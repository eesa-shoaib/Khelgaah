class BookedFacilityDetails {
  final String facilityName;
  final String facilityType;
  final String facilitySummary;
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;
  final String bookingId;
  final String status;

  const BookedFacilityDetails({
    required this.facilityName,
    required this.facilityType,
    required this.facilitySummary,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.bookingId,
    required this.status,
  });

  String get scheduleLabel =>
      '${_weekdayLabel(startTime)} ${_monthLabel(startTime)} ${startTime.day} • '
      '${_timeLabel(startTime)} - ${_timeLabel(endTime)} • $durationMinutes minutes';

  String get statusLabel => status.toUpperCase();

  String get reservationStateLabel {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'Confirmed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  BookedFacilityDetails copyWith({
    String? facilityName,
    String? facilityType,
    String? facilitySummary,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    String? bookingId,
    String? status,
  }) {
    return BookedFacilityDetails(
      facilityName: facilityName ?? this.facilityName,
      facilityType: facilityType ?? this.facilityType,
      facilitySummary: facilitySummary ?? this.facilitySummary,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      bookingId: bookingId ?? this.bookingId,
      status: status ?? this.status,
    );
  }
}

String _weekdayLabel(DateTime value) {
  const labels = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  return labels[value.weekday - 1];
}

String _monthLabel(DateTime value) {
  const labels = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];
  return labels[value.month - 1];
}

String _timeLabel(DateTime value) {
  final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  final minute = value.minute.toString().padLeft(2, '0');
  final suffix = value.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $suffix';
}
