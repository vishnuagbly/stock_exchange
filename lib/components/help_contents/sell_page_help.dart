import 'package:flutter/material.dart';
import 'package:stockexchange/global.dart';

class SellPageHelp extends StatelessWidget {
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
          Text("In this page you can sell your shares works exactly like buy shares page."),
        ],
      ),
    );
  }
}
