import 'package:flutter/material.dart';

class BooleanDialog extends StatelessWidget {
  BooleanDialog(this.text);

  final String text;

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
          onPressed: () => Navigator.pop(
            context,
            true,
          ),
        ),
        FlatButton(
          child: Text("NO"),
          onPressed: () => Navigator.pop(
            context,
            false,
          ),
        )
      ],
    );
  }
}
