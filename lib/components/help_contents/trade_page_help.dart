import 'package:flutter/material.dart';
import 'package:stockexchange/global.dart';

class TradePageHelp extends StatelessWidget {
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
          Text("In this page you can trade your money and share your cards with other players"),
        ],
      ),
    );
  }
}
