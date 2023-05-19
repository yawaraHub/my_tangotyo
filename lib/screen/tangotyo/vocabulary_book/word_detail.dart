import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WordDetail extends StatefulWidget {
  final String bookDocId;
  final String wordDocId;
  const WordDetail({Key? key, required this.bookDocId, required this.wordDocId})
      : super(key: key);

  @override
  State<WordDetail> createState() => _WordDetailState();
}

class _WordDetailState extends State<WordDetail> {
  final _auth = FirebaseAuth.instance;
  late final User _user;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
    getWordInfo();
  }

  Map<String, dynamic> wordInfo = {}; // 空のMapで初期化

  getWordInfo() async {
    if (wordInfo.isEmpty) {
      // nullチェックを追加
      var wordInfoGet = await FirebaseFirestore.instance
          .collection('allVocabularyBooks')
          .doc(_user.uid)
          .collection('userVocabularyBooks')
          .doc(widget.bookDocId)
          .collection('words')
          .doc(widget.wordDocId)
          .get();
      wordInfo = wordInfoGet.data() ?? {}; // nullの場合も空のMapを代入
      setState(() {});
    }
  }

  Widget displayExample() {
    for (int i = 0; i < wordInfo['meanings'].length; i++) {
      if (wordInfo['meanings'][i]['example'][1].isNotEmpty) {
        return Card(
          child: ListTile(
            title: Text('例文${i + 1}'),
            subtitle: Row(
              children: [
                Column(
                  children: [
                    Text(wordInfo['meanings'][i]['example'][1]),
                    Text(wordInfo['meanings'][i]['translatedExample'][1]),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.edit),
            ),
          ),
        );
      }
    }
    ;
    return ElevatedButton(onPressed: () {}, child: const Text('例文追加'));
  }

  Widget displayComment() {
    if (wordInfo['comment'].isNotEmpty) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.speaker_notes),
          title: const Text('コメント'),
          subtitle: Text(wordInfo['comment']),
          trailing: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit),
          ),
        ),
      );
    }
    return ElevatedButton(onPressed: () {}, child: const Text('コメント追加'));
  }

  @override
  Widget build(BuildContext context) {
    if (wordInfo.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('Loading...'),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('allVocabularyBooks')
              .doc(_user.uid)
              .collection('userVocabularyBooks')
              .doc(widget.bookDocId)
              .get(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasData) {
              var bookName = snapshot.data!.get('vocabularyBookName');
              return Text(bookName);
            } else {
              return const Text('Loading...');
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              //Wordを表示
              Row(
                children: [
                  Text(wordInfo['word'][1]),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
                ],
              ),
              //意味を表示
              for (int i = 0; i < wordInfo['meanings'].length; i++) ...{
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () {},
                      child: Text(wordInfo['meanings'][i]['partOfSpeech'][1]),
                    ),
                    Text(wordInfo['meanings'][i]['meaning'][1]),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.edit),
                    ),
                  ],
                ),
              },
              //例文を表示
              displayExample(),
              //コメント表示
              displayComment(),
            ],
          ),
        ),
      ),
    );
  }
}
