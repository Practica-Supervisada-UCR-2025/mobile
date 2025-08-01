import 'package:mobile/src/profile/domain/models/user.dart';

abstract class ProfileRepository {
  Future<User> getCurrentUser(String token);

  Future<User> getUserProfile(String userId, String? token);
}
