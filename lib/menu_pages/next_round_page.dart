import 'package:flutter/material.dart';
import 'package:stockexchange/components/dialogs/future_dialog.dart';
import 'package:stockexchange/global.dart';
import 'package:stockexchange/json_classes/json_classes.dart';
import 'package:stockexchange/network/network.dart';
import 'package:stockexchange/network/transactions.dart';

class NextRoundPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Container(
            margin: EdgeInsets.all(50),
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
                          if (playerManager.lastTurn())
                            print("pressed yes moving to next round");
                          else
                            print("pressed yes moving to next turn");
                          currentPage.value = StockPage.home;
                          if (!online)
                            cardBank.updateCompanyPrices();
                          else
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) => FutureDialog(
                                future: onlineNext(),
                              ),
                            );
                        }),
                    SizedBox(
                      width: 10,
                    ),
                    RaisedButton(
                      child: Text("NO"),
                      onPressed: () {
                        print("pressed no");
                        currentPage.value = StockPage.home;
                      },
                    ),
                  ],
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
