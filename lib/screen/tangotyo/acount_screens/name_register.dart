import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_tangotyo/screen/tangotyo/vocabulary_books_list/vocabulary_books_list.dart';

class NameRegister extends StatefulWidget {
  const NameRegister({Key? key}) : super(key: key);

  @override
  State<NameRegister> createState() => _NameRegisterState();
}

class _NameRegisterState extends State<NameRegister> {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  final _auth = FirebaseAuth.instance;
  late final User _user;
  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
  }

  late String nickname;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('単語登録'),
        ),
        body: SafeArea(
          child: Center(
            child: Column(
              children: [
                Text('${_user.email}'),
                SizedBox(
                  width: 300,
                  child: TextField(
                    enabled: true,
                    decoration: const InputDecoration(
                        icon: Icon(Icons.person),
                        hintText: 'ニックネームを入力',
                        labelText: 'nickname'),
                    onChanged: (value) {
                      nickname = value;
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await usersCollection.doc(_user.uid).set({
                      'name': nickname,
                      'email': _user.email,
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return VocabularyBooksList();
                      }),
                    );
                  },
                  child: const Text('登録'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
