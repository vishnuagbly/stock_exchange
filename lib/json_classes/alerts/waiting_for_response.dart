import 'package:flutter/material.dart';
import 'package:stockexchange/global.dart';
import 'package:stockexchange/components/main_alert_dialog.dart';
import 'alert.dart';

class WaitingForResponseAlert extends Alert {
  WaitingForResponseAlert(String uuid, String name)
      : super.fromString(uuid, name);

  WaitingForResponseAlert.fromMap(Map<String, dynamic> map)
      : super.fromMap(map);

  Map<String, dynamic> toMap() => {
        "uuid": uuid,
        "name": name,
        "type": "waiting_for_response",
      };

  bool sendWaitingForResponseAlert = false;

  @override
  AlertDialog alertDialog(BuildContext context) => MainAlertDialog(
        title: "Waiting For Response",
        content: Text("Player: $name"),
        actions: <Widget>[
          FlatButton(
            color: Colors.transparent,
            child: Text(
              "OK",
              style: TextStyle(
                fontSize: kAlertDialogButtonTextSize,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
}
