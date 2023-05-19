import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../vocabulary_books_list/vocabulary_books_list.dart';

class VocabularyBookAdd extends StatefulWidget {
  const VocabularyBookAdd({Key? key}) : super(key: key);

  @override
  State<VocabularyBookAdd> createState() => _VocabularyBookAddState();
}

class _VocabularyBookAddState extends State<VocabularyBookAdd> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  late String vocabularyBookName;
  int? _order;
  @override
  void initState() {
    super.initState();
    getOrder();
  }

  getOrder() async {
    int size = await FirebaseFirestore.instance
        .collection('allVocabularyBooks')
        .doc(uid)
        .collection('userVocabularyBooks')
        .get()
        .then((querySnapshot) => querySnapshot.size);
    setState(() {
      _order = size;
    });
  }

  registerVocabularyBook(String vocabularyBookName) async {
    final CollectionReference userVocabularyBooksCollection = FirebaseFirestore
        .instance
        .collection('allVocabularyBooks/$uid/userVocabularyBooks');
    await userVocabularyBooksCollection.doc().set({
      'vocabularyBookName': vocabularyBookName,
      'order': _order,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('単語帳追加'),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              SizedBox(
                height: 100,
              ),
              SizedBox(
                width: 300,
                child: TextField(
                  enabled: true,
                  decoration: const InputDecoration(
                      icon: Icon(Icons.book),
                      hintText: '単語帳名を入力',
                      labelText: '単語帳名'),
                  onChanged: (value) {
                    vocabularyBookName = value;
                  },
                ),
              ),
              SizedBox(
                height: 30,
              ),
              ElevatedButton(
                onPressed: () {
                  registerVocabularyBook(vocabularyBookName);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return const VocabularyBooksList();
                    }),
                  );
                },
                child: const Text('単語帳を登録'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
