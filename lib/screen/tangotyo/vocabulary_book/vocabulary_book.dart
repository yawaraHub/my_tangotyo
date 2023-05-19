import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_tangotyo/screen/drawer.dart';
import 'package:my_tangotyo/screen/tangotyo/vocabulary_book/word_add.dart';
import 'package:my_tangotyo/screen/tangotyo/vocabulary_book/word_detail.dart';
import 'package:my_tangotyo/screen/tangotyo/vocabulary_book/word_edit.dart';
import 'package:my_tangotyo/screen/tangotyo/vocabulary_books_list/vocabulary_books_list.dart';

class VocabularyBookDetail extends StatefulWidget {
  final String docId;

  const VocabularyBookDetail({super.key, required this.docId});
  @override
  State<VocabularyBookDetail> createState() => _VocabularyBookDetailState();
}

class _VocabularyBookDetailState extends State<VocabularyBookDetail> {
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
                  return const VocabularyBooksList();
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
        drawer: const DrawerW(),
        body: SafeArea(
          child: Column(
            children: [
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
              //単語を表示
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('allVocabularyBooks')
                      .doc(_user.uid)
                      .collection('userVocabularyBooks')
                      .doc(widget.docId)
                      .collection('words')
                      .orderBy('order')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.data!.docs.isEmpty) {}
                    final List<DocumentSnapshot> documents =
                        snapshot.data!.docs;
                    return ReorderableListView(
                      onReorder: (oldIndex, newIndex) async {
                        // ドラッグアンドドロップで項目を並べ替える処理を実装
                        // Firestoreのデータも同時に更新する必要がある
                        final draggedItem = documents.removeAt(oldIndex);
                        documents.insert(newIndex, draggedItem);

                        for (int i = 0; i < documents.length; i++) {
                          final docId = documents[i].id;
                          final updateData = {'order': i};
                          await FirebaseFirestore.instance
                              .collection('allVocabularyBooks')
                              .doc(_user.uid)
                              .collection('userVocabularyBooks')
                              .doc(widget.docId)
                              .collection('words')
                              .doc(docId)
                              .update(updateData);
                        }

                        // すべてのデータを Firebase Firestore に送信した後に setState() メソッドを呼び出す
                        setState(() {});
                      },
                      children: documents
                          .where((document) =>
                              (document.data() as Map<String, dynamic>)['word']
                                  .toString()
                                  .contains(_searchQuery.toLowerCase()))
                          .map((document) {
                        final Map<String, dynamic>? data =
                            document.data() as Map<String, dynamic>?;
                        final word = data?['word'][1] ?? '';
                        final docId = document.id;

                        return Card(
                          key: Key(word),
                          child: ListTile(
                            title: Text('${data?['order'] + 1}. $word'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => WordEdit(
                                          bookDocId: widget.docId,
                                          wordDocId: docId,
                                        ),
                                      ),
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
                                          content: Text('本当に『$word』を削除しますか?'),
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
                                                    .doc(widget.docId)
                                                    .collection('words')
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
                                  builder: (context) => WordDetail(
                                    bookDocId: widget.docId,
                                    wordDocId: docId,
                                  ),
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
                return WordAdd(docId: widget.docId);
              }),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
