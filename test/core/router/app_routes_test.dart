import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/router/app_routes.dart';
import 'package:mobile/core/router/paths.dart';
import 'package:mobile/src/profile/presenter/page/page.dart';
import 'package:mobile/src/profile/presenter/bloc/profile_bloc.dart';
import 'package:mobile/src/profile/domain/models/models.dart';
import 'package:mobile/src/profile/domain/repository/repository.dart';
import 'package:mobile/core/globals/publications/publications.dart';


class FakeProfileRepository implements ProfileRepository {
  @override
  Future<User> getCurrentUser(String token) async {
    return User(
      firstName: 'Test',
      lastName: 'User',
      username: 'testuser',
      email: 'test@example.com',
      image: 'https://example.com/avatar.png',
    );
  }
  
  @override
  Future<User> getUserProfile(String userId, String? token) {
    // Todo: implement getUserProfile
    throw UnimplementedError();
  }
}

void main() {
  testWidgets(
    'Profile route builds PublicationRepositoryAPI & PublicationBloc, then emits PublicationFailure',
    (WidgetTester tester) async {
      final router = GoRouter(routes: appRoutes);

      await tester.pumpWidget(
        BlocProvider<ProfileBloc>(
          create: (_) => ProfileBloc(
            profileRepository: FakeProfileRepository(),
          )..add(ProfileLoad()),
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      router.go(Paths.profile);
      await tester.pumpAndSettle();

      expect(find.byType(ProfileScreen), findsOneWidget);

      expect(
        find.byType(RepositoryProvider<PublicationRepository>),
        findsOneWidget,
      );

      expect(
        find.byType(BlocProvider<PublicationBloc>),
        findsOneWidget,
      );

      final ctx = tester.element(find.byType(ProfileScreen));

      final repo = ctx.read<PublicationRepository>();
      expect(repo, isA<PublicationRepositoryAPI>());

      final pubBloc = ctx.read<PublicationBloc>();
      expect(pubBloc, isA<PublicationBloc>());

      await tester.pump();

      expect(pubBloc.state, isA<PublicationFailure>());
    },
  );
}
