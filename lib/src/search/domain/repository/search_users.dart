import 'package:mobile/src/search/search.dart';

abstract class SearchUsersRepository {
  Future<List<UserModel>> searchUsers(String name);
}
