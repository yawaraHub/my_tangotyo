import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_tangotyo/screen/tangotyo/multiple_choice_quiz/switch.dart';
import 'package:my_tangotyo/screen/tangotyo/vocabulary_book/word_detail.dart';
import 'package:my_tangotyo/screen/tangotyo/vocabulary_books_list/vocabulary_books_list.dart';

class MultipleChoiceQuiz extends StatefulWidget {
  final Map quizSetting;
  final String docId;

  const MultipleChoiceQuiz(
      {super.key, required this.quizSetting, required this.docId});

  @override
  State<MultipleChoiceQuiz> createState() => _MultipleChoiceQuizState();
}

class _MultipleChoiceQuizState extends State<MultipleChoiceQuiz> {
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
        createQuizDataList(vocabularyBookWords);
      }); // nullの場合も空のMapを代入
      setState(() {});
    }
  }

  List quizList = [];
  createQuizDataList(List vocabularyBookWords) {
    quizList = vocabularyBookWords.sublist(
        int.parse(widget.quizSetting['startNumberOfQuiz']) - 1,
        int.parse(widget.quizSetting['endNumberOfQuiz']));
    quizList.shuffle();

    List addedQuizList = vocabularyBookWords.sublist(
        int.parse(widget.quizSetting['startNumberOfQuiz']) - 1,
        int.parse(widget.quizSetting['endNumberOfQuiz']));
    if (widget.quizSetting['switchExcludeErroneousQuiz']) {
      quizList.removeWhere((item) => item['word'][0] == true);
      addedQuizList.removeWhere((item) => item['word'][0] == true);
    } else {
      if (quizList.length < int.parse(widget.quizSetting['numberOfQuiz'])) {
        for (int i = quizList.length;
            i <= int.parse(widget.quizSetting['numberOfQuiz']);) {
          addedQuizList.shuffle();
          quizList = quizList + addedQuizList;
          i = quizList.length;
        }
      }
      if (quizList.length > int.parse(widget.quizSetting['numberOfQuiz'])) {
        quizList.removeRange(
            int.parse(widget.quizSetting['numberOfQuiz']), quizList.length);
      }
    }
  }

  int _currentQuestionIndex = 0;

  judgeQuizFinish(currentQuestionIndex) {
    List answer = [];
    if (_currentQuestionIndex < quizList.length) {
      for (int i = 0;
          i < quizList[_currentQuestionIndex]['meanings'].length;
          i++) {
        answer.add(quizList[_currentQuestionIndex]['meanings'][i]);
      }
      answer = answer
          .where((element) => element.containsKey('meaning'))
          .map((element) => element['meaning'])
          .toList();
      return createQuizWidget(quizList[_currentQuestionIndex]['word'], answer);
    } else {
      //問題終了後の画面
      return Column(
        children: [
          for (int i = 0; i < quizList.length; i++) ...{
            if (answerBoolean[i] == true) ...{
              Card(
                color: Colors.blue[200],
                child: ListTile(
                  leading: const Text('◎'),
                  title: Text(quizList[i]['word'][1].toString()),
                  onTap: () {
                    FirebaseFirestore.instance
                        .collection('allVocabularyBooks')
                        .doc(_user.uid)
                        .collection('userVocabularyBooks')
                        .doc(widget.docId)
                        .collection('words')
                        .get()
                        .then((querySnapshot) {
                      final documentId = querySnapshot.docs
                          .firstWhere(
                            (doc) =>
                                doc.data()['word'][1] == quizList[i]['word'][1],
                          )
                          .id;
                      // followingDocumentId を使って何か処理を行う
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => WordDetail(
                            bookDocId: widget.docId,
                            wordDocId: documentId,
                          ),
                        ),
                      );
                    });
                  },
                ),
              ),
            } else ...{
              Card(
                color: Colors.red[200],
                child: ListTile(
                  leading: const Text('×'),
                  title: Text(quizList[i]['word'][1].toString()),
                  onTap: () {
                    FirebaseFirestore.instance
                        .collection('allVocabularyBooks')
                        .doc(_user.uid)
                        .collection('userVocabularyBooks')
                        .doc(widget.docId)
                        .collection('words')
                        .get()
                        .then((querySnapshot) {
                      final documentId = querySnapshot.docs
                          .firstWhere(
                            (doc) =>
                                doc.data()['word'][1] == quizList[i]['word'][1],
                          )
                          .id;
                      // followingDocumentId を使って何か処理を行う
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => WordDetail(
                            bookDocId: widget.docId,
                            wordDocId: documentId,
                          ),
                        ),
                      );
                    });
                  },
                ),
              ),
            },
          },
          Text(
              '${answerBoolean.where((element) => element == true).length}/${quizList.length}'),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return const VocabularyBooksList();
                }),
              );
            },
            child: const Text('Homeへ'),
          ),
        ],
      );
    }
  }

  createQuizWidget(question, answerList) {
    List filteredList = [];
    List choices = [];
    String answer = '';
    filteredList = vocabularyBookWords
        .where((map) => map['meanings'][0]['meaning'][1] != answerList[0][1])
        .toList();
    for (int i = 0; i < 3; i++) {
      Random random = Random();
      int randomIndex = random.nextInt(filteredList.length);
      choices
          .add([filteredList[randomIndex]['meanings'][0]['meaning'][1], false]);
      filteredList.removeAt(randomIndex);
    }
    for (int i = 0; i < answerList.length; i++) {
      if (i == 0) {
        answer = '${answerList[i][1]}';
      } else {
        answer = '$answer、${answerList[i][1]}';
      }
    }
    choices.add([answer, true]);
    choices.shuffle();

    //問題を表示する
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text('解答を表示'),
            MultipleChoiceQuizSwitch(
              quizSetting: widget.quizSetting,
            ),
          ],
        ),
        Card(
          child: Container(
            alignment: Alignment.center,
            height: 200,
            child: ListTile(
              title: Text(
                style: const TextStyle(
                  fontSize: 30,
                ),
                '${question[1]}',
                textAlign: TextAlign.center,
              ),
              subtitle: const Text(
                'の意味を選べ',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        for (int i = 0; i < choices.length; i++) ...{
          Card(
            child: ListTile(
              title: Wrap(
                children: [Text('${i + 1}'), Text('.${choices[i][0]}')],
              ),
              onTap: () {
                _answerQuestion(choices[i][1], question);
              },
            ),
          ),
        },
        ElevatedButton(
          onPressed: () {
            _answerQuestion(false, question);
          },
          child: const Text('わからない'),
        ),
      ],
    );
  }

  List answerBoolean = [];
  void _answerQuestion(bool thisBoolean, question) async {
    // 答えが正解かどうかを確認して、適宜スコアを加算するなどの処理を行う
    await FirebaseFirestore.instance
        .collection('allVocabularyBooks')
        .doc(_user.uid)
        .collection('userVocabularyBooks')
        .doc(widget.docId)
        .collection('words')
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        var wordList = doc.get('word');
        if (wordList[1] == question[1]) {
          // wordリストの0番目の値を変更する
          wordList[0] = thisBoolean;
          // ドキュメントを更新する
          doc.reference.update({'word': wordList});
        }
      }
    });
    answerBoolean.add(thisBoolean);
    // 次の問題を表示するために、問題のインデックスを増やす
    // setState(() {
    //   _currentQuestionIndex++;
    // });
    displayAnswerDetailScreen();
  }

  displayAnswerDetailScreen() {
    if (widget.quizSetting['switchQuizCommentary'] == true) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: [
                const Text('解説'),
                for (int i = 0; i < 1; i++) ...{
                  if (answerBoolean[_currentQuestionIndex]) ...{
                    const Icon(
                      Icons.circle_outlined,
                      color: Colors.red,
                    )
                  } else ...{
                    const Icon(
                      Icons.cancel,
                      color: Colors.red,
                    )
                  }
                }
              ],
            ),
            content: Column(
              children: [
                Text('${quizList[_currentQuestionIndex]['word'][1]}'),
                for (int i = 0;
                    i < quizList[_currentQuestionIndex]['meanings'].length;
                    i++) ...{
                  Card(
                    child: ListTile(
                      leading: Text(
                          '${quizList[_currentQuestionIndex]['meanings'][i]['partOfSpeech'][1]}'),
                      title: Text(
                          '${quizList[_currentQuestionIndex]['meanings'][i]['meaning'][1]}'),
                    ),
                  ),
                },
                for (int i = 0;
                    i < quizList[_currentQuestionIndex]['meanings'].length;
                    i++) ...{
                  if (quizList[_currentQuestionIndex]['meanings'][i]['example']
                          [1]
                      .isNotEmpty) ...{
                    Card(
                      child: ListTile(
                        leading: const Text('例文'),
                        title: Column(
                          children: [
                            Text(
                                '${quizList[_currentQuestionIndex]['meanings'][i]['example'][1]}'),
                            Text(
                                '${quizList[_currentQuestionIndex]['meanings'][i]['translatedExample'][1]}'),
                          ],
                        ),
                      ),
                    ),
                  }
                },
                for (int i = 0; i < 1; i++) ...{
                  if (quizList[_currentQuestionIndex]['comment']
                      .isNotEmpty) ...{
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.comment),
                        title: const Text('コメント'),
                        subtitle: Text(
                            '${quizList[_currentQuestionIndex]['comment']}'),
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
                  setState(() {
                    _currentQuestionIndex++;
                  });
                },
                child: const Text('次へ'),
              ),
            ],
          );
        },
      );
    } else {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  quizScreen() {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Quiz (${_currentQuestionIndex + 1}/${quizList.length})'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
              child: Column(
            children: [
              judgeQuizFinish(_currentQuestionIndex),
            ],
          )),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (vocabularyBookWords.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('Loading...'),
        ),
      );
    } else {
      return quizScreen();
    }
  }
}
