import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stockexchange/global.dart';
import 'package:stockexchange/network/network.dart';
import 'package:stockexchange/json_classes/json_classes.dart';

StreamController<Alert> alertsController = StreamController.broadcast();

StreamSubscription<QuerySnapshot> checkAndShowAlert() {
  log("reahed checkAndShowAlert", name: "checkAndShowAlert");
  Stream<QuerySnapshot> stream =
      Network.getCollectionStream("${Network.alertCollectionPath}");
  var alertSubscription = stream.listen((QuerySnapshot snapshot) async {
    log('listened something from alerts document', name: 'checkAndShowAlert');
    List<DocumentSnapshot> allDocuments = snapshot.documents;
    List<Map<String, dynamic>> allAlertMaps = [];
    for (DocumentSnapshot document in allDocuments) {
      allAlertMaps.add(document.data);
      log('adding alert: ${document.data}', name: 'checkAndShowAlert');
    }
    if (allAlertMaps.length > 0) {
      log("got something", name: "checkAndShowAlert");
      await Network.deleteAllDocuments(Network.alertCollectionPath);
      await addToAlerts(allAlertMaps);
    }
  });
  log("leaving", name: "checkAndShowAlert");
  return alertSubscription;
}

StreamSubscription<Alert> showAlerts(BuildContext context) {
  String logName = "checkAndShowAlerts->showAlerts";
  log("alternative Program is sleeping", name: logName);
  Stream<Alert> stream = alertsController.stream;
  var subscription = stream.listen((Alert alert) async {
    await alert.showDialog(context);
  });
  return subscription;
}

Future<void> addToAlerts(List<Map<String, dynamic>> allAlertMaps) async {
  String logName = "checkAndShowAlert->showDialogAccordingly";
  log("alert detected ${allAlertMaps.length}", name: logName);
  List<Alert> waitingAlerts = [];
  for (int i = 0; i < allAlertMaps.length; i++) {
    waitingAlerts.add(getAlertAccordingly(allAlertMaps[i]));
    if (waitingAlerts.last.sendWaitingForResponseAlert) {
      WaitingForResponseAlert alert =
          WaitingForResponseAlert(Network.authId, playerManager.mainPlayerName);
      Network.createDocument(
          "$kAlertDocName/${waitingAlerts.last.uuid}/${Network.authId}",
          alert.toMap());
    }
    alertsController.add(waitingAlerts[i]);
  }
}
