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
    );
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
    );
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
}
