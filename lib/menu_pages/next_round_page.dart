import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:stockexchange/components/components.dart';
import 'package:stockexchange/components/dialogs/future_dialog.dart';
import 'package:stockexchange/global.dart';
import 'package:stockexchange/json_classes/json_classes.dart';
import 'package:stockexchange/network/network.dart';
import 'package:stockexchange/network/offline_database.dart';
import 'package:stockexchange/network/transactions.dart';
import 'package:stockexchange/pages/game_finished_page.dart';

class NextRoundPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Container(
            margin: EdgeInsets.fromLTRB(50, 50, 50, 0),
            padding: EdgeInsets.all(30),
            decoration: kSlateBackDecoration,
            child: Column(
              children: <Widget>[
                Text("ARE YOU SURE"),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton(
                        child: Text("YES"),
                        onPressed: () async {
                          if (playerManager.lastTurn() || !online)
                            log("pressed yes moving to next round",
                                name: 'nextRoundPage');
                          else
                            log("pressed yes moving to next turn",
                                name: 'nextRoundPage');
                          currentPage.value = StockPage.home;
                          if (!online) {
                            startNextRound();
                            companies = cardBank.updateCompanyPrices();
                            await showDialog(
                              context: context,
                              builder: (context) => FutureDialog(
                                future: Phone.saveGame(),
                                loadingText: 'Saving Game...',
                                hasData: (_) => CommonAlertDialog('Saved Game'),
                              ),
                            );
                            ifGameFinished();
                            if (playerManager.depressionValue == 100)
                              await showDialog(
                                context: context,
                                builder: (context) => CommonAlertDialog(
                                  'Depression Bar Got Filled',
                                  icon: Icon(Icons.block),
                                ),
                              );
                            await showDialog(
                              context: context,
                              builder: (context) => FutureDialog(
                                future: quitGame(),
                                loadingText: 'Quiting game...',
                              ),
                            );
                          } else {
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) => FutureDialog(
                                future: onlineNext(),
                              ),
                            );
                          }
                        }),
                    SizedBox(
                      width: 10,
                    ),
                    RaisedButton(
                      child: Text("NO"),
                      onPressed: () {
                        log("pressed no", name: 'nextRoundPage');
                        currentPage.value = StockPage.home;
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: screenWidth * 0.05),
          Container(
            margin: EdgeInsets.fromLTRB(50, 0, 50, 50),
            padding: EdgeInsets.all(30),
            decoration: kSlateBackDecoration,
            child: Column(
              children: [
                Text(
                  "Depression Bar",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                  ),
                ),
                SizedBox(
                  height: screenWidth * 0.02,
                ),
                Container(
                  width: double.infinity,
                  height: screenWidth * 0.1,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Color(0x10FFFFFF),
                  ),
                  padding: EdgeInsets.all(7),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Row(
                      children: [
                        Expanded(
                          flex: playerManager.depressionValue,
                          child: Container(
                            height: double.infinity,
                            color: Colors.red[700],
                            child: Center(
                                child:
                                    Text("${playerManager.depressionValue}%")),
                          ),
                        ),
                        Expanded(
                          flex: 100 - playerManager.depressionValue,
                          child: Container(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> onlineNext() async {
  if (!playerManager.lastTurn()) {
    PlayerTurn playerTurn = PlayerTurn.next();
    await Network.updateData(playersTurnsDocName, playerTurn.toMap());
    return;
  }
  await sendRoundCompleteAlert();
  Transaction.startNextRound();
}
