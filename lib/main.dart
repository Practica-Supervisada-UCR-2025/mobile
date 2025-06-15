import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mobile/core/services/notifications_service/domain/repository/notifications_handler.dart';
import 'package:mobile/src/auth/auth.dart';
import 'package:mobile/src/profile/profile.dart';
import 'package:mobile/src/search/search.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'src/create/create.dart';
import 'package:mobile/src/auth/_children/_children.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/core.dart';
import 'firebase_options.dart';
import 'core/services/notifications_service/data/api/notifications_handler_impl.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:mobile/src/comments/comments.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await LocalStorage.init();
  await dotenv.load(fileName: ".env");

  final NotificationHandler notificationHandler = NotificationHandlerImpl(
    flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
    firebaseMessaging: FirebaseMessaging.instance,
  );

  await notificationHandler.initialize();

  const isRelease = bool.fromEnvironment('dart.vm.product');

  final packageInfo = await PackageInfo.fromPlatform();
  final releaseVersion =
      'ucr-connect@${packageInfo.version}+${packageInfo.buildNumber}';

  await SentryFlutter.init((options) {
    options.dsn = dotenv.env['SENTRY_DSN'];
    options.sendDefaultPii = true;
    options.environment = isRelease ? 'production' : 'debug';
    options.release = releaseVersion;
  }, appRunner: () => runApp(SentryWidget(child: MyApp())));
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
          create:
              (_) => PermissionsRepositoryImpl(
                permissionService: PermissionServiceImpl(),
              ),
        ),
        RepositoryProvider<ProfileRepository>(
          create: (context) => ProfileRepositoryAPI(),
        ),
        ChangeNotifierProvider<RouterRefreshNotifier>(
          create: (_) => RouterRefreshNotifier(),
        ),
        RepositoryProvider<ApiService>(create: (_) => ApiServiceImpl()),

        RepositoryProvider<EditProfileRepository>(
          create:
              (context) => EditProfileRepositoryImpl(
                apiService: context.read<ApiService>(),
              ),
        ),
        RepositoryProvider<CreatePostRepository>(
          create:
              (context) => CreatePostRepositoryImpl(
                apiService: context.read<ApiService>(),
              ),
        ),

        RepositoryProvider<FCMService>(
          create:
              (context) => FCMServiceImpl(
                localStorage: LocalStorage(),
                apiService: context.read<ApiService>(),
              ),
        ),
        RepositoryProvider<NotificationsService>(
          create:
              (context) => NotificationsServiceImpl(
                permissionsRepository: context.read<PermissionsRepository>(),
                fcmService: context.read<FCMService>(),
                localStorage: LocalStorage(),
              ),
        ),
        RepositoryProvider<MediaPickerRepository>(
          create: (_) => MediaPickerRepositoryImpl(),
        ),
        RepositoryProvider<SearchUsersRepository>(
          create:
              (_) => SearchUsersRepositoryImpl(apiService: ApiServiceImpl()),
        ),
        RepositoryProvider<CommentsRepository>(
          create:
              (context) => CommentsRepositoryImpl(
                apiService: context.read<ApiService>(),
              ),
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
                  notificationsService: context.read<NotificationsService>(),
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
            create:
                (context) => CreatePostBloc(
                  createPostRepository: context.read<CreatePostRepository>(),
                ),
          ),
          BlocProvider<EditProfileBloc>(
            create:
                (context) => EditProfileBloc(
                  editProfileRepository: context.read<EditProfileRepository>(),
                ),
          ),
          BlocProvider<SearchBloc>(
            create:
                (context) => SearchBloc(
                  searchUsersRepository: context.read<SearchUsersRepository>(),
                ),
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
