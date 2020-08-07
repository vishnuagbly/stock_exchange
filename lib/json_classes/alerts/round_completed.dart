import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'package:stockexchange/components/components.dart';
import 'package:stockexchange/components/dialogs/future_dialog.dart';
import 'package:stockexchange/components/dialogs/loading_dialog.dart';
import 'package:stockexchange/global.dart';
import 'package:stockexchange/json_classes/alerts/alert.dart';
import 'package:stockexchange/json_classes/round_loading_status.dart';
import 'package:stockexchange/network/network.dart';
import 'package:stockexchange/pages/game_finished_page.dart';

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
        builder: (context) {
          return StreamBuilder<DocumentSnapshot>(
            stream: Network.getDocumentStream(kLoadingStatusDocName),
            builder: (context, snapshot) {
              String status = "Completing Round";
              if (snapshot.data != null && snapshot.data.data != null) {
                Map<String, dynamic> statusMap = snapshot.data.data;
                Status statusObj = Status.fromMap(statusMap);
                if (statusObj.status == LoadingStatus.startedNextRound) {
                  startNextRound();
                  return FutureDialog(
                    future: Network.getAndSetNewRoundsDetails(),
                    loadingText: 'Downloading Updates...',
                    hasData: (_) => CommonAlertDialog(
                      "Started Next Round",
                      onPressed: () {
                        log('your turn: ${playerManager.mainPlayerTurn}');
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          // ignore: invalid_use_of_protected_member
                          homePageState.setState(() {});
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            ifGameFinished();
                          });
                        });
                        Navigator.pop(context);
                      },
                    ),
                  );
                }
                if (statusObj.status == LoadingStatus.nextRoundError ||
                    statusObj.status == LoadingStatus.timeOut) {
                  return CommonAlertDialog(
                    statusObj.toString(),
                    icon: Icon(
                      Icons.block,
                      color: Colors.red,
                    ),
                  );
                } else
                  status = statusObj.toString();
              }
              return LoadingDialog(status);
            },
          );
        });
  }
}
