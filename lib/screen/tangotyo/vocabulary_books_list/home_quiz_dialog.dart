import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_tangotyo/screen/tangotyo/multiple_choice_quiz/multiple_choice_quiz.dart';

class QuizSettingDialog extends StatefulWidget {
  final Map<String, dynamic> quizSetting;
  final String docId;

  QuizSettingDialog({required this.quizSetting, required this.docId});

  @override
  _QuizSettingDialogState createState() => _QuizSettingDialogState();
}

class _QuizSettingDialogState extends State<QuizSettingDialog> {
  bool isInputEnabled = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Quiz設定'),
      content: Column(
        children: [
          Row(
            children: [
              Text('毎回解答を見る'),
              Switch(
                value: widget.quizSetting['switchQuizCommentary'],
                onChanged: (value) {
                  setState(() {
                    widget.quizSetting['switchQuizCommentary'] = value;
                  });
                },
              ),
            ],
          ),
          Row(
            children: [
              Text('間違えた問題のみ'),
              Switch(
                value: widget.quizSetting['switchExcludeErroneousQuiz'],
                onChanged: (value) {
                  setState(() {
                    if (value) {
                      isInputEnabled = false;
                    } else {
                      isInputEnabled = true;
                    }
                    widget.quizSetting['switchExcludeErroneousQuiz'] = value;
                  });
                },
              ),
            ],
          ),
          // Row(
          //   children: [
          //     const Text('Q:'),
          //     DropdownButton(
          //       items: const [
          //         DropdownMenuItem(
          //             value: 'word',
          //             child:
          //                 Text('単語')),
          //         DropdownMenuItem(
          //             value: 'mM',
          //             child:
          //                 Text('意味')),
          //         DropdownMenuItem(
          //             value: 'mPOS',
          //             child:
          //                 Text('品詞')),
          //         DropdownMenuItem(
          //             value: 'mEx',
          //             child:
          //                 Text('例文')),
          //         DropdownMenuItem(
          //             value: 'mTEx',
          //             child: Text(
          //                 '例文訳')),
          //       ],
          //       value: 'word',
          //       onChanged: (value) {
          //         setState(() {
          //           quizSetting[
          //                   'kindOfProblem'] =
          //               value;
          //         });
          //       },
          //     ),
          //   ],
          // ),
          // Row(
          //   children: [
          //     const Text('A:'),
          //     DropdownButton(
          //       items: const [
          //         DropdownMenuItem(
          //             value: 'word',
          //             child:
          //                 Text('単語')),
          //         DropdownMenuItem(
          //             value: 'mM',
          //             child:
          //                 Text('意味')),
          //         DropdownMenuItem(
          //             value: 'mPOS',
          //             child:
          //                 Text('品詞')),
          //         DropdownMenuItem(
          //             value: 'mEx',
          //             child:
          //                 Text('例文')),
          //         DropdownMenuItem(
          //             value: 'mTEx',
          //             child:
          //                 Text('例文訳')),
          //       ],
          //       value: 'mM',
          //       onChanged: (value) {
          //         setState(() {
          //           quizSetting[
          //                   'kindOfAnswer'] =
          //               value;
          //         });
          //       },
          //     ),
          //   ],
          // ),
          Row(
            children: [
              const Text('問題範囲: '),
              SizedBox(
                width: 40,
                child: TextField(
                  controller: TextEditingController.fromValue(
                    TextEditingValue(
                      text: widget.quizSetting['startNumberOfQuiz'],
                      selection: TextSelection.collapsed(
                          offset:
                              widget.quizSetting['startNumberOfQuiz'].length),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    widget.quizSetting['startNumberOfQuiz'] = value;
                  },
                ),
              ),
              const Text(' ～ '),
              SizedBox(
                width: 40,
                child: TextField(
                  controller: TextEditingController.fromValue(
                    TextEditingValue(
                      text: widget.quizSetting['endNumberOfQuiz'],
                      selection: TextSelection.collapsed(
                          offset: widget.quizSetting['endNumberOfQuiz'].length),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    widget.quizSetting['endNumberOfQuiz'] = value;
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Text('問題数:'),
              Expanded(
                child: TextField(
                  enabled: isInputEnabled,
                  controller: TextEditingController.fromValue(
                    TextEditingValue(
                      text: widget.quizSetting['numberOfQuiz'],
                      selection: TextSelection.collapsed(
                          offset: widget.quizSetting['numberOfQuiz'].length),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    widget.quizSetting['numberOfQuiz'] = value;
                  },
                ),
              )
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('キャンセル'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('クイズ開始'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) {
                return MultipleChoiceQuiz(
                    quizSetting: widget.quizSetting, docId: widget.docId);
              }),
            );
          },
        ),
      ],
    );
  }
}
