import 'dart:io';
import 'package:mobile/src/profile/profile.dart';

abstract class EditProfileRepository {
  Future<User> updateUserProfile(
    Map<String, dynamic> updates, {
    File? profilePicture,
  });
}
