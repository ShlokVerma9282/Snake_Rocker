import 'package:flutter/material.dart';
import 'package:snake_ocker/Home_page.dart';
import 'package:firebase_core/firebase_core.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: "AIzaSyCnm4GTYAtugc_r7ICpJ9fqXSqISPuA8fg",
        authDomain: "snake-rock.firebaseapp.com",
        projectId: "snake-rock",
        storageBucket: "snake-rock.appspot.com",
        messagingSenderId: "891052581250",
        appId: "1:891052581250:web:d22f5161765de99e066f9b",
        measurementId: "G-J3BDY84ZEB"
    )
  );
  runApp(const MyApp());

}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
