import 'package:flutter/material.dart';
import 'package:stockexchange/global.dart';

class HomePageHelp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
            "In this page there are all companies data and click on any company's icon for additional details."),
        SizedBox(height: 10),
        Text(
          "ABOUT GAME:-",
          style: TextStyle(
            color: Colors.amber,
            fontSize: screenWidth * 0.04,
            fontWeight: FontWeight.bold,
          ),
        ),
        Divider(
          color: Colors.amber,
          thickness: 2,
        ),
        Text("Aim of this game is to earn money by buying and selling shares"),
        SizedBox(height: 5),
        Text("Person with maximum money in the end wins"),
        SizedBox(height: 10),
        Text(
          "APP LAYOUT:-",
          style: TextStyle(
            color: Colors.cyan,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.04,
          ),
        ),
        Divider(
          color: Colors.cyan,
          thickness: 2,
        ),
        Text("In top right corner you can always see your balance."),
        SizedBox(height: 5),
        Text("There is horizontal sliding menu for different pages."),
        SizedBox(height: 5),
        Text("There might be some locked options in menu, it is because currently it might not be your turn"),
        SizedBox(height: 5),
        Text("Click on info icon on each page for additional info on each."),
        SizedBox(height: 5),
        Text('You can check your turn from everyone\'s assets menu.'),
      ],
    );
  }
}
