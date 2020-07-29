import 'package:flutter/material.dart';
import 'package:stockexchange/global.dart';

class CompanyPageHelp extends StatelessWidget {

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
          Text("Here you can see details of the company."),
          SizedBox(height: 5),
          Text("First there is line graph showing the fluctuations in companies share price with each round"),
          SizedBox(height: 5),
          Text("Secondly is pie chart showing total part of shares own by each player out of 2,00,000 shares that company has."),
          SizedBox(height: 5),
          Text("Lastly there all cards of this company you have"),
        ],
      ),
    );
  }
}