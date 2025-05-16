import 'dart:io';

import 'package:mobile/src/profile/domain/models/user.dart';

abstract class ProfileRepository {
  Future<User> getCurrentUser(String token);

  Future<User> updateUserProfile(
    String token,
    Map<String, dynamic> updates, {
    File? profilePicture,
  });
}
