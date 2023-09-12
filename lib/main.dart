import 'package:flutter/material.dart';

import 'home_page.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

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
    //Record User Data
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final databaseReference = FirebaseDatabase.instance.ref();
      final userRef = databaseReference.child("users").child(user.uid);

      // Check if user exists in the database
      userRef.once().then((DatabaseEvent event) {
        DataSnapshot snapshot = event.snapshot;
        if (snapshot.value != null) {
          Map<String, dynamic> userData =
              snapshot.value as Map<String, dynamic>;
          // User exists, increment login counter
          int currentCount = userData['loginCount'] ?? 0;
          userRef.update({'loginCount': currentCount + 1});
        } else {
          // User doesn't exist, set login counter to 1
          userRef.set({'loginCount': 1, 'email': user.email});
        }
      });
    }

    final providers = [EmailAuthProvider()];
    return MaterialApp(
      title: 'Dylans Random Chess Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute:
          FirebaseAuth.instance.currentUser == null ? '/sign-in' : '/profile',
      routes: {
        '/sign-in': (context) {
          return SignInScreen(
            providers: providers,
            actions: [
              AuthStateChangeAction<SignedIn>((context, state) {
                Navigator.pushReplacementNamed(context, '/profile');
              }),
            ],
          );
        },
        '/profile': (context) => ProfileScreen(providers: providers),
        '/home': (context) => HomePage(),
      },
    );
  }
}

class ProfileScreen extends StatelessWidget {
  final List<AuthProvider> providers;

  ProfileScreen({required this.providers});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Logged in as: ${user?.email}'),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/sign-in');
              },
              child: Text("Sign Out"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(
                    context, '/home'); // Navigate to HomePage
              },
              child: Text("Play Chess"),
            ),
          ],
        ),
      ),
    );
  }
}
