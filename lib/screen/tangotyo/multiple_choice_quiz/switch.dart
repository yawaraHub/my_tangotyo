import 'package:flutter/material.dart';

class MultipleChoiceQuizSwitch extends StatefulWidget {
  final Map quizSetting;

  const MultipleChoiceQuizSwitch({super.key, required this.quizSetting});
  @override
  State<MultipleChoiceQuizSwitch> createState() =>
      _MultipleChoiceQuizSwitchState();
}

class _MultipleChoiceQuizSwitchState extends State<MultipleChoiceQuizSwitch> {
  @override
  Widget build(BuildContext context) {
    return Switch(
      value: widget.quizSetting['switchQuizCommentary'],
      onChanged: (value) {
        setState(() {
          widget.quizSetting['switchQuizCommentary'] = value;
        });
      },
    );
  }
}
