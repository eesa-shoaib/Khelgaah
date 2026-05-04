import 'dart:convert';

num? parseNum(dynamic value) {
  if (value == null) return null;
  if (value is num) return value;
  if (value is String) return num.tryParse(value);
  return null;
}

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class UserSession {
  const UserSession({required this.token, required this.user});

  final String token;
  final UserProfile user;

  Map<String, dynamic> toJson() => {'token': token, 'user': user.toJson()};

  factory UserSession.fromJson(Map<String, dynamic> json) => UserSession(
    token: json['token'] as String,
    user: UserProfile.fromJson(json['user'] as Map<String, dynamic>),
  );
}

class AuthResponse {
  const AuthResponse({required this.token, required this.user});

  final String token;
  final UserProfile user;

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    token: json['token'] as String,
    user: UserProfile.fromJson(json['user'] as Map<String, dynamic>),
  );
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
  });

  final int id;
  final String fullName;
  final String email;
  final String phone;
  final String role;
  final String status;

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: parseNum(json['id'])?.toInt() ?? 0,
    fullName: json['full_name'] as String,
    email: json['email'] as String,
    phone: (json['phone'] as String?) ?? '',
    role: (json['role'] as String?) ?? 'customer',
    status: (json['status'] as String?) ?? 'active',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'full_name': fullName,
    'email': email,
    'phone': phone,
    'role': role,
    'status': status,
  };
}

class FacilityDto {
  const FacilityDto({
    required this.id,
    required this.venueId,
    required this.name,
    required this.sport,
    required this.type,
    required this.openSummary,
  });

  final int id;
  final int venueId;
  final String name;
  final String sport;
  final String type;
  final String openSummary;

  factory FacilityDto.fromJson(Map<String, dynamic> json) => FacilityDto(
    id: parseNum(json['id'])?.toInt() ?? 0,
    venueId: parseNum(json['venue_id'])?.toInt() ?? 0,
    name: json['name'] as String,
    sport: json['sport'] as String,
    type: json['type'] as String,
    openSummary: json['open_summary'] as String? ?? '',
  );
}

class SlotDto {
  const SlotDto({
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    required this.status,
  });

  final DateTime startTime;
  final DateTime endTime;
  final bool isAvailable;
  final String status;

  factory SlotDto.fromJson(Map<String, dynamic> json) => SlotDto(
    startTime: DateTime.parse(json['start_time'] as String),
    endTime: DateTime.parse(json['end_time'] as String),
    isAvailable: json['is_available'] as bool,
    status: json['status'] as String,
  );
}

class BookingDto {
  const BookingDto({
    required this.id,
    required this.userId,
    required this.facilityId,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.createdAt,
  });

  final int id;
  final int userId;
  final int facilityId;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final DateTime createdAt;

  factory BookingDto.fromJson(Map<String, dynamic> json) => BookingDto(
    id: parseNum(json['id'])?.toInt() ?? 0,
    userId: parseNum(json['user_id'])?.toInt() ?? 0,
    facilityId: parseNum(json['facility_id'])?.toInt() ?? 0,
    startTime: DateTime.parse(json['start_time'] as String),
    endTime: DateTime.parse(json['end_time'] as String),
    status: json['status'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),
  );
}

String extractApiErrorMessage(String body) {
  if (body.isEmpty) {
    return 'Request failed';
  }

  try {
    final payload = jsonDecode(body);
    if (payload is Map<String, dynamic>) {
      final message = payload['error'] ?? payload['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }
  } catch (_) {
    return body;
  }

  return body;
}

class VenueDto {
  final int id;
  final String name;
  final String address;
  final String city;
  final double? latitude;
  final double? longitude;
  final String status;
  final int facilityCount;

  const VenueDto({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    this.latitude,
    this.longitude,
    required this.status,
    this.facilityCount = 0,
  });

  factory VenueDto.fromJson(Map<String, dynamic> json) => VenueDto(
        id: parseNum(json['id'])?.toInt() ?? 0,
        name: json['name'] as String,
        address: json['address'] as String? ?? '',
        city: json['city'] as String? ?? '',
        latitude: parseNum(json['latitude'])?.toDouble(),
        longitude: parseNum(json['longitude'])?.toDouble(),
        status: json['status'] as String? ?? 'pending',
        facilityCount: parseNum(json['facility_count'])?.toInt() ?? 0,
      );
}

class VenueOwnerFacilityDto {
  final int id;
  final int venueId;
  final String name;
  final String sport;
  final String type;
  final String openSummary;
  final String pricePerHour;
  final String status;
  final String? openTime;
  final String? closeTime;
  final int? slotDurationMins;

  const VenueOwnerFacilityDto({
    required this.id,
    required this.venueId,
    required this.name,
    required this.sport,
    required this.type,
    required this.openSummary,
    required this.pricePerHour,
    required this.status,
    this.openTime,
    this.closeTime,
    this.slotDurationMins,
  });

  factory VenueOwnerFacilityDto.fromJson(Map<String, dynamic> json) =>
      VenueOwnerFacilityDto(
        id: parseNum(json['id'])?.toInt() ?? 0,
        venueId: parseNum(json['venue_id'])?.toInt() ?? 0,
        name: json['name'] as String,
        sport: json['sport'] as String? ?? '',
        type: json['type'] as String? ?? '',
        openSummary: json['open_summary'] as String? ?? '',
        pricePerHour: json['price_per_hour'] as String? ?? '0',
        status: json['status'] as String? ?? 'pending',
        openTime: json['open_time'] as String?,
        closeTime: json['close_time'] as String?,
        slotDurationMins: parseNum(json['slot_duration_mins'])?.toInt(),
      );
}

class VenueOwnerBookingDto {
  final int id;
  final int userId;
  final String customerName;
  final int facilityId;
  final String facilityName;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final double totalAmount;
  final String paymentStatus;
  final String? notes;

  const VenueOwnerBookingDto({
    required this.id,
    required this.userId,
    required this.customerName,
    required this.facilityId,
    required this.facilityName,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.totalAmount,
    required this.paymentStatus,
    this.notes,
  });

  factory VenueOwnerBookingDto.fromJson(Map<String, dynamic> json) =>
      VenueOwnerBookingDto(
        id: parseNum(json['id'])?.toInt() ?? 0,
        userId: parseNum(json['user_id'])?.toInt() ?? 0,
        customerName: json['customer_name'] as String? ?? 'Customer',
        facilityId: parseNum(json['facility_id'])?.toInt() ?? 0,
        facilityName: json['facility_name'] as String? ?? 'Facility',
        startTime: DateTime.parse(json['start_time'] as String),
        endTime: DateTime.parse(json['end_time'] as String),
        status: json['status'] as String? ?? 'pending',
        totalAmount: parseNum(json['total_amount'])?.toDouble() ?? 0.0,
        paymentStatus: json['payment_status'] as String? ?? 'pending',
        notes: json['notes'] as String?,
      );
}

class DashboardStats {
  final int totalVenues;
  final int totalFacilities;
  final int totalBookings;
  final String revenue;
  final String occupancyRate;

  const DashboardStats({
    required this.totalVenues,
    required this.totalFacilities,
    required this.totalBookings,
    required this.revenue,
    required this.occupancyRate,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) => DashboardStats(
        totalVenues: parseNum(json['total_venues'])?.toInt() ?? 0,
        totalFacilities: parseNum(json['total_facilities'])?.toInt() ?? 0,
        totalBookings: parseNum(json['total_bookings'])?.toInt() ?? 0,
        revenue: json['revenue'] as String? ?? '0',
        occupancyRate: json['occupancy_rate'] as String? ?? '0',
      );
}

class TimeSlotDto {
  final int? id;
  final DateTime startsAt;
  final DateTime endsAt;
  final String slotType;
  final String status;
  final String? reason;

  const TimeSlotDto({
    this.id,
    required this.startsAt,
    required this.endsAt,
    required this.slotType,
    required this.status,
    this.reason,
  });

  factory TimeSlotDto.fromJson(Map<String, dynamic> json) => TimeSlotDto(
        id: parseNum(json['id'])?.toInt(),
        startsAt: DateTime.parse(json['starts_at'] as String),
        endsAt: DateTime.parse(json['ends_at'] as String),
        slotType: json['slot_type'] as String? ?? 'available',
        status: json['status'] as String? ?? 'active',
        reason: json['reason'] as String?,
      );
}

class AnalyticsPoint {
  final String day;
  final int bookings;
  final String revenue;

  const AnalyticsPoint({
    required this.day,
    required this.bookings,
    required this.revenue,
  });

  factory AnalyticsPoint.fromJson(Map<String, dynamic> json) => AnalyticsPoint(
        day: json['day'] as String? ?? '',
        bookings: parseNum(json['bookings'])?.toInt() ?? 0,
        revenue: json['revenue'] as String? ?? '0',
      );
}

class AnalyticsData {
  final List<AnalyticsPoint> analytics;

  const AnalyticsData({required this.analytics});

  factory AnalyticsData.fromJson(Map<String, dynamic> json) => AnalyticsData(
        analytics: (json['analytics'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>()
                .map(AnalyticsPoint.fromJson)
                .toList() ??
            const [],
      );
}
