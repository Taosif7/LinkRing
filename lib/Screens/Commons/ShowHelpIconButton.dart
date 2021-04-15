import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ShowHelpIconButton extends StatelessWidget {
  final String helpText;
  final String titleText;

  const ShowHelpIconButton({Key key, this.helpText, this.titleText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon: Icon(Icons.help_outline),
        onPressed: () {
          showDialog(
              context: context,
              builder: (x) => AlertDialog(
                    elevation: 0,
                    content: Text(helpText),
                    title: titleText != null ? Text(titleText) : null,
                  ));
        },
        tooltip: "Show Help");
  }
}
