import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_tangotyo/screen/tangotyo/vocabulary_books_list/vocabulary_books_list.dart';

class FlipCard extends StatefulWidget {
  final Map flipSetting;
  final String docId;

  const FlipCard({super.key, required this.flipSetting, required this.docId});

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard> {
  final _auth = FirebaseAuth.instance;
  late final User _user;
  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
    getVocabularyBookInfo();
  }

  List vocabularyBookWords = [];
  getVocabularyBookInfo() async {
    if (vocabularyBookWords.isEmpty) {
      // nullチェックを追加
      await FirebaseFirestore.instance
          .collection('allVocabularyBooks')
          .doc(_user.uid)
          .collection('userVocabularyBooks')
          .doc(widget.docId)
          .collection('words')
          .orderBy('order')
          .get()
          .then((QuerySnapshot querySnapshot) {
        for (var doc in querySnapshot.docs) {
          // ドキュメントデータの処理
          vocabularyBookWords.add(doc.data());
        }
        createFlipDataList(vocabularyBookWords);
      }); // nullの場合も空のMapを代入
      setState(() {});
    }
  }

  List flipList = [];
  //TODO これをクラスにして単語と意味、例文と例文訳で分けて作れるようにする。
  createFlipDataList(List vocabularyBookWords) {
    flipList = vocabularyBookWords.sublist(
        int.parse(widget.flipSetting['startNumberOfFlip']) - 1,
        int.parse(widget.flipSetting['endNumberOfFlip']));
    if (widget.flipSetting['kindOfFlip'] == 'ExTEx') {
      flipList = exTExFlipListFirst(flipList);
    } else if (widget.flipSetting['kindOfFlip'] == 'MeTMe') {
      flipList = meTMeFlipListFirst(flipList);
    }
    if (widget.flipSetting['switchShuffleFlip']) {
      flipList.shuffle();
    }
  }

  exTExFlipListFirst(List originalData) {
    List newBox = [];
    for (int i = 0; i < originalData.length; i++) {
      for (int j = 0; j < originalData[i]['meanings'].length; j++) {
        if (originalData[i]['meanings'][j]['example'][1].isNotEmpty &&
            originalData[i]['meanings'][j]['translatedExample'][1].isNotEmpty) {
          originalData[i]['ExNum'] = j;
          newBox.add(originalData[i]);
        }
      }
    }
    if (widget.flipSetting['switchExcludeErroneousFlip']) {
      newBox.removeWhere((map) {
        // マップの'meanings'キーの値がリストであるか確認
        if (map['meanings'] is List) {
          // リスト内の各要素をチェック
          for (var meaning in map['meanings']) {
            // マップの'example'キーが存在し、値がtrueである場合、要素を削除
            if (meaning['example'] != null && meaning['example'][0] == true) {
              return true; // 要素を削除する
            }
          }
        }
        return false;
      });
    }
    return newBox;
  }

  meTMeFlipListFirst(List originalData) {
    List newBox = originalData;
    if (widget.flipSetting['switchExcludeErroneousFlip']) {
      newBox.removeWhere((item) => item['word'][0] == true);
    }
    return newBox;
  }

  judgeFlipFinish(currentFlipIndex) {
    if (flipList.isEmpty) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const Text('知らないFlipはありませんでした。'),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return const VocabularyBooksList();
                      }),
                    );
                  },
                  child: const Text('HOME'))
            ],
          ),
        ),
      );
    }
    if (currentFlipIndex < flipList.length) {
      String flipFront = '';
      String flipBack = '';
      if (widget.flipSetting['kindOfFlip'] == 'ExTEx') {
        flipFront = flipList[currentFlipIndex]['meanings']
            [flipList[currentFlipIndex]['ExNum']]['example'][1];
        flipBack = flipList[currentFlipIndex]['meanings']
            [flipList[currentFlipIndex]['ExNum']]['translatedExample'][1];
      } else if (widget.flipSetting['kindOfFlip'] == 'MeTMe') {
        flipFront = flipList[currentFlipIndex]['word'][1];
        flipBack = flipList[currentFlipIndex]['meanings']
            .map((meaning) => meaning['meaning'][1])
            .join(',');
      }
      if (widget.flipSetting['switchFrontBackFlip']) {
        return createFlipWidget(flipFront, flipBack);
      } else {
        return createFlipWidget(flipBack, flipFront);
      }
    } else {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return const VocabularyBooksList();
                      }),
                    );
                  },
                  child: const Text('終了'),
                ),
                const SizedBox(
                  height: 100,
                )
              ],
            ),
          ),
        ),
      );
    }
  }

  reApplyTrueOrFalse(bool tOrf) async {
    if (widget.flipSetting['kindOfFlip'] == 'ExTEx') {
      await FirebaseFirestore.instance
          .collection('allVocabularyBooks')
          .doc(_user.uid)
          .collection('userVocabularyBooks')
          .doc(widget.docId)
          .collection('words')
          .get()
          .then(
        (querySnapshot) {
          for (var doc in querySnapshot.docs) {
            if (flipList[currentFlipIndex]['word'][1] == doc.get('word')[1]) {
              var docReference = doc.reference;
              var exNum = flipList[currentFlipIndex]['ExNum'];
              flipList[currentFlipIndex]['meanings'][exNum]['example'][0] =
                  tOrf;
              flipList[currentFlipIndex]['meanings'][exNum]['translatedExample']
                  [0] = tOrf;
              // ドキュメントを更新する
              docReference
                  .update({'meanings': flipList[currentFlipIndex]['meanings']});
            }
          }

          setState(() {
            currentFlipIndex++;
            isFront = true;
          });
        },
      );
    } else if (widget.flipSetting['kindOfFlip'] == 'MeTMe') {
      await FirebaseFirestore.instance
          .collection('allVocabularyBooks')
          .doc(_user.uid)
          .collection('userVocabularyBooks')
          .doc(widget.docId)
          .collection('words')
          .get()
          .then(
        (querySnapshot) {
          for (var doc in querySnapshot.docs) {
            if (flipList[currentFlipIndex]['word'][1] == doc['word'][1]) {
              flipList[currentFlipIndex]['word'][0] = tOrf;
              // ドキュメントを更新する
              doc.reference
                  .update({'word': flipList[currentFlipIndex]['word']});
            }
          }
          setState(() {
            currentFlipIndex++;
            isFront = true;
          });
        },
      );
    }
  }

  createFlipWidget(flipFront, flipBack) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return const VocabularyBooksList();
                      }),
                    );
                  },
                  child: const Text('終了'),
                ),
                const SizedBox(
                  width: 10,
                )
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('解説'),
                          content: Column(
                            children: [
                              Text('${flipList[currentFlipIndex]['word'][1]}'),
                              for (int i = 0;
                                  i <
                                      flipList[currentFlipIndex]['meanings']
                                          .length;
                                  i++) ...{
                                Card(
                                  child: ListTile(
                                    leading: Text(
                                        '${flipList[currentFlipIndex]['meanings'][i]['partOfSpeech'][1]}'),
                                    title: Text(
                                        '${flipList[currentFlipIndex]['meanings'][i]['meaning'][1]}'),
                                  ),
                                ),
                              },
                              for (int i = 0;
                                  i <
                                      flipList[currentFlipIndex]['meanings']
                                          .length;
                                  i++) ...{
                                if (flipList[currentFlipIndex]['meanings'][i]
                                        ['example'][1]
                                    .isNotEmpty) ...{
                                  Card(
                                    child: ListTile(
                                      leading: const Text('例文'),
                                      title: Column(
                                        children: [
                                          Text(
                                              '${flipList[currentFlipIndex]['meanings'][i]['example'][1]}'),
                                          Text(
                                              '${flipList[currentFlipIndex]['meanings'][i]['translatedExample'][1]}'),
                                        ],
                                      ),
                                    ),
                                  ),
                                }
                              },
                              for (int i = 0; i < 1; i++) ...{
                                if (flipList[currentFlipIndex]['comment']
                                    .isNotEmpty) ...{
                                  Card(
                                    child: ListTile(
                                      leading: const Icon(Icons.comment),
                                      title: const Text('コメント'),
                                      subtitle: Text(
                                          '${flipList[currentFlipIndex]['comment']}'),
                                    ),
                                  ),
                                }
                              }
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('キャンセル'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                setState(() {
                                  reApplyTrueOrFalse(false);
                                });
                              },
                              child: const Text('次へ'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Text('単語の詳細'),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isFront = !isFront;
                    });
                  },
                  child: Card(
                    child: Container(
                      width: 350,
                      height: 200,
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: AnimatedCrossFade(
                          duration: const Duration(milliseconds: 100),
                          firstChild: SingleChildScrollView(
                            child: Text(
                              flipFront,
                              style: const TextStyle(fontSize: 30),
                            ),
                          ),
                          secondChild: SingleChildScrollView(
                            child: Text(
                              flipBack,
                              style: const TextStyle(fontSize: 30),
                            ),
                          ),
                          crossFadeState: isFront
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        reApplyTrueOrFalse(false);
                      },
                      child: const Text('わからない'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        reApplyTrueOrFalse(true);
                      },
                      child: const Text('知っている'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool isFront = true;
  int currentFlipIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (vocabularyBookWords.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('Loading...'),
        ),
      );
    } else {
      return judgeFlipFinish(currentFlipIndex);
    }
  }
}
