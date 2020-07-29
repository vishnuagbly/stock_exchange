import 'package:flutter/material.dart';
import 'package:stockexchange/global.dart';

class CommonAlertDialog extends AlertDialog {
  final String titleString;
  final Icon icon;
  final Function onPressed;

  CommonAlertDialog(this.titleString, {this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: kAlertDialogElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(kAlertDialogBorderRadius),
        ),
      ),
      backgroundColor: Color(kAlertDialogBackgroundColorCode),
      title: Row(
        children: <Widget>[
          Expanded(
            flex: 10,
            child: Text(
              titleString,
              style: TextStyle(
                fontSize: kAlertDialogTitleTextSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.only(left: 15),
              child: FittedBox(
                child: icon ??
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.lightGreen,
                    ),
              ),
            ),
          )
        ],
      ),
      actions: <Widget>[
        Center(
          child: FlatButton(
            color: Colors.transparent,
            child: Text(
              "OK",
              style: TextStyle(
                fontSize: kAlertDialogButtonTextSize,
              ),
            ),
            onPressed: onPressed ??
                () {
                  Navigator.of(context).pop();
                },
          ),
        ),
      ],
    );
  }
}
