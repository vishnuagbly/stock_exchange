import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart';
import 'package:stockexchange/global.dart';
import 'package:stockexchange/network/network.dart';
import 'all_alerts.dart';

class Alert {
  final String uuid;
  final String name;
  bool sendWaitingForResponseAlert = true;

  Alert()
      : this.uuid = Network.authId,
        this.name = playerManager.mainPlayerName;

  Alert.fromString(this.uuid, this.name);

  Alert.fromMap(Map<String, dynamic> map)
      : uuid = map["uuid"],
        name = map["name"];

  static List<Alert> alertList(List<dynamic> allAlertMaps) {
    List<Alert> allAlerts = [];
    for (Map<String, dynamic> alertMap in allAlertMaps)
      allAlerts.add(Alert.fromMap(alertMap));
    return allAlerts;
  }

  AlertDialog alertDialog(BuildContext context) => null;

  Future<dynamic> showDialog(BuildContext context) async {
    AlertDialog dialog = alertDialog(context);
    if(dialog != null){
      await material.showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => alertDialog(context),
      );
      log("alert completed", name: "alert/showDialog");
    }
  }
}

Alert getAlertAccordingly(Map<String, dynamic> map) {
  if (map["type"] == null) return null;
  String type = map["type"];
  log("got alert, type: $type", name: "alert/getAlertAccordingly");
  switch (type) {
    case "trade":
      return TradeAlert.fromMap(map);
    case "waiting_for_response":
      return WaitingForResponseAlert.fromMap(map);
    case "trade_successful":
      return TradeAccepted.fromMap(map);
    case "trade_declined":
      return TradeDeclined.fromMap(map);
    case "completing_round":
      return CompletingRound.fromMap(map);
    default:
      return null;
  }
}
