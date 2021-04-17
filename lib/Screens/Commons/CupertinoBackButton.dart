import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CupertinoBackIconButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon: Icon(CupertinoIcons.back),
        onPressed: () {
          Navigator.of(context).pop();
        });
  }
}
