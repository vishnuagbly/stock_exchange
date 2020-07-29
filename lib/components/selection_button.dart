import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectionButton extends StatelessWidget {
  final String text;
  final Function onPressed;
  final double width;

  SelectionButton(this.text, this.onPressed, {this.width});

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      color: Colors.white,
      child: Builder(
        builder: (context) {
          return Container(
            padding: EdgeInsets.all(20),
            constraints: BoxConstraints(
              minWidth: width ?? 0.0,
            ),
            child: Center(
              child: Text(
                text,
                style: GoogleFonts.montserrat(
                  textStyle: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
      ),
      onPressed: onPressed,
      disabledColor: Colors.white38,
    );
  }
}
