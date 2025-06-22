import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobile/core/core.dart';
import 'package:mobile/src/auth/_children/_children.dart';

class ApiServiceImpl implements ApiService {
  final http.Client client;
  final LocalStorage localStorage;
  final String baseUrl;
  final ServiceLocator serviceLocator;

  ApiServiceImpl({
    http.Client? client,
    LocalStorage? localStorage,
    String? baseUrl,
    ServiceLocator? serviceLocator,
  }) : client = client ?? http.Client(),
       localStorage = localStorage ?? LocalStorage(),
       baseUrl = baseUrl ?? API_BASE_URL,
       serviceLocator = serviceLocator ?? ServiceLocator();

  String _getBaseUrl({String? endpoint}) {
    if (endpoint != null && endpoint.startsWith('posts/')) {
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

  Future<http.Response> _handleResponse(http.Response response) async {
    if (response.statusCode == 401) {
      final scaffoldMessengerKey = serviceLocator.scaffoldMessengerKey;

      if (scaffoldMessengerKey?.currentState != null) {
        scaffoldMessengerKey!.currentState!.showSnackBar(
          SessionExpiredSnackBar(),
        );
      }

      final logoutBloc = serviceLocator.logoutBloc;
      if (logoutBloc != null) {
        logoutBloc.add(LogoutRequested());
      }
    }

    return response;
  }

  @override
  Future<http.Response> get(
    String endpoint, {
    bool authenticated = true,
  }) async {
    final response = await client.get(
      Uri.parse('${_getBaseUrl(endpoint: endpoint)}$endpoint'),
      headers: _getHeaders(authenticated: authenticated),
    );
    return _handleResponse(response);
  }

  @override
  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    final response = await client.post(
      Uri.parse('${_getBaseUrl(endpoint: endpoint)}$endpoint'),
      headers: _getHeaders(authenticated: authenticated),
      body: json.encode(body ?? {}),
    );
    return _handleResponse(response);
  }

  @override
  Future<http.Response> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    final response = await client.patch(
      Uri.parse('${_getBaseUrl(endpoint: endpoint)}$endpoint'),
      headers: _getHeaders(authenticated: authenticated),
      body: json.encode(body ?? {}),
    );
    return _handleResponse(response);
  }

  @override
  Future<http.Response> delete(
    String endpoint, {
    bool authenticated = true,
  }) async {
    final response = await client.delete(
      Uri.parse('${_getBaseUrl(endpoint: endpoint)}$endpoint'),
      headers: _getHeaders(authenticated: authenticated),
    );
    return _handleResponse(response);
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
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
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
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }
}
