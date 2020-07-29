import 'package:flutter/material.dart';
import 'package:stockexchange/global.dart';

class TotalAssetsPageHelp extends StatelessWidget {
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
          Text("In this page you can see each players total assets. i.e balance he/she would have after selling all their share at current market price."),
        ],
      ),
    );
  }
}