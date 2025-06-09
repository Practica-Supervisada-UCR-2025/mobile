import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mobile/src/auth/auth.dart';
import 'package:mobile/src/profile/profile.dart';
import 'src/create/create.dart';
import 'package:mobile/src/auth/_children/_children.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/core.dart';
import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // This method will be called when the app is in the background or terminated
  //  handle the message here if needed.
  print('🔔 Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await LocalStorage.init();
  await dotenv.load(fileName: ".env");
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // todo: Delete this when the notification ui is implemented
    print('📩 Notification received');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = navigatorKey.currentContext;
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${message.notification?.title ?? 'Notificación'}: ${message.notification?.body ?? ''}',
            ),
            duration: Duration(seconds: 3),
          ),
        );
      }
    });
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('🔔 The user opened the app from a notification');
  });

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
        RepositoryProvider<PublicationRepository>(
          create: (context) => PublicationRepositoryAPI(),
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
          BlocProvider<PublicationBloc>(
            create:
                (context) => PublicationBloc(
                  publicationRepository: context.read<PublicationRepository>(),
                )..add(LoadPublications()),
          ),
          BlocProvider<EditProfileBloc>(
            create:
                (context) => EditProfileBloc(
                  editProfileRepository: context.read<EditProfileRepository>(),
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
