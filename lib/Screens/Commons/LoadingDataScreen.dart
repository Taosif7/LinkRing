import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingDataScreen extends StatelessWidget {
  Future<void> Function(NavigatorState navigator) operation;

  LoadingDataScreen(this.operation);

  @override
  Widget build(BuildContext context) {
    operation(Navigator.of(context));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: () => Navigator.of(context).pop()),
      ),
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
