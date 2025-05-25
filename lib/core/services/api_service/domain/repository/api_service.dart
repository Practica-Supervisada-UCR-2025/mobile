import 'package:http/http.dart' as http;

abstract class ApiService {
  Future<http.Response> get(String endpoint, {bool authenticated = true});

  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  });

  Future<http.Response> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  });

  Future<http.Response> delete(String endpoint, {bool authenticated = true});

  Future<http.Response> patchMultipart(
    String endpoint,
    Map<String, String> fields,
    List<http.MultipartFile> files, {
    bool authenticated = true,
  });
}
