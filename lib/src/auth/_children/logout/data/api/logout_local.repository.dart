import 'package:mobile/src/auth/_children/logout/domain/domain.dart';
import 'package:mobile/core/core.dart';

class LogoutLocalRepository implements LogoutRepository {
  final LocalStorage localStorage;

  LogoutLocalRepository(this.localStorage);

  @override
  Future<void> logout() async {
    await localStorage.clear();
  }
}
