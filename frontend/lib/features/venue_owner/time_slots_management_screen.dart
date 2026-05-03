import 'package:flutter/material.dart';
import 'package:frontend/core/api/api_models.dart';
import 'package:frontend/core/app_controller.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/utils/app_feedback.dart';
import 'package:frontend/core/widgets/confirmation_dialog_widget.dart';
import 'package:frontend/core/widgets/parallelogram_btn.dart';
import 'package:frontend/core/widgets/profile_action_icon.dart';

class TimeSlotsManagementScreen extends StatefulWidget {
  final int facilityId;
  final VenueOwnerFacilityDto? facility;

  const TimeSlotsManagementScreen({
    super.key,
    required this.facilityId,
    this.facility,
  });

  @override
  State<TimeSlotsManagementScreen> createState() =>
      _TimeSlotsManagementScreenState();
}

class _TimeSlotsManagementScreenState extends State<TimeSlotsManagementScreen> {
  late DateTime _selectedDate;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isGenerating = false;
  List<TimeSlotDto> _slots = [];
  String? _error;
  VenueOwnerFacilityDto? _facility;
  
  TimeOfDay _openTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _closeTime = const TimeOfDay(hour: 22, minute: 0);
  int _slotDuration = 60;

  bool get _canSave {
    return _openTime.hour < _closeTime.hour || 
        (_openTime.hour == _closeTime.hour && _openTime.minute < _closeTime.minute);
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _facility = widget.facility;
    
    if (_facility?.openTime != null) {
      final parts = _facility!.openTime!.split(':');
      if (parts.length >= 2) {
        _openTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 9,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }
    if (_facility?.closeTime != null) {
      final parts = _facility!.closeTime!.split(':');
      if (parts.length >= 2) {
        _closeTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 22,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }
    if (_facility?.slotDurationMins != null) {
      _slotDuration = _facility!.slotDurationMins!;
    }
    
    _loadTimeSlots();
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
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

  Future<void> _saveOpeningHours() async {
    if (!_canSave) {
      AppFeedback.pulseMessage(
        context,
        message: 'Close time must be after open time',
        icon: Icons.error_outline,
      );
      return;
    }

    final controller = AppScope.of(context);
    final token = controller.session?.token;
    if (token == null) return;

    setState(() => _isSaving = true);

    try {
      await controller.apiClient.updateFacility(
        token: token,
        facilityId: widget.facilityId,
        name: _facility?.name ?? '',
        sport: _facility?.sport ?? '',
        type: _facility?.type ?? '',
        openSummary: _facility?.openSummary ?? '',
        pricePerHour: double.tryParse(_facility?.pricePerHour ?? '0') ?? 0,
        status: _facility?.status ?? 'active',
        openTime: _formatTimeOfDay(_openTime),
        closeTime: _formatTimeOfDay(_closeTime),
        slotDurationMins: _slotDuration,
      );
      if (!mounted) return;
      _facility = VenueOwnerFacilityDto(
        id: _facility!.id,
        venueId: _facility!.venueId,
        name: _facility!.name,
        sport: _facility!.sport,
        type: _facility!.type,
        openSummary: _facility!.openSummary,
        pricePerHour: _facility!.pricePerHour,
        status: _facility!.status,
        openTime: _formatTimeOfDay(_openTime),
        closeTime: _formatTimeOfDay(_closeTime),
        slotDurationMins: _slotDuration,
      );
      
      await _generateSlots();
    } on ApiException catch (e) {
      if (!mounted) return;
      AppFeedback.pulseMessage(
        context,
        message: e.message,
        icon: Icons.error_outline,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  int _countSlotsToGenerate() {
    int count = 0;
    var current = _openTime;
    
    while (current.hour < _closeTime.hour || 
        (current.hour == _closeTime.hour && current.minute < _closeTime.minute)) {
      final endMinutes = current.hour * 60 + current.minute + _slotDuration;
      if (endMinutes > current.hour * 60 + current.minute) {
        final endHour = endMinutes ~/ 60;
        final endMin = endMinutes % 60;
        
        if (endHour > _closeTime.hour || 
            (endHour == _closeTime.hour && endMin > _closeTime.minute)) {
          break;
        }
        count++;
        current = TimeOfDay(hour: endHour, minute: endMin);
      } else {
        break;
      }
    }
    
    return count;
  }

  Future<void> _generateSlots() async {
    final count = _countSlotsToGenerate();
    if (count == 0) {
      AppFeedback.pulseMessage(
        context,
        message: 'Invalid hours or duration',
        icon: Icons.error_outline,
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Slots'),
        content: Text('Add $count time slots for this facility?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Generate'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    setState(() => _isGenerating = true);

    final controller = AppScope.of(context);
    final token = controller.session?.token;
    if (token == null) return;

    var current = _openTime;
    int generated = 0;

    try {
      while (current.hour < _closeTime.hour || 
          (current.hour == _closeTime.hour && current.minute < _closeTime.minute)) {
        final endMinutes = current.hour * 60 + current.minute + _slotDuration;
        if (endMinutes > current.hour * 60 + current.minute) {
          final endHour = endMinutes ~/ 60;
          final endMin = endMinutes % 60;
          
          if (endHour > _closeTime.hour || 
              (endHour == _closeTime.hour && endMin > _closeTime.minute)) {
            break;
          }
          
          final startsAt = DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
            current.hour,
            current.minute,
          ).toUtc().toIso8601String();

          final endsAt = DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
            endHour,
            endMin,
          ).toUtc().toIso8601String();

          await controller.apiClient.addTimeSlot(
            token: token,
            facilityId: widget.facilityId,
            startsAt: startsAt,
            endsAt: endsAt,
            slotType: 'available',
          );
          
          generated++;
          current = TimeOfDay(hour: endHour, minute: endMin);
        } else {
          break;
        }
      }

      if (!mounted) return;
      AppFeedback.pulseMessage(
        context,
        message: '$generated slots generated',
        icon: Icons.check_circle_outline,
      );
      _loadTimeSlots();
    } catch (e) {
      if (!mounted) return;
      AppFeedback.pulseMessage(
        context,
        message: 'Generated $generated slots',
        icon: Icons.info_outline,
      );
      _loadTimeSlots();
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _deleteSlot(TimeSlotDto slot) async {
    if (slot.id == null) return;

    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Delete Slot',
      message: 'Delete "${_formatTimeRange(slot)}"?',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (!confirmed) return;
    if (!mounted) return;

    final controller = AppScope.of(context);
    final token = controller.session?.token;
    if (token == null) return;

    try {
      await controller.apiClient.deleteTimeSlot(
        token: token,
        slotId: slot.id!,
      );
      if (!mounted) return;
      AppFeedback.pulseMessage(
        context,
        message: 'Slot deleted',
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

  String _formatTimeRange(TimeSlotDto slot) {
    return '${_formatTime(slot.startsAt)} - ${_formatTime(slot.endsAt)}';
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_facility?.name ?? 'Time Slots'),
        actions: const [ProfileActionIcon()],
      ),
      body: Column(
        children: [
          _buildHoursSection(theme),
          _buildDateSelector(theme),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  _formatDate(_selectedDate),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_slots.length} slots',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildSlotsList()),
        ],
      ),
    );
  }

  Widget _buildHoursSection(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Operating Hours',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _TimePickerField(
                  label: 'Opens',
                  time: _openTime,
                  onTap: () => _pickTime(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TimePickerField(
                  label: 'Closes',
                  time: _closeTime,
                  onTap: () => _pickTime(false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DurationPickerField(
                  value: _slotDuration,
                  onChanged: (v) => setState(() => _slotDuration = v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _canSave
                    ? ParallelogramButton(
                        onPressed: _isSaving || _isGenerating ? () {} : _saveOpeningHours,
                        text: _isSaving ? 'Saving...' : _isGenerating ? 'Generating...' : 'Generate',
                        icon: Icons.auto_awesome,
                        variant: ParallelogramButtonVariant.primary,
                      )
                    : ParallelogramButton(
                        onPressed: () {},
                        text: 'Invalid',
                        icon: Icons.warning,
                        variant: ParallelogramButtonVariant.surface,
                      ),
              ),
            ],
          ),
          if (!_canSave) ...[
            const SizedBox(height: 8),
            Text(
              'Close time must be after open time',
              style: TextStyle(
                color: AppTheme.error,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickTime(bool isOpen) async {
    final time = await showTimePicker(
      context: context,
      initialTime: isOpen ? _openTime : _closeTime,
    );
    if (time != null) {
      setState(() {
        if (isOpen) {
          _openTime = time;
        } else {
          _closeTime = time;
        }
      });
    }
  }

  Widget _buildDateSelector(ThemeData theme) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          for (int i = -3; i <= 21; i++)
            _DateChip(
              date: _selectedDate.add(Duration(days: i)),
              isSelected: isSameDay(_selectedDate.add(Duration(days: i)), _selectedDate),
              onTap: () {
                setState(() {
                  _selectedDate = _selectedDate.add(Duration(days: i));
                });
                _loadTimeSlots();
              },
            ),
        ],
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
            Icon(Icons.event_busy, size: 48, color: AppTheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              'No slots for this date',
              style: TextStyle(color: AppTheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _slots.length,
      itemBuilder: (context, index) {
        final slot = _slots[index];
        final isBlocked = slot.slotType == 'blocked';
        final isBooked = slot.status == 'booked';
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isBlocked
                ? AppTheme.error.withValues(alpha: 0.1)
                : isBooked
                    ? Colors.green.withValues(alpha: 0.1)
                    : AppTheme.surfaceContainer,
            border: Border(
              left: BorderSide(
                color: isBlocked 
                    ? AppTheme.error 
                    : isBooked 
                        ? Colors.green 
                        : AppTheme.primary,
                width: 3,
              ),
              top: BorderSide(color: AppTheme.outlineVariant),
              bottom: BorderSide(color: AppTheme.outlineVariant),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isBlocked ? Icons.block : isBooked ? Icons.check_circle : Icons.schedule,
                size: 18,
                color: isBlocked ? AppTheme.error : isBooked ? Colors.green : AppTheme.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _formatTimeRange(slot),
                  style: TextStyle(
                    color: AppTheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isBlocked)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.error),
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
              else if (isBooked)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green),
                  ),
                  child: const Text(
                    'BOOKED',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else
                GestureDetector(
                  onTap: () => _deleteSlot(slot),
                  child: Icon(Icons.delete_outline, size: 18, color: AppTheme.error),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _TimePickerField extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  const _TimePickerField({
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.outlineVariant),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppTheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
            const Spacer(),
            Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DurationPickerField extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _DurationPickerField({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: DropdownButton<int>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        items: [30, 45, 60, 90, 120].map((d) {
          return DropdownMenuItem(
            value: d,
            child: Text('$d min'),
          );
        }).toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final VoidCallback onTap;

  const _DateChip({
    required this.date,
    required this.isSelected,
    required this.onTap,
  });

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final isToday = isSameDay(date, DateTime.now());
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.surfaceContainer,
          border: Border.all(
            color: isToday ? AppTheme.tertiary : AppTheme.outlineVariant,
            width: isToday ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayNames[date.weekday - 1],
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? AppTheme.onPrimary : AppTheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppTheme.onPrimary : AppTheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}