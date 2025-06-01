import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobile/core/core.dart';

class ApiServiceImpl implements ApiService {
  final http.Client client;
  final LocalStorage localStorage;
  final String baseUrl;

  ApiServiceImpl({
    http.Client? client,
    LocalStorage? localStorage,
    String? baseUrl,
  }) : client = client ?? http.Client(),
       localStorage = localStorage ?? LocalStorage(),
       baseUrl = baseUrl ?? API_BASE_URL;

  String _getBaseUrl({String? endpoint}) {
    if (endpoint != null && endpoint.startsWith('posts/newPost')) {
      return baseUrl == API_BASE_URL ? API_POST_BASE_URL : baseUrl;
    }

    if (endpoint != null && endpoint.startsWith('push-notifications')) {
      return baseUrl == API_BASE_URL ? API_FCM_BASE_URL : baseUrl;
    }

    return baseUrl;
  }

  Map<String, String> _getHeaders({bool authenticated = true}) {
    final headers = {'Content-Type': 'application/json'};
    if (authenticated) {
      headers['Authorization'] = 'Bearer ${localStorage.accessToken}';
    }
    return headers;
  }

  @override
  Future<http.Response> get(String endpoint, {bool authenticated = true}) {
    return client.get(
      Uri.parse('${_getBaseUrl(endpoint: endpoint)}$endpoint'),
      headers: _getHeaders(authenticated: authenticated),
    );
  }

  @override
  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) {
    return client.post(
      Uri.parse('${_getBaseUrl(endpoint: endpoint)}$endpoint'),
      headers: _getHeaders(authenticated: authenticated),
      body: json.encode(body ?? {}),
    );
  }

  @override
  Future<http.Response> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) {
    return client.patch(
      Uri.parse('${_getBaseUrl(endpoint: endpoint)}$endpoint'),
      headers: _getHeaders(authenticated: authenticated),
      body: json.encode(body ?? {}),
    );
  }

  @override
  Future<http.Response> delete(String endpoint, {bool authenticated = true}) {
    return client.delete(
      Uri.parse('${_getBaseUrl(endpoint: endpoint)}$endpoint'),
      headers: _getHeaders(authenticated: authenticated),
    );
  }

  @override
  Future<http.Response> patchMultipart(
    String endpoint,
    Map<String, String> fields,
    List<http.MultipartFile> files, {
    bool authenticated = true,
  }) async {
    final uri = Uri.parse('${_getBaseUrl(endpoint: endpoint)}$endpoint');
    final request = http.MultipartRequest('PATCH', uri);

    if (authenticated) {
      request.headers['Authorization'] = 'Bearer ${localStorage.accessToken}';
    }

    request.fields.addAll(fields);
    request.files.addAll(files);

    final streamedResponse = await request.send();
    return http.Response.fromStream(streamedResponse);
  }

  @override
  Future<http.Response> postMultipart(
    String endpoint,
    Map<String, String> fields,
    List<http.MultipartFile> files, {
    bool authenticated = true,
  }) async {
    final uri = Uri.parse('${_getBaseUrl(endpoint: endpoint)}$endpoint');
    final request = http.MultipartRequest('POST', uri);

    if (authenticated) {
      request.headers['Authorization'] = 'Bearer ${localStorage.accessToken}';
    }

    request.fields.addAll(fields);
    request.files.addAll(files);

    final streamedResponse = await request.send();
    return http.Response.fromStream(streamedResponse);
  }
}
