import 'dart:io' show Platform;

import 'package:camera_ai/main_page.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:firebase_ui_oauth_apple/firebase_ui_oauth_apple.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseUIAuth.configureProviders([
    EmailAuthProvider(),
    GoogleProvider(
      clientId:
          (Platform.isIOS || Platform.isMacOS) ?
          "87900953374-lvcc3r9298bsffdi0kdtubedu2r8frpg.apps.googleusercontent.com" :
          '87900953374-sehcf8lujuioo7uufcfvo5saeobm9uph.apps.googleusercontent.com',
    ),
    AppleProvider(),
  ]);

  runApp(const RootApp());
}

class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute:
          FirebaseAuth.instance.currentUser == null ? '/sign-in' : '/',
      routes: {
        '/sign-in': (context) {
          return SignInScreen(
            actions: [
              AuthStateChangeAction<SignedIn>((context, state) {
                Navigator.pushReplacementNamed(context, '/');
              }),
            ],
          );
        },
        '/profile': (context) {
          return ProfileScreen(
            appBar: AppBar(
              title: const Text('Profile'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.exit_to_app),
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushReplacementNamed(context, '/sign-in');
                  },
                ),
              ],
            ),
            actions: [
              SignedOutAction((context) {
                Navigator.pushReplacementNamed(context, '/sign-in');
              }),
            ],
          );
        },
        '/': (context) => const CameraPage(),
        '/error': (context) =>
            const Scaffold(body: Center(child: Text('Error'))),
        '/loading': (context) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      },
    );
  }
}
