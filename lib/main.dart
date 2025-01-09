  import 'package:animated_splash_screen/animated_splash_screen.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:flutter/material.dart';
  import 'package:firebase_core/firebase_core.dart';
  import 'package:hedieaty/controllers/authentication_controller.dart';
  import 'package:hedieaty/models/model/user_model.dart';
  import 'package:hedieaty/service/firebase_notification.dart';
  import 'package:hedieaty/service/notification_service.dart';
  import 'package:hedieaty/views/widgets/local_push_notification.dart';
  import 'package:hedieaty/views/Screens/Auth/login_screen.dart';
  import 'package:hedieaty/views/widgets/bottom_navigation_bar.dart';
  import 'package:lottie/lottie.dart';
  import 'package:hedieaty/views/widgets/theming.dart';

  Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    await FirebaseNotification().initNotification();
    await NotificationService().initNotification();
    runApp(const MyApp());
  }
  class MyApp extends StatelessWidget {
    const MyApp({super.key});

    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Hedieaty',
        theme: appTheme,
        home: AnimatedSplashScreen(
          splash: Center(
            child: SizedBox(
              width: 400,
              height: 400,
              child: LottieBuilder.asset("assets/splash_animation.json"),
            ),
          ),
          splashIconSize: 400,
          nextScreen: FirebaseAuth.instance.currentUser == null
              ? const LoginScreen()
              : const MainAppEntry(),
        ),
      );
    }
  }

  class MainAppEntry extends StatelessWidget {
    const MainAppEntry({super.key});

    @override
    Widget build(BuildContext context) {
      return FutureBuilder<UserModel?>(
        future: AuthController().intiateUserAfterLogin(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return Container(
              color: Colors.white,
              child: Center(
                child: SizedBox(
                  width: 400,
                  height: 400,
                  child: LottieBuilder.asset("assets/splash_animation.json"),
                ),
              ),
            );
          }

          if (userSnapshot.hasData) {
            return LocalPushNotification(
              child: MainNavigation(user: userSnapshot.data!),
            );
          } else {
            return const LoginScreen();
          }
        },
      );
    }
  }
