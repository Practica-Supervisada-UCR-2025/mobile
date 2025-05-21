import 'dart:convert';
import 'dart:io';
import 'package:mobile/core/core.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mobile/src/profile/profile.dart';
import 'package:mime/mime.dart';

class EditProfileRepositoryImpl implements EditProfileRepository {
  final http.Client client;
  final String token = LocalStorage().accessToken;

  EditProfileRepositoryImpl({http.Client? client})
    : client = client ?? http.Client();

  @override
  Future<User> updateUserProfile(
    Map<String, dynamic> updates, {
    File? profilePicture,
  }) async {
    // If there's a profile picture to upload, use multipart/form-data request
    if (profilePicture != null) {
      return _updateWithProfilePicture(updates, profilePicture);
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
    Map<String, dynamic> updates,
    File imageFile,
  ) async {
    final uri = Uri.parse('$API_BASE_URL/user/auth/profile');
    final request = http.MultipartRequest('PATCH', uri);

    request.headers['Authorization'] = 'Bearer $token';

    updates.forEach((key, value) {
      if (value != null) {
        request.fields[key] = value.toString();
      }
    });

    final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';

    request.files.add(
      await http.MultipartFile.fromPath(
        'profile_picture',
        imageFile.path,
        contentType: MediaType.parse(mimeType),
      ),
    );

    final streamedResponse = await client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update user profile: ${response.body}');
    }
  }
}
