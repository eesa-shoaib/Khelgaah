import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_models.dart';

class ApiClient {
  ApiClient({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  String get baseUrl {
    const configured = String.fromEnvironment('API_BASE_URL');
    if (configured.isNotEmpty) {
      return configured;
    }
    if (kIsWeb) {
      return 'http://localhost:8080';
    }
    if (Platform.isAndroid) {
      const useAdbReverse = bool.fromEnvironment('API_USE_ADB_REVERSE');
      if (useAdbReverse) {
        return 'http://127.0.0.1:8080';
      }
      return 'http://10.0.2.2:8080';
    }
    return 'http://localhost:8080';
  }

  Uri _uri(String path, [Map<String, String>? queryParameters]) {
    return Uri.parse('$baseUrl$path').replace(
      queryParameters: queryParameters?.isEmpty ?? true
          ? null
          : queryParameters,
    );
  }

  Map<String, String> _headers({String? token}) => {
    'Content-Type': 'application/json',
    if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
  };

  Future<AuthResponse> signUp({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String role,
  }) async {
    final response = await _httpClient.post(
      _uri('/api/v1/auth/signup'),
      headers: _headers(),
      body: jsonEncode({
        'full_name': fullName,
        'email': email,
        'password': password,
        'phone': phone,
        'role': role,
      }),
    );
    return _decodeSingle(response, AuthResponse.fromJson);
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _httpClient.post(
      _uri('/api/v1/auth/login'),
      headers: _headers(),
      body: jsonEncode({'email': email, 'password': password}),
    ).timeout(const Duration(seconds: 30));
    return _decodeSingle(response, AuthResponse.fromJson);
  }

  Future<List<FacilityDto>> listFacilities({String? query}) async {
    final response = await _httpClient.get(
      _uri(
        '/api/v1/facilities',
        query != null && query.trim().isNotEmpty ? {'q': query.trim()} : null,
      ),
      headers: _headers(),
    );
    return _decodeList(response, 'facilities', FacilityDto.fromJson);
  }

  Future<List<SlotDto>> listAvailability({
    required int facilityId,
    required DateTime date,
    required int durationMinutes,
  }) async {
    final response = await _httpClient.get(
      _uri('/api/v1/facilities/$facilityId/availability', {
        'date': _formatDate(date),
        'duration': '$durationMinutes',
      }),
      headers: _headers(),
    );
    return _decodeList(response, 'slots', SlotDto.fromJson);
  }

  Future<BookingDto> createBooking({
    required String token,
    required int facilityId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final response = await _httpClient.post(
      _uri('/api/v1/bookings'),
      headers: _headers(token: token),
      body: jsonEncode({
        'facility_id': facilityId,
        'start_time': startTime.toUtc().toIso8601String(),
        'end_time': endTime.toUtc().toIso8601String(),
      }),
    );
    return _decodeSingle(response, BookingDto.fromJson);
  }

  Future<List<BookingDto>> listBookings({required String token}) async {
    final response = await _httpClient.get(
      _uri('/api/v1/bookings'),
      headers: _headers(token: token),
    );
    return _decodeList(response, 'bookings', BookingDto.fromJson);
  }

  Future<UserProfile> me({required String token}) async {
    final response = await _httpClient.get(
      _uri('/api/v1/me'),
      headers: _headers(token: token),
    ).timeout(const Duration(seconds: 30));
    return _decodeSingle(response, UserProfile.fromJson);
  }

  T _decodeSingle<T>(
    http.Response response,
    T Function(Map<String, dynamic>) parser,
  ) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        extractApiErrorMessage(response.body),
        statusCode: response.statusCode,
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return parser(body);
  }

  List<T> _decodeList<T>(
    http.Response response,
    String key,
    T Function(Map<String, dynamic>) parser,
  ) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        extractApiErrorMessage(response.body),
        statusCode: response.statusCode,
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final rawItems = body[key] as List<dynamic>? ?? <dynamic>[];
    return rawItems
        .cast<Map<String, dynamic>>()
        .map(parser)
        .toList(growable: false);
  }

  String _formatDate(DateTime value) {
    final local = DateTime(value.year, value.month, value.day);
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }

  // ==================== VENUE OWNER ENDPOINTS ====================

  Future<DashboardStats> getVenueOwnerDashboard({required String token}) async {
    final response = await _httpClient.get(
      _uri('/api/v1/venue-owner/dashboard'),
      headers: _headers(token: token),
    ).timeout(const Duration(seconds: 30));
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        extractApiErrorMessage(response.body),
        statusCode: response.statusCode,
      );
    }
    return DashboardStats.fromJson(body);
  }

  Future<List<VenueDto>> listVenues({required String token}) async {
    final response = await _httpClient.get(
      _uri('/api/v1/venue-owner/venues'),
      headers: _headers(token: token),
    );
    return _decodeList(response, 'venues', VenueDto.fromJson);
  }

  Future<VenueDto> createVenue({
    required String token,
    required String name,
    required String address,
    required String city,
    double? latitude,
    double? longitude,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'address': address,
      'city': city,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
    final response = await _httpClient.post(
      _uri('/api/v1/venue-owner/venues'),
      headers: _headers(token: token),
      body: jsonEncode(body),
    );
    return _decodeSingle(response, VenueDto.fromJson);
  }

  Future<VenueDto> updateVenue({
    required String token,
    required int venueId,
    required String name,
    required String address,
    required String city,
    double? latitude,
    double? longitude,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'address': address,
      'city': city,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
    final response = await _httpClient.put(
      _uri('/api/v1/venue-owner/venues/$venueId'),
      headers: _headers(token: token),
      body: jsonEncode(body),
    );
    return _decodeSingle(response, VenueDto.fromJson);
  }

  Future<void> deleteVenue({
    required String token,
    required int venueId,
  }) async {
    final response = await _httpClient.delete(
      _uri('/api/v1/venue-owner/venues/$venueId'),
      headers: _headers(token: token),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        extractApiErrorMessage(response.body),
        statusCode: response.statusCode,
      );
    }
  }

  Future<List<VenueOwnerFacilityDto>> listFacilitiesForVenue({
    required String token,
    required int venueId,
  }) async {
    final response = await _httpClient.get(
      _uri('/api/v1/venue-owner/venues/$venueId/facilities'),
      headers: _headers(token: token),
    );
    return _decodeList(response, 'facilities', VenueOwnerFacilityDto.fromJson);
  }

  Future<VenueOwnerFacilityDto> createFacility({
    required String token,
    required int venueId,
    required String name,
    required String description,
    required int capacity,
    required double pricePerHour,
    required List<String> amenities,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'description': description,
      'capacity': capacity,
      'price_per_hour': pricePerHour,
      'amenities': amenities,
    };
    final response = await _httpClient.post(
      _uri('/api/v1/venue-owner/venues/$venueId/facilities'),
      headers: _headers(token: token),
      body: jsonEncode(body),
    );
    return _decodeSingle(response, VenueOwnerFacilityDto.fromJson);
  }

  Future<VenueOwnerFacilityDto> updateFacility({
    required String token,
    required int facilityId,
    required String name,
    required String description,
    required int capacity,
    required double pricePerHour,
    required List<String> amenities,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'description': description,
      'capacity': capacity,
      'price_per_hour': pricePerHour,
      'amenities': amenities,
    };
    final response = await _httpClient.put(
      _uri('/api/v1/venue-owner/facilities/$facilityId'),
      headers: _headers(token: token),
      body: jsonEncode(body),
    );
    return _decodeSingle(response, VenueOwnerFacilityDto.fromJson);
  }

  Future<void> deleteFacility({
    required String token,
    required int facilityId,
  }) async {
    final response = await _httpClient.delete(
      _uri('/api/v1/venue-owner/facilities/$facilityId'),
      headers: _headers(token: token),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        extractApiErrorMessage(response.body),
        statusCode: response.statusCode,
      );
    }
  }

  Future<List<VenueOwnerBookingDto>> listVenueOwnerBookings({
    required String token,
    String? status,
    String? dateFrom,
    String? dateTo,
    int? facilityId,
  }) async {
    final query = <String, String>{};
    if (status != null && status.isNotEmpty) query['status'] = status;
    if (dateFrom != null && dateFrom.isNotEmpty) query['date_from'] = dateFrom;
    if (dateTo != null && dateTo.isNotEmpty) query['date_to'] = dateTo;
    if (facilityId != null) query['facility_id'] = '$facilityId';

    final response = await _httpClient.get(
      _uri('/api/v1/venue-owner/bookings', query.isEmpty ? null : query),
      headers: _headers(token: token),
    );
    return _decodeList(response, 'bookings', VenueOwnerBookingDto.fromJson);
  }

  Future<VenueOwnerBookingDto> getBookingDetails({
    required String token,
    required int bookingId,
  }) async {
    final response = await _httpClient.get(
      _uri('/api/v1/venue-owner/bookings/$bookingId'),
      headers: _headers(token: token),
    );
    return _decodeSingle(response, VenueOwnerBookingDto.fromJson);
  }

  Future<VenueOwnerBookingDto> approveBooking({
    required String token,
    required int bookingId,
  }) async {
    final response = await _httpClient.post(
      _uri('/api/v1/venue-owner/bookings/$bookingId/approve'),
      headers: _headers(token: token),
    );
    return _decodeSingle(response, VenueOwnerBookingDto.fromJson);
  }

  Future<VenueOwnerBookingDto> rejectBooking({
    required String token,
    required int bookingId,
    String? reason,
  }) async {
    final response = await _httpClient.post(
      _uri('/api/v1/venue-owner/bookings/$bookingId/reject'),
      headers: _headers(token: token),
      body: jsonEncode({'reason': reason ?? ''}),
    );
    return _decodeSingle(response, VenueOwnerBookingDto.fromJson);
  }

  Future<VenueOwnerBookingDto> cancelBooking({
    required String token,
    required int bookingId,
    String? reason,
  }) async {
    final response = await _httpClient.post(
      _uri('/api/v1/venue-owner/bookings/$bookingId/cancel'),
      headers: _headers(token: token),
      body: jsonEncode({'reason': reason ?? ''}),
    );
    return _decodeSingle(response, VenueOwnerBookingDto.fromJson);
  }

  Future<List<TimeSlotDto>> listTimeSlots({
    required String token,
    required int facilityId,
    required DateTime date,
  }) async {
    final response = await _httpClient.get(
      _uri('/api/v1/venue-owner/facilities/$facilityId/time-slots', {
        'date': _formatDate(date),
      }),
      headers: _headers(token: token),
    );
    return _decodeList(response, 'slots', TimeSlotDto.fromJson);
  }

  Future<void> addTimeSlot({
    required String token,
    required int facilityId,
    required DateTime date,
    required String startTime,
    required String endTime,
  }) async {
    final response = await _httpClient.post(
      _uri('/api/v1/venue-owner/facilities/$facilityId/time-slots'),
      headers: _headers(token: token),
      body: jsonEncode({
        'date': _formatDate(date),
        'start_time': startTime,
        'end_time': endTime,
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        extractApiErrorMessage(response.body),
        statusCode: response.statusCode,
      );
    }
  }

  Future<void> blockDate({
    required String token,
    required int facilityId,
    required DateTime date,
  }) async {
    final response = await _httpClient.post(
      _uri('/api/v1/venue-owner/facilities/$facilityId/block-date'),
      headers: _headers(token: token),
      body: jsonEncode({'date': _formatDate(date)}),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        extractApiErrorMessage(response.body),
        statusCode: response.statusCode,
      );
    }
  }

  Future<void> deleteTimeSlot({
    required String token,
    required int slotId,
  }) async {
    final response = await _httpClient.delete(
      _uri('/api/v1/venue-owner/time-slots/$slotId'),
      headers: _headers(token: token),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        extractApiErrorMessage(response.body),
        statusCode: response.statusCode,
      );
    }
  }

  Future<AnalyticsData> getAnalytics({
    required String token,
    String? dateFrom,
    String? dateTo,
  }) async {
    final query = <String, String>{};
    if (dateFrom != null && dateFrom.isNotEmpty) query['date_from'] = dateFrom;
    if (dateTo != null && dateTo.isNotEmpty) query['date_to'] = dateTo;

    final response = await _httpClient.get(
      _uri('/api/v1/venue-owner/analytics', query.isEmpty ? null : query),
      headers: _headers(token: token),
    );
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        extractApiErrorMessage(response.body),
        statusCode: response.statusCode,
      );
    }
    return AnalyticsData.fromJson(body);
  }
}
