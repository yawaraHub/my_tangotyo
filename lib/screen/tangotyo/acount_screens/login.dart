import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_tangotyo/screen/tangotyo/acount_screens/name_register.dart';
import 'package:my_tangotyo/screen/tangotyo/acount_screens/signin.dart';
import 'package:my_tangotyo/screen/tangotyo/vocabulary_books_list/vocabulary_books_list.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({Key? key}) : super(key: key);

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  FirebaseAuth auth = FirebaseAuth.instance;

  late String email;
  late String password;

  Future<void> LogInWithEmailAndPassword(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return VocabularyBooksList();
        }),
      );
    } catch (e) {
      print('ログインに失敗しました。エラー：$e');
    }
  }

  Future<void> registerWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuth =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuth.idToken,
          accessToken: googleSignInAuth.accessToken,
        );

        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
        // ユーザーの登録に成功した場合の処理
        User? user = userCredential.user;

        if (user != null) {
          // ユーザーが新規登録か既に登録済みかを判定
          final bool isNewUser =
              userCredential.additionalUserInfo?.isNewUser ?? false;

          if (isNewUser) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) {
                return NameRegister();
              }),
            );
          } else {
            // 既に登録済みの場合の処理
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) {
                return VocabularyBooksList();
              }),
            );
          }
        }
      }
    } catch (e) {
      // ユーザーの登録に失敗した場合のエラーハンドリング
      print('Failed to register user with Google: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log In Page'),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              width: 300,
              child: TextField(
                enabled: true,
                decoration: const InputDecoration(
                    icon: Icon(Icons.mail),
                    hintText: 'メールアドレスを入力',
                    labelText: 'Email'),
                onChanged: (value) {
                  email = value;
                },
              ),
            ),
            SizedBox(
              width: 300,
              child: TextField(
                enabled: true,
                decoration: const InputDecoration(
                    icon: Icon(Icons.password),
                    hintText: 'パスワードを入力',
                    labelText: 'Password'),
                onChanged: (value) {
                  password = value;
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                LogInWithEmailAndPassword(email, password);
              },
              child: const Text('Log In'),
            ),
            ElevatedButton(
              onPressed: () {
                registerWithGoogle();
              },
              child: const Text('Google Log In'),
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return SignInPage();
                    }),
                  );
                },
                child: const Text('Go to Sign In Page'))
          ],
        ),
      ),
    );
  }
}
