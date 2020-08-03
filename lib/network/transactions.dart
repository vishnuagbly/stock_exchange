import 'dart:developer';
import 'package:stockexchange/backend_files/card_data.dart' as shareCard;
import 'package:stockexchange/backend_files/player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:stockexchange/backend_files/backend_files.dart';
import 'package:stockexchange/global.dart';
import 'package:stockexchange/json_classes/json_classes.dart';
import 'package:stockexchange/network/network.dart';

class Transaction {
  static final firestore = Firestore.instance;

  static Future<void> buySellShares(
      int companyIndex, int shares, bool sellShares) async {
    Player mainPlayer;
    await firestore
        .runTransaction((transaction) async {
          var companiesSnapshot =
              await transaction.get(Network.companiesDataDocRef);
          var mainPlayerSnapshot =
              await transaction.get(Network.mainPlayerFullDataDocRef);
          companies =
              Company.allCompaniesFromMap(companiesSnapshot.data['companies']);
          mainPlayer = Player.fromFullMap(mainPlayerSnapshot.data);
          if (sellShares)
            mainPlayer.sellShares(companyIndex, shares);
          else
            mainPlayer.buyShares(companyIndex, shares);
          var roomDataSnapshot = await transaction.get(Network.roomDataDocRef);
          RoomData roomData = RoomData.fromMap(roomDataSnapshot.data);
          var totalAssets = roomData.allPlayersTotalAssetsBarCharData;
          for (int i = 0; i < totalAssets.length; i++)
            if (totalAssets[i].domain == mainPlayer.name)
              totalAssets[i] = mainPlayer.totalAssets();
          await transaction.update(Network.mainPlayerFullDataDocRef, {
            "_money": mainPlayer.money,
            "shares": mainPlayer.shares,
          });
          await transaction.update(Network.mainPlayerDataDocRef, {
            "_money": mainPlayer.money,
            "shares": mainPlayer.shares,
          });
          await transaction.update(Network.roomDataDocRef, roomData.toMap());
          await transaction.update(Network.companiesDataDocRef, {
            'companies': Company.allCompaniesToMap(companies),
          });
        })
        .then((_) => playerManager.setOfflineMainPlayerData(mainPlayer))
        .catchError((err) => throw err);
  }

  static Future<void> makeTrade(TradeDetails tradeDetails) async {
    await Status.send(LoadingStatus.trading);
    String requesterId =
        playerManager.getPlayerId(index: tradeDetails.playerRequesting);
    String requestedId =
        playerManager.getPlayerId(index: tradeDetails.playerRequested);
    Player mainPlayer;
    await firestore.runTransaction((transaction) async {
      var requesterSnapshot =
          await transaction.get(Network.playerFullDataRef(requesterId));
      var requestedSnapshot =
          await transaction.get(Network.playerFullDataRef(requestedId));
      var roomDataSnapshot = await transaction.get(Network.roomDataDocRef);
      RoomData roomData = RoomData.fromMap(roomDataSnapshot.data);
      if (requesterSnapshot.data == null) {
        throw PlatformException(
          code: 'PLAYER_NOT_FOUND',
          message: 'some error occured',
          details: 'requester: $requesterId not found',
        );
      }
      if (requestedSnapshot.data == null) {
        throw PlatformException(
          code: 'PLAYER_NOT_FOUND',
          message: 'some error occured',
          details: 'requested: $requestedId not found',
        );
      }
      Player requester = Player.fromFullMap(requesterSnapshot.data);
      Player requested = Player.fromFullMap(requestedSnapshot.data);
      if (requester.uuid == Network.authId)
        mainPlayer = requester;
      else
        mainPlayer = requested;
      tradeDetails.checkIfTradePossible(requester, requested);
      log('requester: ${requester.toMap()} requested: ${requested.toMap()}',
          name: 'Transaction.makeTrade');
      try {
        requester.makeHalfTrade(
            tradeDetails.detailsForRequestingPlayer, requested);
      } catch (err) {
        log("1st half trade error: $err", name: 'Transaction.madeTrade');
        throw err;
      }
      try {
        requested.makeHalfTrade(
            tradeDetails.detailsForRequestedPlayer, requester);
      } catch (err) {
        log("2nd half trade error: $err", name: 'Transaction.madeTrade');
        throw err;
      }
      log('trade completed requester: ${requester.toMap()} requested: ${requested.toMap()}',
          name: 'Transaction.makeTrade');
      var totalAssets = roomData.allPlayersTotalAssetsBarCharData;
      for (int i = 0; i < totalAssets.length; i++) {
        if (totalAssets[i].domain == requester.name)
          totalAssets[i] = requester.totalAssets();
        if (totalAssets[i].domain == requested.name)
          totalAssets[i] = requested.totalAssets();
      }
      roomData.allPlayersTotalAssetsBarCharData = totalAssets;
      await transaction.update(Network.roomDataDocRef, roomData.toMap());
      await transaction.update(
          Network.playerFullDataRef(requesterId), requester.toFullDataMap());
      await transaction.update(
          Network.playerFullDataRef(requestedId), requested.toFullDataMap());
      await transaction.update(
          Network.playerDataDocRef(requesterId), requester.toMap());
      await transaction.update(
          Network.playerDataDocRef(requestedId), requested.toMap());
      log("all updates done", name: 'transaction.makeTrade');
    }).then((_) async {
      await Status.send(LoadingStatus.tradeComplete);
      playerManager.setOfflineMainPlayerData(mainPlayer);
    }).catchError((error) async {
      Status.send(LoadingStatus.tradingError);
      log('transaction error: $error', name: 'transaction.makeTrade');
      throw error;
    });
  }

  static Future<void> startNextRound() async {
    var playerRefs = Network.allPlayersFullDataRefs;
    await firestore.runTransaction(
      (transaction) async {
        log("stariting next round", name: "startNextOnlineRound");
        List<DocumentSnapshot> documents = [];
        for (var ref in playerRefs) documents.add(await transaction.get(ref));
        var roomDataSnapshot = await transaction.get(Network.roomDataDocRef);
        var roomData = RoomData.fromMap(roomDataSnapshot.data);
        await Status.send(LoadingStatus.calculationStarted);
        List<Player> allPlayers = Player.allFullPlayersFromMap(
            Network.getAllDataFromDocuments(documents));
        List<shareCard.Card> allCards = getAllCards(allPlayers);
        List<Company> tempCompanies = calcSharePrice(allCards, companies);
        cardBank.generateAllCards();
        log('generated cards', name: 'startNextRound');
        allPlayers.setNewCards(cardBank.getEachPlayerCards(),
            cardBank.getEachPlayerProcessedCards());
        log('setted new cards', name: 'startNextRound');
        var totalAssets = roomData.allPlayersTotalAssetsBarCharData;
        await Status.send(LoadingStatus.calculationCompleted);
        await transaction.update(Network.companiesDataDocRef, {
          'companies': Company.allCompaniesToMap(tempCompanies),
        });
        await Status.send(LoadingStatus.startingNextRound);
        await transaction.set(
            firestore.document('${Network.roomName}/$playersTurnsDocName'), {
          'turns': 0,
        });
        for (int j = 0; j < totalAssets.length; j++){
          var assets = totalAssets[j];
          for(var player in allPlayers)
            if(player.name == assets.domain)
              assets = player.totalAssets();
          totalAssets[j] = assets;
        }
        roomData.allPlayersTotalAssetsBarCharData = totalAssets;
        await transaction.update(Network.roomDataDocRef, roomData.toMap());
        for (int i = 0; i < playerRefs.length; i++) {
          var ref = playerRefs[i];
          allPlayers[i].incrementPlayerTurn();
          await transaction.update(ref, allPlayers[i].toFullDataMap());
          log('player[${allPlayers[i].name} is updated', name: 'startNextRound');
        }

      },
    ).timeout(Duration(seconds: 7), onTimeout: () {

      throw 'Time out';
    })
        .then((_) {
      log('completed transaction', name: 'startNextRound');
      Status.send(LoadingStatus.startedNextRound);
    }).catchError((err) async {
      await Status.send(LoadingStatus.nextRoundError);
      throw err;
    });
  }
}

Future<void> sendRoundCompleteAlert() async {
  log("sending roundLoadingStatus", name: "setRoundCompleteAlert");
  await Status.send(LoadingStatus.gettingData);
  log("creating completingRound object", name: "setRoundCompleteAlert");
  CompletingRound completingRound = CompletingRound();
  for (int i = 0; i < playerManager.totalPlayers; i++) {
    Network.createDocument(
        "$alertDocumentName/${playerManager.getPlayerId(index: i)}/${Network.authId}",
        completingRound.toMap());
  }
  log("sent alert to everyone", name: "setRoundCompleteAlert");
}

List<shareCard.Card> getAllCards(List<Player> allPlayers) {
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

List<Company> calcSharePrice(
    List<shareCard.Card> allCards, List<Company> allCompanies) {
  log('starting calculating card shares price', name: 'calcSharePrice');
  List<int> shareValues = [];
  for (int i = 0; i < allCompanies.length; i++) shareValues.add(0);
  for (shareCard.Card card in allCards)
    shareValues[card.companyNum] += card.shareValueChange;
  for (int i = 0; i < allCompanies.length; i++)
    allCompanies[i].setCurrentSharePrice(shareValues[i]);
  return allCompanies;
}
