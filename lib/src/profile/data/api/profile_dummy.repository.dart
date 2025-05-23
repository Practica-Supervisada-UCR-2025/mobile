import 'dart:convert';
import 'dart:io';
import 'package:mobile/core/core.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mobile/src/profile/profile.dart';
import 'package:mime/mime.dart';

class ProfileRepositoryAPI implements ProfileRepository {
  final http.Client client;

  ProfileRepositoryAPI({http.Client? client})
    : client = client ?? http.Client();

  @override
  Future<User> getCurrentUser(String token) async {
    try {
      final response = await client.get(
        Uri.parse('$API_BASE_URL/user/auth/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        User user = User.fromJson(data);
        LocalStorage localStorage = LocalStorage();
        localStorage.userProfilePicture = user.image;
        return user;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to load user');
      }
    } catch (e) {
      throw Exception('Error getting user profile: $e');
    }
  }

  @override
  Future<User> updateUserProfile(
    String token,
    Map<String, dynamic> updates, {
    File? profilePicture,
  }) async {
    // If there's a profile picture to upload, use multipart/form-data request
    if (profilePicture != null) {
      return _updateWithProfilePicture(token, updates, profilePicture);
    }

    final response = await client.patch(
      Uri.parse('$API_BASE_URL/user/auth/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(updates),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception('Failed to update user profile');
    }
  }

  Future<User> _updateWithProfilePicture(
    String token,
    Map<String, dynamic> updates,
    File imageFile,
  ) async {
    // Check file size (max 4MB)
    final fileSize = await imageFile.length();
    if (fileSize > 4 * 1024 * 1024) {
      throw Exception('Image size exceeds 4MB limit');
    }

    // Create multipart request
    final request = http.MultipartRequest(
      'PATCH',
      Uri.parse('$API_BASE_URL/user/auth/profile'),
    );

    // Set headers
    request.headers['Authorization'] = 'Bearer $token';

    // Add text fields for profile updates
    updates.forEach((key, value) {
      if (value != null) {
        request.fields[key] = value.toString();
      }
    });

    // Detect mime type
    final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';

    // Add file to request with correct field name
    request.files.add(
      await http.MultipartFile.fromPath(
        'profile_picture',
        imageFile.path,
        contentType: MediaType.parse(mimeType),
      ),
    );

    // Send request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception('Failed to update user profile: ${response.body}');
    }
  }
}
