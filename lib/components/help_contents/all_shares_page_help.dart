import 'package:flutter/material.dart';
import 'package:stockexchange/global.dart';

class AllSharesPageHelp extends StatelessWidget {
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
          Text("In this page you can see all shares you have placed in a form of bar graph"),
        ],
      ),
    );
  }
}