import 'package:flutter/material.dart';

class BookedFacilityDetails {
  final String facilityName;
  final String dayLabel;
  final String dateLabel;
  final String timeLabel;
  final int durationMinutes;
  final double subtotal;
  final double serviceFee;
  final bool isPaid;
  final String bookingId;
  final String accessNote;

  const BookedFacilityDetails({
    required this.facilityName,
    required this.dayLabel,
    required this.dateLabel,
    required this.timeLabel,
    required this.durationMinutes,
    required this.subtotal,
    required this.serviceFee,
    this.isPaid = false,
    required this.bookingId,
    required this.accessNote,
  });

  double get total => subtotal + serviceFee;

  String get scheduleLabel =>
      '$dayLabel $dateLabel • $timeLabel • $durationMinutes minutes';

  String get paymentStatusLabel => isPaid ? 'PAID' : 'PAYMENT PENDING';

  String get reservationStateLabel => isPaid ? 'Confirmed' : 'Awaiting Payment';

  Color get paymentStatusColor =>
      isPaid ? const Color(0xFFE5A72A) : const Color(0xFFC4693D);

  BookedFacilityDetails copyWith({
    String? facilityName,
    String? dayLabel,
    String? dateLabel,
    String? timeLabel,
    int? durationMinutes,
    double? subtotal,
    double? serviceFee,
    bool? isPaid,
    String? bookingId,
    String? accessNote,
  }) {
    return BookedFacilityDetails(
      facilityName: facilityName ?? this.facilityName,
      dayLabel: dayLabel ?? this.dayLabel,
      dateLabel: dateLabel ?? this.dateLabel,
      timeLabel: timeLabel ?? this.timeLabel,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      subtotal: subtotal ?? this.subtotal,
      serviceFee: serviceFee ?? this.serviceFee,
      isPaid: isPaid ?? this.isPaid,
      bookingId: bookingId ?? this.bookingId,
      accessNote: accessNote ?? this.accessNote,
    );
  }
}
