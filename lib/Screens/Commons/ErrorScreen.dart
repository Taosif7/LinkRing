import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:link_ring/Screens/Commons/CupertinoBackButton.dart';

class ErrorScreen extends StatelessWidget {
  final String errorMessage;
  String title;
  String assetImageName;

  ErrorScreen({Key key, this.errorMessage, this.title, this.assetImageName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(this.title ?? "Oops"), leading: CupertinoBackIconButton()),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (this.assetImageName != null)
              Image.asset('assets/error_images/${this.assetImageName}')
            else
              Container(color: Colors.blueGrey, height: 120),
            SizedBox(height: 20),
            Text(errorMessage, style: Theme.of(context).textTheme.headline6),
          ],
        ),
      ),
    );
  }
}
