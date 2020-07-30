import 'package:flutter/material.dart';
import 'file:///D:/FlutterProjects/stock_exchange/lib/components/dialogs/common_alert_dialog.dart';
import 'package:stockexchange/json_classes/alerts/alert.dart';

class TradeDeclined extends Alert {
  TradeDeclined() : super();

  TradeDeclined.fromMap(Map<String, dynamic> map) : super.fromMap(map);

  Map<String, dynamic> toMap() => {
        "type": "trade_declined",
        "uuid": uuid,
        "name": name,
      };

  bool sendWaitingForResponseAlert = false;

  @override
  AlertDialog alertDialog(BuildContext context) => CommonAlertDialog(
        "TRADE DECLINED",
        icon: Icon(
          Icons.block,
          color: Colors.red,
        ),
      );
}
