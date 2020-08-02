import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:stockexchange/backend_files/player.dart';

class TradeDetails {
  final cardsOffered;
  final moneyOffered;
  final cardsRequested;
  final moneyRequested;
  final int playerRequesting;
  final int playerRequested;

  TradeDetails(List<int> values, this.playerRequested, this.playerRequesting)
      : this.cardsOffered = values[0],
        this.moneyOffered = values[1],
        this.cardsRequested = values[2],
        this.moneyRequested = values[3];

  TradeDetails.fromMap(Map<String, dynamic> map)
      : this.cardsOffered = map["values"][0],
        this.moneyOffered = map["values"][1],
        this.cardsRequested = map["values"][2],
        this.moneyRequested = map["values"][3],
        this.playerRequested = map["playerRequested"],
        this.playerRequesting = map["playerRequesting"];

  Map<String, dynamic> toMap() => {
        "values": [cardsOffered, moneyOffered, cardsRequested, moneyRequested],
        "playerRequested": playerRequested,
        "playerRequesting": playerRequesting,
      };

  TradeDetails reverse() {
    List<int> values = [
      cardsRequested,
      moneyRequested,
      cardsOffered,
      moneyOffered
    ];
    return TradeDetails(values, playerRequesting, playerRequested);
  }

  TradeDetails get detailsForRequestingPlayer => reverse();

  TradeDetails get detailsForRequestedPlayer => this;

  void checkIfTradePossible(Player requester, Player requested) {
    int requesterIndex = this.playerRequesting,
        requestedIndex = this.playerRequested;
    log('trade details: ${toMap()}', name: 'checkIfTradePossible');
    if (this.moneyOffered > requester.money)
      throw 'Not have enough money from trade requester';
    if (this.moneyRequested > requested.money) {
      log(
        'money requested: $moneyRequested, money requseted has: ${requested.money}',
        name: checkIfTradePossible.toString(),
      );
      throw 'requested person does not have enough money';
    }
    if (!checkIfTradingOfCardsPossible(
      cardsProvider: requester,
      cardsAcceptor: requested,
      numOfCards: this.cardsOffered,
      providerIndex: requesterIndex,
      acceptorIndex: requestedIndex,
    )) throw '${requester.name} does not have enoough cards';
    if (!checkIfTradingOfCardsPossible(
      cardsProvider: requested,
      cardsAcceptor: requester,
      numOfCards: this.cardsRequested,
      providerIndex: requestedIndex,
      acceptorIndex: requesterIndex,
    )) throw '${requested.name} does not have enoough cards';
    log('trade possible', name: 'checkIfTradePossible');
  }
}

int getPossibleTradingCards({
  @required Player cardsProvider,
  @required Player cardsAcceptor,
  @required int numOfCards,
  @required int providerIndex,
  @required int acceptorIndex,
}) {
  assert(cardsProvider != null &&
      cardsAcceptor != null &&
      numOfCards != null &&
      providerIndex != null &&
      providerIndex != null);
  if (!checkIfTradingOfCardsPossible(
    cardsProvider: cardsProvider,
    cardsAcceptor: cardsAcceptor,
    numOfCards: numOfCards,
    providerIndex: providerIndex,
    acceptorIndex: acceptorIndex,
  )) {
    numOfCards = cardsProvider.getAllCardsLength() -
        cardsProvider.totalTradedCards[acceptorIndex] -
        cardsAcceptor.totalTradedCards[providerIndex];
    if (numOfCards < 0) return 0;
  }
  return numOfCards;
}

bool checkIfTradingOfCardsPossible({
  @required Player cardsProvider,
  @required Player cardsAcceptor,
  @required int numOfCards,
  @required int providerIndex,
  @required int acceptorIndex,
}) {
  assert(cardsProvider != null &&
      cardsAcceptor != null &&
      numOfCards != null &&
      providerIndex != null &&
      providerIndex != null);
  if (cardsProvider.getAllCardsLength() -
          cardsProvider.totalTradedCards[acceptorIndex] -
          cardsAcceptor.totalTradedCards[providerIndex] <
      numOfCards) return false;
  if (numOfCards < 0) return false;
  return true;
}
