import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:stockexchange/backend_files/backend_files.dart';
import 'package:stockexchange/backend_files/card_data.dart' as shareCard;
import 'package:stockexchange/global.dart';
import 'package:stockexchange/json_classes/json_classes.dart';
import 'package:stockexchange/json_classes/round_loading_status.dart';
import 'package:stockexchange/network/network.dart';

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
                          if (!online) {
                            cardBank.updateCompanyPrices();
                            startNextOnlineRound();
                          } else
                            await onlineNext();
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
    await Network.updateData(playersTurnDocumentName, playerTurn.toMap());
    return;
  }
  await startNextOnlineRound();
}

Future<void> startNextOnlineRound() async {
  log("stariting next round", name: "startNextOnlineRound");
  List<Map<String, dynamic>> allPlayersMap =
      await Network.getAllDocuments(playerFullDataCollectionPath);
//  log("got playrs: ${allPlayersMap.toString()}", name: "startNextOnlineRound");
  List<Player> allPlayers = Player.allFullPlayersFromMap(allPlayersMap);
  sendRoundCompleteAlert(allPlayers);
  List<shareCard.Card> allCards = getAllCards(allPlayers);
  await calcAndUploadSharePrices(allCards);
}

void sendRoundCompleteAlert(List<Player> allPlayers) async {
  log("sending roundLoadingStatus", name: "setRoundCompleteAlert");
  await Status.send(LoadingStatus.calculationStarted);
  log("creating completingRound object", name: "setRoundCompleteAlert");
  CompletingRound completingRound = CompletingRound();
  for (Player player in allPlayers) {
    Network.createDocument(
        "$alertDocumentName/${player.uuid}/${Network.authId}",
        completingRound.toMap());
  }
  log("sent alert to everyone", name: "setRoundCompleteAlert");
}

List<shareCard.Card> getAllCards(List<Player> allPlayers) {
  Status.send(LoadingStatus.calculationInProgress);
  List<shareCard.Card> allCards = [];
  Player mainPlayer = playerManager.mainPlayer();
  for (shareCard.Card card in mainPlayer.getAllCards()) {
    if (!card.bought && !card.traded) allCards.add(card);
    if (allCards.length == 10) break;
  }
  allCards.addAll(cardBank.buyableCards);
  for (Player player in allPlayers)
    if (player.name != playerManager.mainPlayerName)
      for (shareCard.Card card in player.getAllCards())
        if (!card.traded) allCards.add(card);
  return allCards;
}

Future<void> calcAndUploadSharePrices(List<shareCard.Card> allCards) async {
  Status.send(LoadingStatus.calculationCompleted);
  List<int> shareValues = [];
  for (int i = 0; i < companies.length; i++) shareValues.add(0);
  for (shareCard.Card card in allCards)
    shareValues[card.companyNum] += card.shareValueChange;
  for (int i = 0; i < companies.length; i++)
    companies[i].setCurrenSharePrice(shareValues[i]);
  await Network.updateCompaniesData();
  Status.send(LoadingStatus.startedNextRound);
  Network.resetPlayerTurns();
}
