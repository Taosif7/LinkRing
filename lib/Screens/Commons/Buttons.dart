import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ColorButton extends StatelessWidget {
  final String label;
  final Function onPressed;
  final Color color;

  const ColorButton({Key key, @required this.label, @required this.onPressed, @required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      child: Text(label, style: Theme.of(context).textTheme.button.copyWith(color: Colors.white, fontSize: 16)),
      elevation: 0,
      focusElevation: 0,
      highlightElevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      color: this.color,
      padding: EdgeInsets.symmetric(vertical: 15),
    );
  }
}
