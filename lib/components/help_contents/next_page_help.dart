import 'package:flutter/material.dart';
import 'package:stockexchange/global.dart';

class NextPageHelp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.6,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text("On this page you complete your turn or move to next round depending on your turn respective to other players"),
        ],
      ),
    );
  }
}
