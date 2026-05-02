import 'package:flutter/material.dart';
import 'package:frontend/core/api/api_models.dart';
import 'package:frontend/core/app_controller.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/utils/app_feedback.dart';
import 'package:frontend/core/widgets/confirmation_dialog_widget.dart';
import 'package:frontend/core/widgets/profile_action_icon.dart';
import 'package:table_calendar/table_calendar.dart';

class TimeSlotsManagementScreen extends StatefulWidget {
  final int facilityId;

  const TimeSlotsManagementScreen({super.key, required this.facilityId});

  @override
  State<TimeSlotsManagementScreen> createState() =>
      _TimeSlotsManagementScreenState();
}

class _TimeSlotsManagementScreenState extends State<TimeSlotsManagementScreen> {
  late DateTime _selectedDate;
  bool _isLoading = true;
  List<TimeSlotDto> _slots = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadTimeSlots();
  }

  Future<void> _loadTimeSlots() async {
    final controller = AppScope.of(context);
    final token = controller.session?.token;
    if (token == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final slots = await controller.apiClient.listTimeSlots(
        token: token,
        facilityId: widget.facilityId,
        date: _selectedDate,
      );
      if (!mounted) return;
      setState(() {
        _slots = slots;
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
        _error = 'Failed to load time slots.';
        _isLoading = false;
      });
    }
  }

  Future<void> _addTimeSlot() async {
    final result = await showDialog<_TimeSlotFormResult>(
      context: context,
      builder: (_) => const _AddTimeSlotDialog(),
    );

    if (result == null) return;

    final controller = AppScope.of(context);
    final token = controller.session?.token;
    if (token == null) return;

    try {
      await controller.apiClient.addTimeSlot(
        token: token,
        facilityId: widget.facilityId,
        date: _selectedDate,
        startTime: result.startTime,
        endTime: result.endTime,
      );
      AppFeedback.pulseMessage(
        context,
        message: 'Time slot added successfully.',
        icon: Icons.check_circle_outline,
      );
      _loadTimeSlots();
    } on ApiException catch (e) {
      if (!mounted) return;
      AppFeedback.pulseMessage(
        context,
        message: e.message,
        icon: Icons.error_outline,
      );
    }
  }

  Future<void> _blockDate() async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Block Date',
      message:
          'Are you sure you want to block ${_formatDate(_selectedDate)}? No bookings will be allowed on this date.',
      confirmText: 'Block',
      isDestructive: true,
    );

    if (!confirmed) return;

    final controller = AppScope.of(context);
    final token = controller.session?.token;
    if (token == null) return;

    try {
      await controller.apiClient.blockDate(
        token: token,
        facilityId: widget.facilityId,
        date: _selectedDate,
      );
      AppFeedback.pulseMessage(
        context,
        message: 'Date blocked successfully.',
        icon: Icons.check_circle_outline,
      );
      _loadTimeSlots();
    } on ApiException catch (e) {
      if (!mounted) return;
      AppFeedback.pulseMessage(
        context,
        message: e.message,
        icon: Icons.error_outline,
      );
    }
  }

  Future<void> _deleteTimeSlot(TimeSlotDto slot) async {
    if (slot.id == null) return;

    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Delete Time Slot',
      message: 'Are you sure you want to delete this time slot?',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (!confirmed) return;

    final controller = AppScope.of(context);
    final token = controller.session?.token;
    if (token == null) return;

    try {
      await controller.apiClient.deleteTimeSlot(
        token: token,
        slotId: slot.id!,
      );
      AppFeedback.pulseMessage(
        context,
        message: 'Time slot deleted successfully.',
        icon: Icons.check_circle_outline,
      );
      _loadTimeSlots();
    } on ApiException catch (e) {
      if (!mounted) return;
      AppFeedback.pulseMessage(
        context,
        message: e.message,
        icon: Icons.error_outline,
      );
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
        title: const Text('Time Slots'),
        actions: [ProfileActionIcon()],
      ),
      body: Column(
        children: [
          _buildCalendar(theme),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Slots for ${_formatDate(_selectedDate)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _blockDate,
                  icon: const Icon(Icons.block, size: 16),
                  label: const Text('Block Date'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.error,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildSlotsList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTimeSlot,
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCalendar(ThemeData theme) {
    return TableCalendar(
      firstDay: DateTime.now().subtract(const Duration(days: 30)),
      lastDay: DateTime.now().add(const Duration(days: 365)),
      focusedDay: _selectedDate,
      selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
      onDaySelected: (selectedDay, _) {
        setState(() => _selectedDate = selectedDay);
        _loadTimeSlots();
      },
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: AppTheme.primary,
          shape: BoxShape.circle,
        ),
        defaultTextStyle: TextStyle(color: AppTheme.onSurface),
        weekendTextStyle: TextStyle(color: AppTheme.onSurface),
      ),
      headerStyle: HeaderStyle(
        titleTextStyle: theme.textTheme.titleMedium!.copyWith(
          color: AppTheme.onSurface,
        ),
        formatButtonVisible: false,
      ),
    );
  }

  Widget _buildSlotsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: AppTheme.error)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loadTimeSlots, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_slots.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.schedule_outlined,
                size: 48, color: AppTheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              'No time slots for this date.',
              style: TextStyle(color: AppTheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        for (final slot in _slots)
          _SlotTile(
            slot: slot,
            onDelete: slot.id != null ? () => _deleteTimeSlot(slot) : null,
          ),
      ],
    );
  }
}

class _SlotTile extends StatelessWidget {
  final TimeSlotDto slot;
  final VoidCallback? onDelete;

  const _SlotTile({required this.slot, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBlocked = slot.isBlocked;
    final isAvailable = slot.isAvailable && !isBlocked;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isBlocked
            ? AppTheme.error.withValues(alpha: 0.1)
            : isAvailable
                ? Colors.green.withValues(alpha: 0.1)
                : AppTheme.surfaceContainer,
        border: Border(
          left: BorderSide(
            color: isBlocked
                ? AppTheme.error
                : isAvailable
                    ? Colors.greenAccent
                    : AppTheme.outlineVariant,
            width: 3,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isBlocked
                ? Icons.block
                : isAvailable
                    ? Icons.check_circle
                    : Icons.cancel,
            size: 16,
            color: isBlocked
                ? AppTheme.error
                : isAvailable
                    ? Colors.greenAccent
                    : AppTheme.onSurfaceVariant,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${slot.startTime} - ${slot.endTime}',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (isBlocked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.error, width: 1),
              ),
              child: const Text(
                'BLOCKED',
                style: TextStyle(
                  color: AppTheme.error,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else if (isAvailable)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.greenAccent, width: 1),
              ),
              child: const Text(
                'AVAILABLE',
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          if (onDelete != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDelete,
              child: Icon(Icons.delete_outline, size: 18, color: AppTheme.error),
            ),
          ],
        ],
      ),
    );
  }
}

class _AddTimeSlotDialog extends StatefulWidget {
  const _AddTimeSlotDialog();

  @override
  State<_AddTimeSlotDialog> createState() => _AddTimeSlotDialogState();
}

class _AddTimeSlotDialogState extends State<_AddTimeSlotDialog> {
  final _startController = TextEditingController();
  final _endController = TextEditingController();

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Time Slot'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _startController,
            decoration: const InputDecoration(
              labelText: 'Start Time (HH:mm)',
              hintText: 'e.g. 09:00',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _endController,
            decoration: const InputDecoration(
              labelText: 'End Time (HH:mm)',
              hintText: 'e.g. 10:00',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_startController.text.isNotEmpty &&
                _endController.text.isNotEmpty) {
              Navigator.pop(
                context,
                _TimeSlotFormResult(
                  startTime: _startController.text.trim(),
                  endTime: _endController.text.trim(),
                ),
              );
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class _TimeSlotFormResult {
  final String startTime;
  final String endTime;

  const _TimeSlotFormResult({required this.startTime, required this.endTime});
}
