import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/core.dart';
import 'package:mobile/src/comments/presenter/page/comments_page.dart';
import 'package:mobile/src/profile/_children/_children.dart';
import 'package:mobile/src/search/presenter/page/page.dart';
import '../../src/profile/domain/domain.dart';
import '../../core/globals/main_scaffold.dart';
import '../../src/auth/_children/login/presenter/presenter.dart';
import '../../src/auth/_children/register/presenter/presenter.dart';
import '../../src/auth/_children/forgot-password/presenter/presenter.dart';
import '../../src/home/presenter/presenter.dart';
import '../../src/create/presenter/presenter.dart';
import '../../src/notifications/presenter/presenter.dart';
import '../../src/profile/presenter/presenter.dart';
import '../../src/settings/presenter/presenter.dart';

final List<RouteBase> appRoutes = [
  GoRoute(path: Paths.login, builder: (context, state) => const LoginPage()),
  GoRoute(
    path: Paths.register,
    builder: (context, state) => const RegisterPage(),
  ),
  GoRoute(
    path: Paths.settings,
    builder: (context, state) => const SettingsScreen(),
  ),
  GoRoute(
    path: Paths.editProfile,
    builder: (context, state) {
      final user = state.extra as User;
      return ProfileEditPage(user: user);
    },
  ),
  GoRoute(
    path: Paths.forgot_password,
    builder: (context, state) => const ForgotPasswordPage(),
  ),
  GoRoute(path: Paths.create, builder: (context, state) => const CreatePage()),
  ShellRoute(
    builder: (context, state, child) {
      final index = getIndexFromLocation(state.uri.toString());
      return MainScaffold(currentIndex: index, child: child);
    },
    routes: [
      GoRoute(
        path: Paths.home,
        builder: (context, state) {
          //final isFeed = state.extra as bool? ?? false;
          return RepositoryProvider<PublicationRepository>(
            create: (context) => PublicationRepositoryAPI(
              endpoint: ENDPOINT_FEED_PUBLICATIONS,
            ),
            child: BlocProvider<PublicationBloc>(
              create: (context) {
                final bloc = PublicationBloc(
                  publicationRepository: context.read<PublicationRepository>(),
                );
                bloc.add(LoadPublications(isFeed: true));
                bloc.add(LoadMorePublications(isFeed: true));
                return bloc;
              },
              child: const HomeScreen(isFeed: true),
            ),
          );
        },
      ),
      GoRoute(
        path: Paths.comments,
        builder: (context, state) {
          final publication = state.extra as Publication;
          return CommentsPage(publication: publication);
        },
      ),
      GoRoute(
        path: Paths.search,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: Paths.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: Paths.profile,
        builder: (context, state) {
          return RepositoryProvider<PublicationRepository>(
            create:
                (context) => PublicationRepositoryAPI(
                  endpoint: ENDPOINT_OWN_PUBLICATIONS,
                ),
            child: BlocProvider<PublicationBloc>(
              create:
                  (context) => PublicationBloc(
                    publicationRepository:
                        context.read<PublicationRepository>(),
                  )..add(LoadPublications()),
              child: const ProfileScreen(isFeed: false),
            ),
          );
        },
      ),
      GoRoute(
        path: Paths.externProfile(':userId'),
        builder: (context, state) {
          final userId = state.pathParameters['userId'];
          return ProfileScreen(userId: userId, isFeed: true);
        },
      ),
    ],
  ),
];
