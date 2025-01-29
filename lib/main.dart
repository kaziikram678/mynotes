import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/firebase_options.dart';
import 'package:mynotes/views/login_view.dart';
import 'package:mynotes/views/register_view.dart';
import 'package:mynotes/views/verify_email.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized;
  //WidgetsFlutterBinding();
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: const Homepage(),
    routes: {
      '/login/': (context) => const LoginView(),
      '/register/': (context) => const RegisterView()
    },
  ));
}

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final user = FirebaseAuth.instance.currentUser;

          if (user != null) {
            if (user.emailVerified) {
              // Email is verified, navigate to the main screen
              return const Text('Email is Verified'); // Replace with your main screen widget
            } else {
              // Email is not verified, show the VerifyEmailView
              return const VerifyEmailView();
            }
          } else {
            // No user is logged in, show the LoginView
            return const LoginView();
          }
        } else {
          // Firebase is still initializing, show a loading indicator
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
