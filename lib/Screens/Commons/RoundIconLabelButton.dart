import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RoundIconLabelButton extends StatelessWidget {
  Widget Icon;
  String label;
  Color buttonColor;
  Function onTap;

  RoundIconLabelButton(this.Icon, this.label, {this.buttonColor = Colors.white, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Material(
        clipBehavior: Clip.hardEdge,
        color: this.buttonColor,
        elevation: 2,
        shape: CircleBorder(),
        child: IconButton(icon: this.Icon, onPressed: onTap ?? () {}, color: Colors.black),
      ),
      SizedBox(height: 10),
      Text(label, style: TextStyle(fontSize: 12)),
    ]);
  }
}
