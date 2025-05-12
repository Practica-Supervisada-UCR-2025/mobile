import 'package:flutter/material.dart';
import 'package:mobile/src/auth/auth.dart';
import 'package:mobile/src/profile/profile.dart';
import 'src/create/create.dart';
import 'package:mobile/src/auth/_children/_children.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await LocalStorage.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<RegisterRepository>(
          create: (context) => RegisterRepositoryFirebase(),
        ),
        RepositoryProvider<LoginRepository>(
          create: (context) => LoginRepositoryFirebase(),
        ),
        RepositoryProvider<LogoutRepository>(
          create: (_) => LogoutLocalRepository(LocalStorage()),
        ),
        RepositoryProvider<PermissionsRepository>(
          create: (_) => PermissionsRepositoryImpl(),
        ),
        RepositoryProvider<ProfileRepository>(
          create: (context) => ProfileRepositoryAPI(),
        ),
        ChangeNotifierProvider<RouterRefreshNotifier>(
          create: (_) => RouterRefreshNotifier(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<RegisterBloc>(
            create:
                (context) => RegisterBloc(
                  registerRepository: context.read<RegisterRepository>(),
                  registerAPIRepository: RegisterAPIRepository(),
                ),
          ),
          BlocProvider<LoginBloc>(
            create:
                (context) => LoginBloc(
                  loginRepository: context.read<LoginRepository>(),
                  localStorage: LocalStorage(),
                  tokensRepository: TokensRepositoryAPI(),
                ),
          ),
          BlocProvider<LogoutBloc>(
            create:
                (context) => LogoutBloc(
                  logoutRepository: context.read<LogoutRepository>(),
                ),
          ),
          BlocProvider<ProfileBloc>(
            create:
                (context) => ProfileBloc(
                  profileRepository: context.read<ProfileRepository>(),
                ),
          ),
          BlocProvider<CreatePostBloc>(
            create: (context) => CreatePostBloc(),
          ),
        ],
        child: Builder(
          builder: (context) {
            final notifier = context.read<RouterRefreshNotifier>();
            context.read<LoginBloc>().stream.listen((state) {
              notifier.refresh();
            });
            return MaterialApp.router(
              title: 'UCR Connect',
              themeMode: ThemeMode.system,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              routerConfig: createRouter(context),
            );
          },
        ),
      ),
    );
  }
}
