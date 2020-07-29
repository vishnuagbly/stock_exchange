import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class SelectionButton extends StatelessWidget {
  final String text;
  final Function onPressed;

  SelectionButton(this.text, this.onPressed);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      color: Colors.white,
      child: Container(
        padding: EdgeInsets.all(20),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
      ),
      onPressed: onPressed,
      disabledColor: Colors.white38,
    );
  }
}