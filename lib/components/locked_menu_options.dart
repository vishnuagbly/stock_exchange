import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:stockexchange/network/network.dart';
import 'menu_slate.dart';
import 'package:stockexchange/global.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stockexchange/json_classes/json_classes.dart';

class LockedMenuOptions extends StatelessWidget {
  final StockPage lockedPage;

  LockedMenuOptions(this.lockedPage);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Network.firestore
            .document(
                "${Network.gameDataPath}/$playersTurnsDocName")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            log("room does not exist", name: "LockedMenuOptions");
            if (!online) return UnlockedOpt(lockedPage);
            return LockedMenuOpt();
          }
//          log("room exists", name: "LockedMenuOptions");
          DocumentSnapshot playerTurnsDocument = snapshot.data;
          if (playerTurnsDocument.data == null) {
            log("no data inside room collection", name: "LockedMenuOptions");
            if (!online) return UnlockedOpt(lockedPage);
            return LockedMenuOpt();
          }
          PlayerTurn playerTurn = PlayerTurn.fromMap(playerTurnsDocument.data);
          log("acquired player turns successfully: ${playerTurn.turn}",
              name: "LockedMenuOptions");
          log("your turn: ${playerManager.mainPlayerTurn}",
              name: "LockedMenuOption");
          if (playerTurn.turn == playerManager.mainPlayerTurn){
            currentTurn = true;
            return UnlockedOpt(lockedPage);
          }
          currentTurn = false;
          return LockedMenuOpt();
        });
  }
}

class UnlockedOpt extends StatelessWidget {
  final StockPage unlockedPage;

  UnlockedOpt(this.unlockedPage);

  @override
  Widget build(BuildContext context) {
    if (unlockedPage == StockPage.buy)
      return Row(
        children: <Widget>[
          MenuSlate(
            page: StockPage.buy,
            icon: Icon(
              Icons.shopping_cart,
              color: Colors.green[900],
            ),
            title: "Buy Shares",
          ),
        ],
      );
    else
      return MenuSlate(
        page: StockPage.next,
        icon: Icon(
          Icons.arrow_forward,
          color: Colors.teal[500],
        ),
        title: playerManager != null
            ? (playerManager.lastTurn() ? "Next Round" : "Complete Turn")
            : "NA",
      );
  }
}

class LockedMenuOpt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MenuSlate(
      getSelected: false,
      icon: Icon(
        Icons.lock,
        color: Colors.grey,
      ),
      title: "Locked",
    );
  }
}
