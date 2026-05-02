import 'dart:convert';

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
    id: json['id'] as int,
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
    id: json['id'] as int,
    venueId: json['venue_id'] as int,
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
  });

  final DateTime startTime;
  final DateTime endTime;
  final bool isAvailable;

  factory SlotDto.fromJson(Map<String, dynamic> json) => SlotDto(
    startTime: DateTime.parse(json['start_time'] as String),
    endTime: DateTime.parse(json['end_time'] as String),
    isAvailable: json['is_available'] as bool,
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
    id: json['id'] as int,
    userId: json['user_id'] as int,
    facilityId: json['facility_id'] as int,
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
        id: json['id'] as int,
        name: json['name'] as String,
        address: json['address'] as String? ?? '',
        city: json['city'] as String? ?? '',
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        status: json['status'] as String? ?? 'pending',
        facilityCount: json['facility_count'] as int? ?? 0,
      );
}

class VenueOwnerFacilityDto {
  final int id;
  final int venueId;
  final String name;
  final String description;
  final int capacity;
  final double pricePerHour;
  final String status;
  final List<String> amenities;

  const VenueOwnerFacilityDto({
    required this.id,
    required this.venueId,
    required this.name,
    required this.description,
    required this.capacity,
    required this.pricePerHour,
    required this.status,
    this.amenities = const [],
  });

  factory VenueOwnerFacilityDto.fromJson(Map<String, dynamic> json) =>
      VenueOwnerFacilityDto(
        id: json['id'] as int,
        venueId: json['venue_id'] as int,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        capacity: json['capacity'] as int? ?? 0,
        pricePerHour: (json['price_per_hour'] as num?)?.toDouble() ?? 0.0,
        status: json['status'] as String? ?? 'pending',
        amenities: (json['amenities'] as List<dynamic>?)
                ?.cast<String>()
                .toList() ??
            const [],
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
        id: json['id'] as int,
        userId: json['user_id'] as int,
        customerName: json['customer_name'] as String? ?? 'Customer',
        facilityId: json['facility_id'] as int,
        facilityName: json['facility_name'] as String? ?? 'Facility',
        startTime: DateTime.parse(json['start_time'] as String),
        endTime: DateTime.parse(json['end_time'] as String),
        status: json['status'] as String? ?? 'pending',
        totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
        paymentStatus: json['payment_status'] as String? ?? 'pending',
        notes: json['notes'] as String?,
      );
}

class DashboardStats {
  final int totalBookings;
  final double totalRevenue;
  final double occupancyRate;
  final int pendingApprovals;
  final List<VenueOwnerBookingDto> recentBookings;

  const DashboardStats({
    required this.totalBookings,
    required this.totalRevenue,
    required this.occupancyRate,
    required this.pendingApprovals,
    required this.recentBookings,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) => DashboardStats(
        totalBookings: json['total_bookings'] as int? ?? 0,
        totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
        occupancyRate: (json['occupancy_rate'] as num?)?.toDouble() ?? 0.0,
        pendingApprovals: json['pending_approvals'] as int? ?? 0,
        recentBookings: (json['recent_bookings'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>()
                .map(VenueOwnerBookingDto.fromJson)
                .toList() ??
            const [],
      );
}

class TimeSlotDto {
  final int? id;
  final DateTime date;
  final String startTime;
  final String endTime;
  final bool isAvailable;
  final bool isBlocked;

  const TimeSlotDto({
    this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    this.isBlocked = false,
  });

  factory TimeSlotDto.fromJson(Map<String, dynamic> json) => TimeSlotDto(
        id: json['id'] as int?,
        date: DateTime.parse(json['date'] as String),
        startTime: json['start_time'] as String,
        endTime: json['end_time'] as String,
        isAvailable: json['is_available'] as bool? ?? true,
        isBlocked: json['is_blocked'] as bool? ?? false,
      );
}

class AnalyticsData {
  final List<ChartDataPoint> revenueData;
  final List<ChartDataPoint> bookingsByFacility;
  final List<ChartDataPoint> occupancyByFacility;
  final List<ChartDataPoint> peakHours;

  const AnalyticsData({
    required this.revenueData,
    required this.bookingsByFacility,
    required this.occupancyByFacility,
    required this.peakHours,
  });

  factory AnalyticsData.fromJson(Map<String, dynamic> json) => AnalyticsData(
        revenueData: (json['revenue_data'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>()
                .map(ChartDataPoint.fromJson)
                .toList() ??
            const [],
        bookingsByFacility: (json['bookings_by_facility'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>()
                .map(ChartDataPoint.fromJson)
                .toList() ??
            const [],
        occupancyByFacility: (json['occupancy_by_facility'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>()
                .map(ChartDataPoint.fromJson)
                .toList() ??
            const [],
        peakHours: (json['peak_hours'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>()
                .map(ChartDataPoint.fromJson)
                .toList() ??
            const [],
      );
}

class ChartDataPoint {
  final String label;
  final double value;

  const ChartDataPoint({required this.label, required this.value});

  factory ChartDataPoint.fromJson(Map<String, dynamic> json) => ChartDataPoint(
        label: json['label'] as String? ?? '',
        value: (json['value'] as num?)?.toDouble() ?? 0.0,
      );
}
