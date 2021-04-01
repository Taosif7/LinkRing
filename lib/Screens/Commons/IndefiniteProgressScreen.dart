import 'package:flutter/material.dart';

void showIndefiniteProgressScreen(BuildContext context) {
  showDialog(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (_) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Container(
            color: Colors.black45,
            child: Center(child: CircularProgressIndicator()),
          ),
        );
      });
}

void hideIndefiniteProgressScreen(BuildContext context) {
  Navigator.of(context).pop();
}
