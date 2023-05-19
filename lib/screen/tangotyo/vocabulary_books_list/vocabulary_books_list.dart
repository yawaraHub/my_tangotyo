import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_tangotyo/screen/drawer.dart';
import 'package:my_tangotyo/screen/tangotyo/vocabulary_book/vocabulary_book.dart';
import 'package:my_tangotyo/screen/tangotyo/vocabulary_book/vocabulary_book_add.dart';
import 'package:my_tangotyo/screen/tangotyo/vocabulary_books_list/flip_dialog.dart';
import 'package:my_tangotyo/screen/tangotyo/vocabulary_books_list/home_quiz_dialog.dart';

class VocabularyBooksList extends StatefulWidget {
  const VocabularyBooksList({Key? key}) : super(key: key);

  @override
  State<VocabularyBooksList> createState() => _VocabularyBooksListState();
}

class _VocabularyBooksListState extends State<VocabularyBooksList> {
  final _auth = FirebaseAuth.instance;
  late final User _user;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
  }

  final TextEditingController _searchController = TextEditingController();
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<String> getUserName() async {
    final DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(_user.uid)
        .get();
    final String userName = (snapshot.data() as Map<String, dynamic>?)?['name'];
    return userName;
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String _searchQuery = "";

  getQuizInitialValue(bookDocId) async {
    List<Map<String, dynamic>> quizData = [];
    if (quizData.isEmpty) {
      var booksInfo = await FirebaseFirestore.instance
          .collection('allVocabularyBooks')
          .doc(_user.uid)
          .collection('userVocabularyBooks')
          .doc(bookDocId)
          .collection('words')
          .get();

      quizData = booksInfo.docs.map((doc) => doc.data()).toList();
    }
    if (quizData.isNotEmpty) {
      quizSetting['kindOfProblem'] = 'word';
      quizSetting['kindOfAnswer'] = 'mM';
      quizSetting['endNumberOfQuiz'] = quizData.length.toString();
    }

    quizData.insert(0, quizSetting);
    return quizData;
  }

  Map<String, dynamic> quizSetting = {
    'numberOfQuiz': '10',
    'switchQuizCommentary': false,
    'switchExcludeErroneousQuiz': false,
    'startNumberOfQuiz': '1',
  };
  getFlipInitialValue(bookDocId) async {
    List<Map<String, dynamic>> flipData = [];
    if (flipData.isEmpty) {
      var booksInfo = await FirebaseFirestore.instance
          .collection('allVocabularyBooks')
          .doc(_user.uid)
          .collection('userVocabularyBooks')
          .doc(bookDocId)
          .collection('words')
          .get();

      flipData = booksInfo.docs.map((doc) => doc.data()).toList();
    }
    if (flipData.isNotEmpty) {
      flipSetting['endNumberOfFlip'] = flipData.length.toString();
    }

    flipData.insert(0, flipSetting);
    return flipData;
  }

  Map<String, dynamic> flipSetting = {
    'switchShuffleFlip': true,
    'switchQuizCommentary': false,
    'switchExcludeErroneousFlip': false,
    'startNumberOfFlip': '1',
    'kindOfFlip': 'ExTEx',
    'switchFrontBackFlip': true,
  };
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('単語帳'),
        ),
        drawer: const DrawerW(),
        body: SafeArea(
          child: Column(
            children: [
              //名前を表示
              FutureBuilder<String>(
                future: getUserName(),
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      return Text(snapshot.data!);
                    } else if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    } else {
                      return const Text("No Data");
                    }
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: '検索',
                ),
                onChanged: (query) {
                  // 検索文字列が変更された時の処理をここに実装する
                  setState(() {
                    _searchQuery = query;
                  });
                },
              ),
              //単語帳を表示
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('allVocabularyBooks')
                      .doc(_user.uid)
                      .collection('userVocabularyBooks')
                      .orderBy('order') // 順序でソート
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final List<DocumentSnapshot> documents =
                        snapshot.data!.docs;
                    // 検索結果をフィルタリング
                    final filteredDocuments = documents.where((document) =>
                        (document.data()
                                as Map<String, dynamic>)['vocabularyBookName']
                            .toString()
                            .contains(_searchQuery.toLowerCase()));

                    return ReorderableListView(
                      onReorder: (oldIndex, newIndex) async {
                        setState(() {
                          // ドラッグアンドドロップで項目を並べ替える処理を実装
                          // Firestoreのデータも同時に更新する必要がある
                          final draggedItem = documents.removeAt(oldIndex);
                          documents.insert(newIndex, draggedItem);
                        });
                        for (int i = 0; i < documents.length; i++) {
                          final docId = documents[i].id;
                          final updateData = {'order': i};
                          await FirebaseFirestore.instance
                              .collection('allVocabularyBooks')
                              .doc(_user.uid)
                              .collection('userVocabularyBooks')
                              .doc(docId)
                              .update(updateData);
                        }
                      },
                      children: filteredDocuments.map((document) {
                        final Map<String, dynamic>? data =
                            document.data() as Map<String, dynamic>?;
                        final vocabularyBookName =
                            data?['vocabularyBookName'] ?? '';
                        final docId = document.id;

                        return Card(
                          key: Key(vocabularyBookName),
                          child: ListTile(
                            title: Text(vocabularyBookName),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return FutureBuilder(
                                          future: getFlipInitialValue(docId),
                                          builder: (BuildContext context,
                                              AsyncSnapshot snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const CircularProgressIndicator();
                                            } else if (snapshot.hasError) {
                                              return const Text('エラーが発生しました');
                                            } else {
                                              var initialFlipSetting =
                                                  snapshot.data[0];
                                              return FlipSettingDialog(
                                                  flipSetting:
                                                      initialFlipSetting,
                                                  docId: docId);
                                            }
                                          },
                                        );
                                      },
                                    );
                                  },
                                  icon: const Icon(Icons.style),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.quiz),
                                  onPressed: () async {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return FutureBuilder(
                                          future: getQuizInitialValue(docId),
                                          builder: (BuildContext context,
                                              AsyncSnapshot snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const CircularProgressIndicator();
                                            } else if (snapshot.hasError) {
                                              return const Text('エラーが発生しました');
                                            } else {
                                              var quizSetting =
                                                  snapshot.data[0];
                                              return QuizSettingDialog(
                                                  quizSetting: quizSetting,
                                                  docId: docId);
                                            }
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    // 編集ボタンを押した時の処理
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        TextEditingController controller =
                                            TextEditingController(
                                                text: vocabularyBookName);
                                        return AlertDialog(
                                          title: const Text('単語帳名の編集'),
                                          content: TextField(
                                            controller: controller,
                                            decoration: const InputDecoration(
                                              hintText: '単語帳名を入力してください',
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              child: const Text('キャンセル'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            TextButton(
                                              child: const Text('保存'),
                                              onPressed: () async {
                                                final newName = controller.text;
                                                if (newName.isNotEmpty) {
                                                  // Firestoreのデータを更新
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection(
                                                          'allVocabularyBooks')
                                                      .doc(_user.uid)
                                                      .collection(
                                                          'userVocabularyBooks')
                                                      .doc(docId)
                                                      .update({
                                                    'vocabularyBookName':
                                                        newName
                                                  });
                                                }
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('確認'),
                                          content: Text(
                                              '本当に『$vocabularyBookName』を削除しますか?'),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text('キャンセル'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            TextButton(
                                              child: const Text('削除'),
                                              onPressed: () {
                                                //単語帳削除
                                                FirebaseFirestore.instance
                                                    .collection(
                                                        'allVocabularyBooks')
                                                    .doc(_user.uid)
                                                    .collection(
                                                        'userVocabularyBooks')
                                                    .doc(docId)
                                                    .delete();
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                            onTap: () {
                              // 単語帳の詳細画面に遷移する処理を実装
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      VocabularyBookDetail(docId: docId),
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) {
                return const VocabularyBookAdd();
              }),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
