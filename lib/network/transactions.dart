import 'dart:developer';

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
}
