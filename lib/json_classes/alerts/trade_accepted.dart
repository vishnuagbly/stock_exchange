import 'package:flutter/material.dart';
import 'package:stockexchange/backend_files/player.dart';
import 'package:stockexchange/components/common_alert_dialog.dart';
import 'package:stockexchange/global.dart';
import 'package:stockexchange/json_classes/alerts/alert.dart';
import 'package:stockexchange/network/network.dart';

class TradeAccepted extends Alert {
  TradeAccepted(this.tradeDetails) : super();

  TradeAccepted.fromMap(Map<String, dynamic> map)
      : this.tradeDetails = TradeDetails.fromMap(map["trade_details"]),
        super.fromString(map["uuid"], map["name"]);

  Map<String, dynamic> toMap() => {
    "type": "trade_successful",
    "name": name,
    "uuid": uuid,
    "trade_details": tradeDetails.toMap(),
  };

  final TradeDetails tradeDetails;
  bool sendWaitingForResponseAlert = false;

  @override
  AlertDialog alertDialog(BuildContext context) {
    return CommonAlertDialog(
      "Trade Accepted by $name",
      onPressed: () async {
        await playerManager.onlineTrade(tradeDetails.reverse());
        Network.updateAllMainPlayerData();
        Navigator.of(context).pop();
      },
    );
  }
}
