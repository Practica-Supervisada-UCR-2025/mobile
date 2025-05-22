import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:mobile/core/core.dart';
import 'package:mobile/src/profile/profile.dart';

class EditProfileRepositoryImpl implements EditProfileRepository {
  final ApiService apiService;

  EditProfileRepositoryImpl({required this.apiService});

  @override
  Future<User> updateUserProfile(
    Map<String, dynamic> updates, {
    File? profilePicture,
  }) async {
    if (profilePicture != null) {
      return _updateWithProfilePicture(updates, profilePicture);
    }

    final response = await apiService.patch(
      '/user/auth/profile',
      body: updates,
    );

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update user profile');
    }
  }

  Future<User> _updateWithProfilePicture(
    Map<String, dynamic> updates,
    File imageFile,
  ) async {
    final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';

    final file = await http.MultipartFile.fromPath(
      'profile_picture',
      imageFile.path,
      contentType: MediaType.parse(mimeType),
    );

    final stringifiedUpdates = updates.map(
      (key, value) => MapEntry(key, value.toString()),
    );

    final response = await apiService.patchMultipart(
      '/user/auth/profile',
      stringifiedUpdates,
      [file],
    );

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update user profile: ${response.body}');
    }
  }
}
