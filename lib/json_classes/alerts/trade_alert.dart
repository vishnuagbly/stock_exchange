import 'package:flutter/material.dart';
import 'package:stockexchange/components/common_alert_dialog.dart';
import 'trade_accepted.dart';
import 'trade_declined.dart';
import 'package:stockexchange/network/network.dart';
import 'package:stockexchange/backend_files/player.dart';
import 'package:stockexchange/global.dart';
import 'package:stockexchange/components/main_alert_dialog.dart';
import 'alert.dart';

class TradeAlert extends Alert {
  TradeAlert(this.tradeDetails) : super();

  TradeAlert.fromMap(Map<String, dynamic> map)
      : this.tradeDetails = TradeDetails.fromMap(map["trade_details"]),
        super.fromString(map["uuid"], map["name"]);

  Map<String, dynamic> toMap() => {
        "uuid": uuid,
        "name": name,
        "type": "trade",
        "trade_details": tradeDetails.toMap(),
      };

  final TradeDetails tradeDetails;

  @override
  AlertDialog alertDialog(BuildContext context) {
    if (tradeDetails == null) return null;
    Player mainPlayer = playerManager.mainPlayer();
    if (tradeDetails.moneyRequested > mainPlayer.money)
      return MainAlertDialog(
        title: "TRADE",
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("Requester: $name"),
            SizedBox(height: 5),
            Text("Asked money was more than you had"),
          ],
        ),
        contentPadding: EdgeInsets.all(30),
      );
    int numOfCards = tradeDetails.cardsRequested;
    int requestingPlayer = playerManager.getPlayerIndex(name);
    int requestedPlayer = playerManager.mainPlayerIndex;
    int correctNumOfCards = playerManager.checkNumOfTradingCards(
        requestedPlayer, requestingPlayer, numOfCards);
    AlertDialog result = MainAlertDialog(
      title: "TRADE",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TradeDetailRow("Trade Requester", "$name"),
          TradeDetailRow(
              "Offered Money", "$kRupeeChar${tradeDetails.moneyOffered}"),
          TradeDetailRow("Offered Cards", "${tradeDetails.cardsOffered} Cards"),
          TradeDetailRow(
              "Requested Money", "$kRupeeChar${tradeDetails.moneyRequested}"),
          numOfCards == correctNumOfCards
              ? TradeDetailRow("Requested Cards", "$numOfCards")
              : Column(
                  children: <Widget>[
                    TradeDetailRow(
                        "Requested Cards", "$correctNumOfCards Cards"),
                    TradeDetailRow(
                        "(Originally Requested", "$numOfCards Cards)"),
                  ],
                ),
        ],
      ),
      actions: <Widget>[
        FlatButton(
          color: Colors.transparent,
          padding: EdgeInsets.all(10),
          child: Text(
            "Accept",
            style: TextStyle(
              fontSize: kAlertDialogButtonTextSize,
              color: Colors.green,
            ),
          ),
          onPressed: () async {
            Future complete = playerManager.onlineTrade(tradeDetails);
            await Network.updateAllMainPlayerData();
            TradeAccepted tradeAccepted = TradeAccepted(tradeDetails);
            Network.createDocument(
                "$alertDocumentName/$uuid/${Network.authId}",
                tradeAccepted.toMap());
            Navigator.of(context).pop();
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return FutureBuilder(
                  future: complete,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return CommonAlertDialog("Trade Successful");
                    } else if (snapshot.hasError) {
                      return CommonAlertDialog(
                        "Something went wrong!",
                        icon: Icon(
                          Icons.block,
                          color: Colors.red,
                        ),
                      );
                    }
                    return MainAlertDialog(
                      title: "Loading performing Trade",
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
              },
            );
          },
        ),
        Container(
          height: 20,
          width: 2,
          color: Colors.white12,
        ),
        FlatButton(
          color: Colors.transparent,
          padding: EdgeInsets.all(10),
          child: Text(
            "Decline",
            style: TextStyle(
              fontSize: kAlertDialogButtonTextSize,
              color: Colors.red,
            ),
          ),
          onPressed: () async {
            TradeDeclined tradeDeclined = TradeDeclined();
            await Network.createDocument(
                "$alertDocumentName/$uuid/${Network.authId}",
                tradeDeclined.toMap());
            Navigator.of(context).pop();
          },
        ),
      ],
    );
    return result;
  }
}

class TradeDetailRow extends StatelessWidget {
  TradeDetailRow(this.first, this.second);

  final String first, second;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Text(first),
            ),
            Expanded(
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 20,
                  ),
                  Text(":-"),
                  SizedBox(
                    width: 20,
                  ),
                  Text(second),
                ],
              ),
            )
          ],
        ),
        SizedBox(
          height: 5,
        ),
      ],
    );
  }
}
