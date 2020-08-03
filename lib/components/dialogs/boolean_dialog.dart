import 'package:flutter/material.dart';

class BooleanDialog extends StatelessWidget {
  BooleanDialog(this.text, {this.onPressedNo, this.onPressedYes});

  final String text;
  final Function onPressedYes;
  final Function onPressedNo;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return AlertDialog(
      title: Container(
        width: screenWidth * 0.5,
        child: Text(
          text,
          maxLines: null,
        ),
      ),
      actions: [
        FlatButton(
          child: Text("YES"),
          onPressed: onPressedYes ?? () => Navigator.pop(
            context,
            true,
          ),
        ),
        FlatButton(
          child: Text("NO"),
          onPressed: onPressedNo ?? () => Navigator.pop(
            context,
            false,
          ),
        )
      ],
    );
  }
}
