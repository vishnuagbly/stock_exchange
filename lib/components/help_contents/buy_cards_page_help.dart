import 'package:flutter/material.dart';
import 'package:stockexchange/global.dart';

class BuyCardsPageHelp extends StatelessWidget {
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
          Text("In this page you can buy extra cards from bank, works exactly like buy shares page."),
          SizedBox(height: 10),
          Text(
            "MORE INFO FOR NERDS  ( MAY GET UNFAIR ADVANTAGE OVER OTHERS ):-",
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              color: Colors.red[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          Divider(color: Colors.red[700], thickness: 2,),
          Text("Price for extra cards is not constant for each round and each player."),
          SizedBox(height: 5),
          Text("Price for each cards is generated according to max profit can be achieved on that round by that player."),
          SizedBox(height: 5),
          Text("Hence, higher the price for each card, it means higher the profit can be achieved by that player if he/she buys the correct shares."),
        ],
      ),
    );
  }
}