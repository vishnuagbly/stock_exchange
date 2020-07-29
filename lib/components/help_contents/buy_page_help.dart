import 'package:flutter/material.dart';
import 'package:stockexchange/global.dart';

class BuyPageHelp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.6,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text("Main aim of this game is to buy and sell shares"),
            SizedBox(height: 5),
            Text("On this page you can buy shares for any company"),
            SizedBox(height: 10),
            Text(
              "BUY PRICE:-",
              style: TextStyle(
                color: Colors.teal,
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(
              color: Colors.teal,
              thickness: 2,
            ),
            Text(
                "Price of each share can be seen on home page, also if you type either price or number of shares you want, other column will automatically get filled."),
          ],
        ),
      ),
    );
  }
}
