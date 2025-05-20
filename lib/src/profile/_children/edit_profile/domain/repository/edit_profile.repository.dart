import 'dart:io';
import 'package:mobile/src/profile/profile.dart';

abstract class EditProfileRepository {
  Future<User> updateUserProfile(
    String token,
    Map<String, dynamic> updates, {
    File? profilePicture,
  });
}
