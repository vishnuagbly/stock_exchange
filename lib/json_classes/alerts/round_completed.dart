import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'package:stockexchange/components/components.dart';
import 'package:stockexchange/global.dart';
import 'package:stockexchange/json_classes/alerts/alert.dart';
import 'package:stockexchange/json_classes/round_loading_status.dart';
import 'package:stockexchange/network/network.dart';

class CompletingRound extends Alert {
  CompletingRound() : super();

  CompletingRound.fromMap(Map<String, dynamic> map) : super.fromMap(map);

  Map<String, dynamic> toMap() => {
        "type": "completing_round",
        "uuid": uuid,
        "name": name,
      };

  @override
  bool sendWaitingForResponseAlert = false;

  @override
  Future<dynamic> showDialog(BuildContext context) async {
    String logName = "round_completed/showDialog";
    log("reached", name: logName);
    return material.showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context){
        return StreamBuilder<DocumentSnapshot>(
          stream: Network.getDocumentStream(Network.nextRoundStatusDocName),
          builder: (context, snapshot){
            String status = "Completing Round";
            if(snapshot.data != null && snapshot.data.data != null){
              Map<String, dynamic> statusMap = snapshot.data.data;
              RoundLoadingStatus statusObj = RoundLoadingStatus.fromMap(statusMap);
              if(statusObj.status == roundLoadingStatus.startedNextRound){
                cardBank.generateAllCards();
                startNextRound();
                playerManager.incrementPlayerTurn();
                // ignore: invalid_use_of_protected_member
                homePageState.setState(() {});
                Network.updateAllMainPlayerData();
                return CommonAlertDialog(
                  "Started Next Round",
                );
              }
              else status = statusObj.toString();
            }
            return MainAlertDialog(
              title: status,
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
        );
      }
    );
  }
}
