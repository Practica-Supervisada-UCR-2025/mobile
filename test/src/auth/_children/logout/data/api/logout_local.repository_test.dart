import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:mobile/src/auth/auth.dart';
import 'package:mobile/core/core.dart';

import 'logout_local.repository_test.mocks.dart';

@GenerateMocks([LocalStorage])
void main() {
  late MockLocalStorage mockLocalStorage;
  late LogoutLocalRepository logoutLocalRepository;

  setUp(() {
    mockLocalStorage = MockLocalStorage();
    logoutLocalRepository = LogoutLocalRepository(mockLocalStorage);
  });

  test('should call localStorage.clear() when logout is called', () async {
    when(mockLocalStorage.clear()).thenAnswer((_) async => Future.value());

    await logoutLocalRepository.logout();

    verify(mockLocalStorage.clear()).called(1);
  });
}
