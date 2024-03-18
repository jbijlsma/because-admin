import 'package:because_admin/my_home_page.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

// import './example_app.dart';
import './firebase_options.dart';

const becauseColor = Color.fromRGBO(91, 198, 194, 1);

const title = Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Image(
      image: AssetImage('assets/because_logo.webp'),
      height: 200,
      width: 200,
    ),
    Text(
      'Admin',
      style: TextStyle(color: Colors.white, fontSize: 22),
    )
  ],
);

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final providers = [EmailAuthProvider()];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Because Admin',
      initialRoute:
          FirebaseAuth.instance.currentUser == null ? '/sign-in' : '/profile',
      routes: {
        '/sign-in': (context) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: becauseColor,
              title: title,
            ),
            body: SignInScreen(
              providers: providers,
              showAuthActionSwitch: false,
              actions: [
                AuthStateChangeAction<SignedIn>((context, state) {
                  Navigator.pushReplacementNamed(context, '/profile');
                }),
              ],
            ),
          );
        },
        '/profile': (context) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: becauseColor,
              title: title,
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.logout,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();

                    if (!context.mounted) return;
                    Navigator.of(context).pushReplacementNamed('/sign-in');
                  },
                )
              ],
            ),
            body: const MyHomePage(),
          );
        },
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: becauseColor),
        useMaterial3: true,
      ),
    );
  }
}
