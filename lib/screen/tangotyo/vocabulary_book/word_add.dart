import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_tangotyo/screen/tangotyo/vocabulary_book/vocabulary_book.dart';

class WordAdd extends StatefulWidget {
  final String docId;

  const WordAdd({Key? key, required this.docId}) : super(key: key);

  @override
  State<WordAdd> createState() => _WordAddState();
}

class _WordAddState extends State<WordAdd> {
  final _auth = FirebaseAuth.instance;
  late final User _user;
  int? _order;
  @override
  void initState() {
    super.initState();
    _getUser();
  }

  _getUser() async {
    _user = _auth.currentUser!;
    await getOrder();
  }

  getOrder() async {
    int size = await FirebaseFirestore.instance
        .collection('allVocabularyBooks')
        .doc(_user.uid)
        .collection('userVocabularyBooks')
        .doc(widget.docId)
        .collection('words')
        .get()
        .then((querySnapshot) => querySnapshot.size);
    setState(() {
      _order = size;
    });
  }

  registerWordInfo(wordInfo) async {
    final userVocabularyBookWordCollection = FirebaseFirestore.instance
        .collection('allVocabularyBooks')
        .doc(_user.uid)
        .collection('userVocabularyBooks')
        .doc(widget.docId)
        .collection('words');
    await userVocabularyBookWordCollection.doc().set(wordInfo);
  }

  late String word;
  List meanings = [
    {
      'partOfSpeech': [false, '動'],
      'meaning': [false, ''],
      'example': [false, ''],
      'translatedExample': [false, ''],
    },
  ];

  List verbMeanings = [];
  List nounMeanings = [];
  List adjectiveMeanings = [];
  List adverbMeanings = [];
  List prepositionMeanings = [];
  List conjunctionMeanings = [];
  List synonyms = [];
  List antonyms = [];
  List relatedWords = [];
  List abbreviations = [];
  String comment = '';
  Map<String, dynamic> wordInfo = {};

  Widget wordMeaningWidget(meanings, i) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
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
                meanings[i]['partOfSpeech'][1] = value.toString();
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
        icon: const Icon(Icons.delete),
      ),
    ]);
  }

  createWordInfo(List meanings, String comment) {
    wordInfo['meanings'] = [];
    // 品詞ごとに意味を分ける
    if (meanings.isNotEmpty) {
      for (int i = 0; i < meanings.length; i++) {
        if (meanings[i]['meaning'].isNotEmpty) {
          wordInfo['meanings'].add(meanings[i]);
        }
      }
    }

    //Mapを作製

    wordInfo['comment'] = comment;
    wordInfo['word'] = [false, word];
    wordInfo['order'] = _order;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return VocabularyBookDetail(docId: widget.docId);
                }),
              );
            },
          ),
          title: FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('allVocabularyBooks')
                .doc(_user.uid)
                .collection('userVocabularyBooks')
                .doc(widget.docId)
                .get(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 300,
                  child: TextField(
                    enabled: true,
                    decoration: const InputDecoration(
                        hintText: '単語を入力', labelText: 'word'),
                    onChanged: (value) {
                      word = value;
                    },
                  ),
                ),
                for (int i = 0; i < meanings.length; i++) ...{
                  wordMeaningWidget(meanings, i),
                },
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      meanings.add({
                        'partOfSpeech': [false, '動'],
                        'meaning': [false, ''],
                        'example': [false, ''],
                        'translatedExample': [false, ''],
                      });
                    });
                  },
                  child: const Text('意味追加'),
                ),
                SizedBox(
                  width: 350,
                  child: TextFormField(
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
                      setState(() {
                        comment = input;
                      });
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        createWordInfo(meanings, comment);
                        registerWordInfo(wordInfo);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) {
                            return VocabularyBookDetail(docId: widget.docId);
                          }),
                        );
                      },
                      child: const Text('追加して終了'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        createWordInfo(meanings, comment);
                        registerWordInfo(wordInfo);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) {
                            return WordAdd(docId: widget.docId);
                          }),
                        );
                      },
                      child: const Text('追加して次へ'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
