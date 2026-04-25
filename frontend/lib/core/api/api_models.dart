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

  Map<String, dynamic> toJson() => {
    'token': token,
    'user': user.toJson(),
  };

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
  });

  final int id;
  final String fullName;
  final String email;
  final String phone;

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] as int,
    fullName: json['full_name'] as String,
    email: json['email'] as String,
    phone: (json['phone'] as String?) ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'full_name': fullName,
    'email': email,
    'phone': phone,
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
