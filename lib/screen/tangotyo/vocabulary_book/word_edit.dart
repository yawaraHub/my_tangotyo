import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WordEdit extends StatefulWidget {
  final String bookDocId;
  final String wordDocId;
  const WordEdit({Key? key, required this.bookDocId, required this.wordDocId})
      : super(key: key);

  @override
  State<WordEdit> createState() => _WordEditState();
}

class _WordEditState extends State<WordEdit> {
  final _auth = FirebaseAuth.instance;
  late final User _user;

  @override
  void initState() {
    super.initState();
    _getUser();
    getWordInfo();
  }

  _getUser() {
    _user = _auth.currentUser!;
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

  Widget wordMeaningWidget(meanings, i) {
    return Card(
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Column(
          children: [
            DropdownButton(
              items: const [
                DropdownMenuItem(value: '動', child: Text('動詞')),
                DropdownMenuItem(value: '名', child: Text('名詞')),
                DropdownMenuItem(value: '形', child: Text('形容詞')),
                DropdownMenuItem(value: '副', child: Text('副詞')),
                DropdownMenuItem(value: '前', child: Text('前置詞')),
                DropdownMenuItem(value: '接', child: Text('接続詞')),
              ],
              value: meanings[i]['partOfSpeech'][1],
              onChanged: (value) {
                setState(() {
                  meanings[i]['partOfSpeech'][1] = value;
                });
              },
            ),
          ],
        ),
        Column(
          children: [
            SizedBox(
              width: 200,
              child: TextField(
                textInputAction: TextInputAction.next,
                controller: TextEditingController.fromValue(
                  TextEditingValue(
                    text: meanings[i]['meaning'][1],
                    selection: TextSelection.collapsed(
                        offset: meanings[i]['meaning'][1].length),
                  ),
                ),
                enabled: true,
                decoration: const InputDecoration(
                    hintText: '単語訳を入力', labelText: 'translated meaning'),
                onChanged: (value) {
                  print(meanings);
                  meanings[i]['meaning'][1] = value.toString();
                },
              ),
            ),
            SizedBox(
              width: 200,
              child: TextField(
                textInputAction: TextInputAction.next,
                controller: TextEditingController.fromValue(
                  TextEditingValue(
                    text: meanings[i]['example'][1],
                    selection: TextSelection.collapsed(
                        offset: meanings[i]['example'][1].length),
                  ),
                ),
                enabled: true,
                decoration: const InputDecoration(
                    hintText: '例文を入力', labelText: 'example'),
                onChanged: (value) {
                  print(meanings);
                  meanings[i]['example'][1] = value.toString();
                },
              ),
            ),
            SizedBox(
              width: 200,
              child: TextField(
                textInputAction: TextInputAction.next,
                controller: TextEditingController.fromValue(
                  TextEditingValue(
                    text: meanings[i]['translatedExample'][1],
                    selection: TextSelection.collapsed(
                        offset: meanings[i]['translatedExample'][1].length),
                  ),
                ),
                enabled: true,
                decoration: const InputDecoration(
                    hintText: '例文訳を入力', labelText: 'translate example'),
                onChanged: (value) {
                  print(meanings);
                  meanings[i]['translatedExample'][1] = value.toString();
                },
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () {
            setState(() {
              if (meanings.length != 1) {
                meanings.removeAt(i);
              }
            });
          },
          icon: Icon(Icons.delete),
        ),
      ]),
    );
  }

  reRegisterWordInfo(wordInfo) async {
    final userVocabularyBookWordDoc = FirebaseFirestore.instance
        .collection('allVocabularyBooks')
        .doc(_user.uid)
        .collection('userVocabularyBooks')
        .doc(widget.bookDocId)
        .collection('words')
        .doc(widget.wordDocId);
    for (int i = 0; i < wordInfo['meanings'].length; i++) {
      if (wordInfo['meanings'][i]['meaning'].isEmpty) {
        wordInfo['meanings'].removeAt(i);
      }
    }
    await userVocabularyBookWordDoc.update(wordInfo);
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
              return Text('Loading...');
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                width: 300,
                child: TextField(
                  controller: TextEditingController.fromValue(
                    TextEditingValue(
                      text: wordInfo['word'][1],
                      selection: TextSelection.collapsed(
                          offset: wordInfo['word'][1].length),
                    ),
                  ),
                  enabled: true,
                  decoration: const InputDecoration(
                      hintText: '単語を入力', labelText: 'word'),
                  onChanged: (value) {
                    wordInfo['word'][1] = value;
                  },
                ),
              ),
              for (int i = 0; i < wordInfo['meanings'].length; i++) ...{
                wordMeaningWidget(wordInfo['meanings'], i)
              },
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    wordInfo['meanings'].add({
                      'meaning': [false, ''],
                      'partOfSpeech': [false, '動'],
                      'example': [false, ''],
                      'translatedExample': [false, ''],
                    });
                    print(wordInfo['meanings']);
                  });
                },
                child: Text('追加'),
              ),
              SizedBox(
                width: 350,
                child: TextFormField(
                  controller: TextEditingController.fromValue(
                    TextEditingValue(
                      text: wordInfo['comment'] ?? '',
                      selection: TextSelection.collapsed(
                          offset: (wordInfo['comment'] ?? '').length),
                    ),
                  ),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: "\n\n\n\n\n\n\n",
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        width: 1.0,
                      ),
                    ),
                  ),
                  onChanged: (input) {
                    wordInfo['comment'] = input;
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  reRegisterWordInfo(wordInfo);
                },
                child: Text('編集完了'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
