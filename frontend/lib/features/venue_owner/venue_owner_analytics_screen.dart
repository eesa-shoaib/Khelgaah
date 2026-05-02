import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/core/api/api_models.dart';
import 'package:frontend/core/app_controller.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/profile_action_icon.dart';

class VenueOwnerAnalyticsScreen extends StatefulWidget {
  const VenueOwnerAnalyticsScreen({super.key});

  @override
  State<VenueOwnerAnalyticsScreen> createState() =>
      _VenueOwnerAnalyticsScreenState();
}

class _VenueOwnerAnalyticsScreenState extends State<VenueOwnerAnalyticsScreen> {
  bool _isLoading = true;
  AnalyticsData? _data;
  String? _error;
  DateTime? _dateFrom;
  DateTime? _dateTo;

  @override
  void initState() {
    super.initState();
    _dateTo = DateTime.now();
    _dateFrom = DateTime.now().subtract(const Duration(days: 30));
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    final controller = AppScope.of(context);
    final token = controller.session?.token;
    if (token == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await controller.apiClient.getAnalytics(
        token: token,
        dateFrom: _dateFrom != null ? _formatDate(_dateFrom!) : null,
        dateTo: _dateTo != null ? _formatDate(_dateTo!) : null,
      );
      if (!mounted) return;
      setState(() {
        _data = data;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load analytics.';
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _dateFrom != null && _dateTo != null
          ? DateTimeRange(start: _dateFrom!, end: _dateTo!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _dateFrom = picked.start;
        _dateTo = picked.end;
      });
      _loadAnalytics();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [ProfileActionIcon()],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorState(message: _error!, onRetry: _loadAnalytics)
              : _data == null
                  ? const Center(child: Text('No data available.'))
                  : _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildDateFilter(theme),
        const SizedBox(height: 20),
        _buildSectionTitle(theme, 'Revenue Over Time'),
        const SizedBox(height: 12),
        _buildLineChart(_data!.revenueData, 'Revenue (PKR)'),
        const SizedBox(height: 24),
        _buildSectionTitle(theme, 'Bookings by Facility'),
        const SizedBox(height: 12),
        _buildBarChart(_data!.bookingsByFacility, 'Bookings'),
        const SizedBox(height: 24),
        _buildSectionTitle(theme, 'Occupancy Rate by Facility'),
        const SizedBox(height: 12),
        _buildBarChart(_data!.occupancyByFacility, 'Occupancy %'),
        const SizedBox(height: 24),
        _buildSectionTitle(theme, 'Peak Hours Analysis'),
        const SizedBox(height: 12),
        _buildBarChart(_data!.peakHours, 'Bookings'),
      ],
    );
  }

  Widget _buildDateFilter(ThemeData theme) {
    return GestureDetector(
      onTap: _selectDateRange,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.date_range, size: 16, color: AppTheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              _dateFrom != null && _dateTo != null
                  ? '${_formatDate(_dateFrom!)} → ${_formatDate(_dateTo!)}'
                  : 'Select date range',
              style: TextStyle(
                color:
                    _dateFrom != null ? AppTheme.onSurface : AppTheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        color: AppTheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildLineChart(List<ChartDataPoint> data, String label) {
    if (data.isEmpty) {
      return _EmptyChart(message: 'No revenue data available.');
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: _getInterval(data),
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppTheme.outlineVariant,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, _) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10, color: AppTheme.onSurfaceVariant),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, _) {
                  final index = value.toInt();
                  if (index < 0 || index >= data.length) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    data[index].label.length > 5
                        ? data[index].label.substring(0, 5)
                        : data[index].label,
                    style: const TextStyle(fontSize: 9, color: AppTheme.onSurfaceVariant),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: AppTheme.outlineVariant),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: data.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value.value);
              }).toList(),
              isCurved: true,
              color: AppTheme.primary,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.primary.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(List<ChartDataPoint> data, String label) {
    if (data.isEmpty) {
      return _EmptyChart(message: 'No data available.');
    }

    final maxVal = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Container(
      height: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: BarChart(
        BarChartData(
          maxY: maxVal * 1.2,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxVal / 4,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppTheme.outlineVariant,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, _) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10, color: AppTheme.onSurfaceVariant),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, _) {
                  final index = value.toInt();
                  if (index < 0 || index >= data.length) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    data[index].label.length > 8
                        ? data[index].label.substring(0, 8)
                        : data[index].label,
                    style: const TextStyle(fontSize: 9, color: AppTheme.onSurfaceVariant),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: AppTheme.outlineVariant),
          ),
          barGroups: data.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.value,
                  color: AppTheme.primary,
                  width: 16,
                  borderRadius: BorderRadius.zero,
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  double _getInterval(List<ChartDataPoint> data) {
    if (data.isEmpty) return 100;
    final maxVal = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    return maxVal / 4;
  }
}

class _EmptyChart extends StatelessWidget {
  final String message;

  const _EmptyChart({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(color: AppTheme.onSurfaceVariant),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, style: const TextStyle(color: AppTheme.error)),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
