import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_tangotyo/screen/tangotyo/acount_screens/login.dart';
import 'package:my_tangotyo/screen/tangotyo/vocabulary_books_list/vocabulary_books_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: AuthChecker(),
    );
  }
}

class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  _AuthCheckerState createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    if (user != null) {
      // ログイン済みの場合は、ログイン後のウィジェットを表示する
      return VocabularyBooksList();
    } else {
      // 未ログインの場合は、ログイン前のウィジェットを表示する
      return LogInPage();
    }
  }
}
