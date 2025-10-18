import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  /// Get the base URL based on debug mode
  static String get baseUrl {
    if (false) {
      return 'http://10.10.30.101:3000';
    } else {
      return 'https://rema.tihlde.org';
    }
  }

  /// Build a complete URL from a path
  Uri _buildUri(String path) {
    return Uri.parse('$baseUrl$path');
  }

  /// GET request
  Future<dynamic> get(String path) async {
    try {
      final response = await _client.get(
        _buildUri(path),
        headers: {'Content-Type': 'application/json'},
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  /// POST request
  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    try {
      final response = await _client.post(
        _buildUri(path),
        headers: {'Content-Type': 'application/json'},
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  /// PATCH request
  Future<dynamic> patch(String path, {Map<String, dynamic>? body}) async {
    try {
      final response = await _client.patch(
        _buildUri(path),
        headers: {'Content-Type': 'application/json'},
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  /// PUT request
  Future<dynamic> put(String path, {Map<String, dynamic>? body}) async {
    try {
      final response = await _client.put(
        _buildUri(path),
        headers: {'Content-Type': 'application/json'},
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  /// DELETE request
  Future<void> delete(String path) async {
    try {
      final response = await _client.delete(
        _buildUri(path),
        headers: {'Content-Type': 'application/json'},
      );
      _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  /// Handle HTTP response
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.statusCode == 204 || response.body.isEmpty) {
        return null;
      }
      return jsonDecode(response.body);
    } else {
      throw ApiException(
        'Request failed with status ${response.statusCode}: ${response.body}',
        statusCode: response.statusCode,
      );
    }
  }

  void dispose() {
    _client.close();
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message';
}
