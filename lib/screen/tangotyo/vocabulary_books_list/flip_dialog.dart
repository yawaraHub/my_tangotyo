import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_tangotyo/screen/tangotyo/flip/flip.dart';

class FlipSettingDialog extends StatefulWidget {
  final Map<String, dynamic> flipSetting;
  final String docId;

  FlipSettingDialog({required this.flipSetting, required this.docId});

  @override
  _FlipSettingDialogState createState() => _FlipSettingDialogState();
}

class _FlipSettingDialogState extends State<FlipSettingDialog> {
  bool isInputEnabled = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Flip設定'),
      content: Column(
        children: [
          DropdownButton(
            items: const [
              DropdownMenuItem(value: 'ExTEx', child: Text('例文&例文訳')),
              DropdownMenuItem(value: 'MeTMe', child: Text('単語&意味')),
            ],
            value: widget.flipSetting['kindOfFlip'],
            onChanged: (value) {
              setState(() {
                widget.flipSetting['kindOfFlip'] = value;
              });
            },
          ),
          Row(
            children: [
              const Text('間違えた問題のみ'),
              Switch(
                value: widget.flipSetting['switchExcludeErroneousFlip'],
                onChanged: (value) {
                  setState(() {
                    if (value) {
                      isInputEnabled = false;
                    } else {
                      isInputEnabled = true;
                    }
                    widget.flipSetting['switchExcludeErroneousFlip'] = value;
                  });
                },
              ),
            ],
          ),
          Row(
            children: [
              Text('英語が表'),
              Switch(
                value: widget.flipSetting['switchFrontBackFlip'],
                onChanged: (value) {
                  setState(() {
                    if (value) {
                      isInputEnabled = false;
                    } else {
                      isInputEnabled = true;
                    }
                    widget.flipSetting['switchFrontBackFlip'] = value;
                  });
                },
              ),
            ],
          ),
          Row(
            children: [
              Text('シャッフル'),
              Switch(
                value: widget.flipSetting['switchShuffleFlip'],
                onChanged: (value) {
                  setState(() {
                    if (value) {
                      isInputEnabled = false;
                    } else {
                      isInputEnabled = true;
                    }
                    widget.flipSetting['switchShuffleFlip'] = value;
                  });
                },
              ),
            ],
          ),
          Row(
            children: [
              const Text('問題範囲: '),
              SizedBox(
                width: 40,
                child: TextField(
                  controller: TextEditingController.fromValue(
                    TextEditingValue(
                      text: widget.flipSetting['startNumberOfFlip'],
                      selection: TextSelection.collapsed(
                          offset:
                              widget.flipSetting['startNumberOfFlip'].length),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    widget.flipSetting['startNumberOfFlip'] = value;
                  },
                ),
              ),
              const Text(' ～ '),
              SizedBox(
                width: 40,
                child: TextField(
                  controller: TextEditingController.fromValue(
                    TextEditingValue(
                      text: widget.flipSetting['endNumberOfFlip'],
                      selection: TextSelection.collapsed(
                          offset: widget.flipSetting['endNumberOfFlip'].length),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    widget.flipSetting['endNumberOfFlip'] = value;
                  },
                ),
              ),
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
          child: const Text('フリップ開始'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) {
                return FlipCard(
                    flipSetting: widget.flipSetting, docId: widget.docId);
              }),
            );
          },
        ),
      ],
    );
  }
}
