import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stockexchange/backend_files/backend_files.dart';
import 'package:stockexchange/components/common_alert_dialog.dart';
import 'package:stockexchange/components/components.dart';
import 'package:stockexchange/components/dialogs/future_dialog.dart';
import 'package:stockexchange/global.dart';
import 'package:stockexchange/json_classes/alerts/alert.dart';
import 'package:stockexchange/network/network.dart';
import 'package:flutter/material.dart' as material;

import '../json_classes.dart';

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
  Future<dynamic> showDialog(BuildContext context) async {
    return material.showDialog(
      context: context,
      builder: (context) => StreamBuilder<DocumentSnapshot>(
        stream: Network.getDocumentStream(loadingStatusDocName),
        builder: (context, snapshot) {
          if (snapshot.data != null && snapshot.data.data != null) {
            Status statusObj = Status.fromMap(snapshot.data.data);
            if (statusObj.status == LoadingStatus.tradingError) {
              return CommonAlertDialog(
                'Some error occured',
                icon: Icon(Icons.block, color: Colors.red),
              );
            }
            if (statusObj.status == LoadingStatus.tradeComplete)
              return FutureDialog<void>(
                future: Network.getAndSetMainPlayerFullData(),
                loadingText: 'Finalising Trade...',
                hasData: (_) => CommonAlertDialog('Trade Successful'),
              );
          }
          return MainAlertDialog(
            title: 'Performing Trade...',
            content: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
