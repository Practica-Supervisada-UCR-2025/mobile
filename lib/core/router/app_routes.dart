import 'package:go_router/go_router.dart';
import '../../src/profile/domain/domain.dart';
import 'paths.dart';
import 'router_utils.dart';
import '../../core/globals/main_scaffold.dart';
import '../../src/auth/_children/login/presenter/presenter.dart';
import '../../src/auth/_children/register/presenter/presenter.dart';
import '../../src/auth/_children/forgot-password/presenter/presenter.dart';
import '../../src/home/presenter/presenter.dart';
import '../../src/search/presenter/presenter.dart';
import '../../src/create/presenter/presenter.dart';
import '../../src/notifications/presenter/presenter.dart';
import '../../src/profile/presenter/presenter.dart';
import '../../src/settings/presenter/presenter.dart';

final List<RouteBase> appRoutes = [
  GoRoute(
    path: Paths.login,
    builder: (context, state) => const LoginPage(),
    /* BLOC
    builder: (context, state) => BlocProvider.value(
      value: _blocValue,
      child: LoginScreen(),
    ),
    */
  ),
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
        builder: (context, state) => const HomeScreen(),
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
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  ),
];
