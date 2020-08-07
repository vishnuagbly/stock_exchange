library player;

import 'dart:developer';
import 'dart:math' as maths;
import 'package:flutter/material.dart';
import 'package:stockexchange/global.dart';
import 'package:stockexchange/json_classes/alerts/all_alerts.dart';
import 'package:stockexchange/network/network.dart';
import 'package:stockexchange/backend_files/card_data.dart' as shareCard;
import 'trade.dart';
import 'package:stockexchange/charts/pie_chart.dart';
import 'package:stockexchange/charts/bar_chart.dart';

class Player {
  String name;
  final bool mainPlayer;
  final bool online;
  String uuid;
  List<int> shares = [];
  List<shareCard.Card> _allCards = [];
  List<shareCard.Card> _processedCards = [];
  List<int> totalTradedCards = [];
  int _boughtCard = 0;
  int totalBoughtCards = 0;
  int _turn;

  int get turn => _turn;
  int _cardPrice;
  int _money;

  int get money => _money ?? 0;

  set turn(int value) {
    log('$name current turn: $_turn', name: 'setTurn');
    _turn = value;
    log('$name new turn = $turn', name: 'setTurn');
  }

  Player(this.name, int totalPlayers, int newTurn,
      {this.mainPlayer: false, this.online: false}) {
    this._money = 1000000;
    for (int i = 0; i < 6; i++) shares.add(0);
    for (int i = 0; i < totalPlayers; i++) {
      totalTradedCards.add(0);
    }
    turn = newTurn;
    log("totalTradedCards player[${this.name}]: $totalTradedCards",
        name: 'Player');
  }

  Player.fromMap(Map<String, dynamic> map, int totalPlayers,
      {this.mainPlayer: false, this.online: false})
      : name = map["name"],
        uuid = map["uuid"],
        shares = map["shares"].cast<int>(),
        _money = map["money"],
        totalTradedCards = getTotalTradedCardsFromMap(
          map["totalTradedCards"],
          totalPlayers,
        ),
        _allCards = generateDummyCards(map["totalCards"]),
        _turn = map["turn"];

  static List<int> getTotalTradedCardsFromMap(map, int totalPlayers) {
    List<int> result = map.cast<int>();
    while (result.length < totalPlayers) result.add(0);
    return result;
  }

  static List<shareCard.Card> generateDummyCards(int totalCards) {
    List<shareCard.Card> result = [];
    result.length = totalCards;
    return result;
  }

  Player.fromFullMap(Map<String, dynamic> map,
      {this.mainPlayer: false, this.online: false})
      : name = map["name"],
        uuid = map["uuid"],
        shares = map["shares"].cast<int>(),
        _allCards = shareCard.Card.allCardsFromMap(
            map["_allCards"].cast<Map<String, dynamic>>()),
        _processedCards = shareCard.Card.allCardsFromMap(
            map["_processedCards"].cast<Map<String, dynamic>>()),
        totalTradedCards = map["totalTradedCards"].cast<int>(),
        _boughtCard = map["_boughtCard"],
        totalBoughtCards = map["totalBoughtCards"],
        _cardPrice = map["_cardPrice"],
        _money = map["_money"],
        _turn = map["turn"];

  Map<String, dynamic> toFullDataMap() {
    return {
      "name": name,
      "uuid": uuid,
      "shares": shares,
      "mainPlayer": mainPlayer,
      "_allCards": shareCard.Card.allCardsToMap(_allCards),
      "_processedCards": shareCard.Card.allCardsToMap(_processedCards),
      "totalTradedCards": totalTradedCards,
      "_boughtCard": _boughtCard,
      "totalBoughtCards": totalBoughtCards,
      "_cardPrice": _cardPrice,
      "_money": _money,
      'turn': turn,
    };
  }

  ///players is list of Maps
  static List<Player> allFullPlayersFromMap(players,
      {bool savedOffline = false}) {
    List<Player> result = [];
    for (int i = 0; i < players.length; i++) {
      if (savedOffline)
        result.add(
          Player.fromFullMap(
            players[i],
            mainPlayer: players[i]['mainPlayer'],
          ),
        );
      else
        result.add(Player.fromFullMap(players[i]));
    }
    return result;
  }

  static List<Map<String, dynamic>> allPlayersToMap(List<Player> allPlayers) {
    List<Map<String, dynamic>> allPlayersMap = [];
    for (Player player in allPlayers) {
      allPlayersMap.add(player.toMap());
    }
    return allPlayersMap;
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "uuid": uuid,
      "shares": shares,
      "totalTradedCards": totalTradedCards,
      "totalCards": _allCards.length,
      "money": money,
      'turn': turn,
    };
  }

  int get totalPlayers => totalTradedCards.length;

  set totalPlayers(int value) {
    totalTradedCards.length = value;
  }

  void incrementPlayerTurn() {
    log("current player $name turn $turn", name: "incrementPlayerTurn");
    log('totalTradedCards: $totalTradedCards', name: 'incrementPlayerTurn');
    turn = (turn + 1) % totalTradedCards.length;
    log("new player $name turn $turn", name: "incrementPlayerTurn");
  }

  BarChartData totalAssets() {
    double totalAssets = _money.toDouble();
    log("calculating totalAssets for $name", name: 'Player->totalAssets');
    for (int i = 0; i < shares.length; i++)
      totalAssets += shares[i] * companies[i].getCurrentSharePrice();
    log("total assets: $totalAssets", name: 'Player->totalAssets');
    return BarChartData(name, totalAssets);
  }

  void setMoney(int money) {
    this._money = money;
    if (mainPlayer) balance.value = this._money;
  }

  void addMoney(int money) {
    this._money += money;
    if (mainPlayer) balance.value = this._money;
  }

  List<shareCard.Card> getProcessedCards() {
    return _processedCards;
  }

  int getCardPrice() {
    log('card price: $_cardPrice', name: 'getCardPrice');
    if (_cardPrice == null) setCardPrice();
    if (_cardPrice == -1) throw 'cards not for sale';
    return _cardPrice;
  }

  void setCardPrice() {
    log('setting card price', name: 'setCardPrice');
    try {
      _cardPrice = cardBank.getCardPrice(totalAssets().measure.toInt());
    } catch (error) {
      log('Error: ${error.toString()}', name: 'setCardPrice');
      _cardPrice = -1;
    }
  }

  int get maxBuyableCards {
    int stock = cardBank.getBuyableCardsLength() - totalBoughtCards;
    int cardsInBudget = money ~/ _cardPrice;
    return maths.min(stock, cardsInBudget);
  }

  void buyCards(int numOfCards) {
    List<shareCard.Card> cards =
        cardBank.getBuyableCard(totalBoughtCards, numOfCards);
    totalBoughtCards += numOfCards;
    if (totalBoughtCards >= cardBank.getBuyableCardsLength())
      throw 'We do not have enough cards to sell.';
    addCards(cards, bought: true);
    addMoney(numOfCards * _cardPrice * -1);
  }

  void setAllCards(List<shareCard.Card> cards,
      {bool traded, bool bought, int tradedFrom}) {
    _allCards.clear();
    addCards(cards, traded: traded, bought: bought, tradedFrom: tradedFrom);
  }

  void addCards(List<shareCard.Card> cards,
      {bool traded, bool bought, int tradedFrom}) {
    if (traded == null && bought == null)
      _allCards.addAll(cards);
    else
      for (int i = 0; i < cards.length; i++) {
        _allCards.add(shareCard.Card(
          cards[i].companyNum,
          cards[i].shareValueChange,
          traded: traded ?? false,
          tradedFrom: tradedFrom,
          bought: bought ?? false,
        ));
        if (traded ?? false) totalTradedCards[tradedFrom]++;
        if (bought ?? false) _boughtCard++;
      }
    setProcessedCards();
  }

  int getTotalBoughtCard() {
    return _boughtCard;
  }

  int getAllCardsLength() {
    return _allCards.length;
  }

  List<shareCard.Card> getAllCards() {
    return _allCards;
  }

  void setProcessedCards() {
    _processedCards.clear();
    List<int> resultShareChangeValue = [];
    List<bool> traded = [];
    List<bool> bought = [];
    resultShareChangeValue.length = companies.length;
    for (int i = 0; i < companies.length; i++) {
      traded.add(false);
      bought.add(false);
    }
    for (int i = 0; i < _allCards.length; i++) {
      resultShareChangeValue[_allCards[i].companyNum] =
          (resultShareChangeValue[_allCards[i].companyNum] ?? 0) +
              _allCards[i].shareValueChange;
      if (_allCards[i].traded ?? false) traded[_allCards[i].companyNum] = true;
      if (_allCards[i].bought ?? false) bought[_allCards[i].companyNum] = true;
    }
    for (int i = 0; i < resultShareChangeValue.length; i++)
      if (resultShareChangeValue[i] != null)
        _processedCards.add(shareCard.Card(
          i,
          resultShareChangeValue[i],
          traded: traded[i],
          bought: bought[i],
        ));
    mainPlayerCards.value++;
  }

  void autoPlay() {
    if (!mainPlayer || !online) {
      for (int i = 0; i < this.shares.length; i++)
        sellShares(i, this.shares[i]);
      int max;
      for (int i = 0; i < _processedCards.length; i++) {
        int companyIndex = _processedCards[i].companyNum;
        if (max == null && companies[companyIndex].getCurrentSharePrice() != 0)
          max = i;
        if (max != null) {
          if (_processedCards[max].shareValueChange <
                  _processedCards[i].shareValueChange &&
              companies[companyIndex].getCurrentSharePrice() != 0) max = i;
        }
      }
      if (max != null) {
        int shares = _money ~/
            companies[_processedCards[max].companyNum]
                .getCurrentSharePrice()
                .toInt();
        buyShares(_processedCards[max].companyNum, shares);
      }
    }
  }

  void sellShares(int companyIndex, int shares) {
    if (companyIndex < 0 || companyIndex >= companies.length) {
      log("Error: company[$companyIndex] doesn't exists transaction doesn't performed",
          name: 'sellShares');
      return;
    }
    if (shares > this.shares[companyIndex]) {
      log("Error: shares not enough bought", name: 'sellShares');
      shares = this.shares[companyIndex];
    }
    if (companies[companyIndex].getCurrentSharePrice() == 0) {
      log("Error:Cannot sell shares as company[$companyIndex] is bankrupt for now",
          name: 'sellShares');
      return;
    }
    companies[companyIndex].leftShares += shares;
    this.shares[companyIndex] -= shares;
    _money += (shares * companies[companyIndex].getCurrentSharePrice()).toInt();
    if (mainPlayer) balance.value = _money;
  }

  void buyShares(int companyIndex, int shares) {
    if (companyIndex < 0 || companyIndex >= companies.length) {
      log("Error: company[$companyIndex] doesn't exists transaction doesn't performed",
          name: 'buyShares');
      return;
    }
    if (companies[companyIndex].leftShares < shares) {
      log("Error: not enough shares left", name: 'buyShares');
      shares = companies[companyIndex].leftShares;
    }
    if (companies[companyIndex].getCurrentSharePrice() == 0) {
      log("Error: company[$companyIndex] is bankrupt for now",
          name: 'buyShares');
      return;
    }
    if (_money < shares * companies[companyIndex].getCurrentSharePrice()) {
      log("Error: not enough money money: $_money needed: ${shares * companies[companyIndex].getCurrentSharePrice()}",
          name: 'buyShares');
      shares = _money ~/ companies[companyIndex].getCurrentSharePrice();
    }
    _money -= (shares * companies[companyIndex].getCurrentSharePrice()).toInt();
    if (mainPlayer) balance.value = _money;
    companies[companyIndex].leftShares -= shares;
    this.shares[companyIndex] += shares;
  }

  ///Returns true if trade accepted.
  bool tradeRequest(TradeDetails tradeDetails) {
    if (!mainPlayer && turn > playerManager.mainPlayerTurn) {
      if (tradeDetails.moneyRequested <= tradeDetails.moneyOffered) {
        if (tradeDetails.cardsOffered >= tradeDetails.cardsRequested)
          return true;
        return false;
      }
      if (tradeDetails.cardsRequested > tradeDetails.cardsOffered) {
        if ((tradeDetails.moneyOffered - tradeDetails.moneyRequested) /
                (tradeDetails.cardsRequested - tradeDetails.cardsOffered) >
            (maths.max(money * 0.1, 10000))) {
          return true;
        }
        return false;
      } else if (tradeDetails.cardsRequested == tradeDetails.cardsOffered) {
        if (tradeDetails.moneyOffered >= tradeDetails.moneyRequested)
          return true;
        return false;
      } else if ((tradeDetails.moneyRequested - tradeDetails.moneyOffered) /
              (tradeDetails.cardsOffered - tradeDetails.cardsRequested) <=
          money * 0.03) return true;
    }
    return false;
  }

  ///Performs trade considering the other player as requesting trade.
  ///
  ///Trade is only performed one sided.
  void makeHalfTrade(TradeDetails tradeDetails, Player player) {
    log('making half trade', name: 'Player.halfTrade');
    log('checking if trade possible', name: 'Player.halfTrade');
    tradeDetails.checkIfTradePossible(player, this);
    log('trade possible', name: 'Player.halfTrade');
    _money += tradeDetails.moneyOffered - tradeDetails.moneyRequested;
    if (mainPlayer) balance.value = money;
    int offeringPlayer = tradeDetails.playerRequesting;
    int thisIndex = tradeDetails.playerRequested;
    int alreadyTradedCards = totalTradedCards[offeringPlayer];
    log("total cards already traded: ${totalTradedCards[offeringPlayer]}",
        name: 'Player.halfTrade');
    int numOfCards = getPossibleTradingCards(
      cardsProvider: player,
      cardsAcceptor: this,
      numOfCards: tradeDetails.cardsOffered,
      providerIndex: offeringPlayer,
      acceptorIndex: thisIndex,
    );
    for (int i = alreadyTradedCards; i < numOfCards + alreadyTradedCards; i++) {
      log("i: $i", name: 'Player.halfTrade');
      if (player.getAllCards()[i].tradedFrom != thisIndex)
        addCards([player.getAllCards()[i]],
            traded: true, tradedFrom: offeringPlayer);
      else
        i--;
    }
  }
}

extension allPlayersExtensions on List<Player> {
  void setNewCards(List<List<shareCard.Card>> playerCards,
      List<List<shareCard.Card>> processedPlayerCards) {
    for (int i = 0; i < this.length; i++) {
      this[i].setAllCards(playerCards[i]);
      this[i].setCardPrice();
      for (int j = 0; j < this[i].totalTradedCards.length; j++)
        this[i].totalTradedCards[j] = 0;
      this[i].totalBoughtCards = 0;
    }
  }
}

class PlayerManager {
  String get mainPlayerName => _allPlayers[_mainPlayerIndex].name;
  int _totalPlayers;
  int _mainPlayerIndex;
  int _totalRounds;
  int _currentRound;

  int get currentRound => _currentRound;

  set currentRound(int value) {
    _currentRound = value;
    currentRoundChanged.value = _currentRound;
  }

  int get totalRounds => _totalRounds;

  int get mainPlayerIndex => _mainPlayerIndex;

  int get totalPlayers => _totalPlayers;

  int get mainPlayerTurn => mainPlayer().turn;
  final List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.yellow,
    Colors.blue,
    Colors.pink,
    Colors.orange,
  ];
  List<Player> _allPlayers = [];

  List<Player> get allPlayers => _allPlayers;

  bool lastTurn() => mainPlayerTurn == (totalPlayers - 1);

  PlayerManager(this._totalPlayers, int turn, int totalRounds,
      {List<Player> allPlayers, int currentRound = 1})
      : this._mainPlayerIndex = turn,
        _allPlayers = allPlayers ?? [],
        this._totalRounds = totalRounds {
    this.currentRound = currentRound;
    if (allPlayers != null) {
      for (var player in allPlayers)
        if (player.mainPlayer) setValueNotifier(money: player.money);
    }
  }

  void setAllPlayersData(
    List<Map<String, dynamic>> playersMap,
    int newTotalRounds,
    int newCurrentRound,
  ) {
    assert(newTotalRounds != null &&
        newCurrentRound != null &&
        playersMap != null);
    String logName = "player/setAllPlayersData()";
    _totalRounds = newTotalRounds;
    currentRound = newCurrentRound;
    playersMap = playersMap.reversed.toList();
    _totalPlayers = playersMap.length;
    log("playersMap: ${playersMap.toString()}", name: logName);
    Player mainPlayer = _allPlayers[mainPlayerIndex];
    _allPlayers.clear();
    for (int i = 0; i < playersMap.length; i++) {
      Player player = Player.fromMap(playersMap[i], _totalPlayers);
      if (player.uuid != Network.authId)
        _allPlayers.add(player);
      else {
        log("player id: ${player.uuid}", name: logName);
        log("player name: ${player.name}", name: logName);
        mainPlayer.totalPlayers = _totalPlayers;
        if (player.turn == null)
          mainPlayer.turn = i;
        else
          mainPlayer.turn = player.turn;
        _mainPlayerIndex = i;
        _allPlayers.add(mainPlayer);
        if (player.turn !=
            mainPlayer.turn) //if database does not have correct turn;
          Network.updateMainPlayerAndRoomData();
      }
      log("$i: ${_allPlayers[i].toMap().toString()}", name: logName);
    }
  }

  void updateAllPlayersData(List<Map<String, dynamic>> allDocuments) {
    for (Map<String, dynamic> playerDataMap in allDocuments) {
      Player player = Player.fromMap(playerDataMap, totalPlayers);
      if (player.uuid != Network.authId) setPlayerData(player);
    }
  }

  void generatePlayers(List<String> playerNames) {
    if (playerNames.length != totalPlayers) {
      log("Error: playerNames String is not equal to totalPLayers",
          name: 'generatePlayers');
      int i = 1;
      while (playerNames.length < totalPlayers)
        playerNames.add("Player ${i++}");
    }
    for (int i = 0; i < totalPlayers; i++) {
      if (i == _mainPlayerIndex)
        _allPlayers.add(Player(
          playerNames[i],
          totalPlayers,
          i,
          mainPlayer: true,
        ));
      else
        _allPlayers.add(Player(playerNames[i], totalPlayers, i));
    }
    setValueNotifier();
  }

  List<String> otherPlayerNames() {
    List<String> result = [];
    for (int i = 0; i < _allPlayers.length; i++) {
      if (i != _mainPlayerIndex) result.add(_allPlayers[i].name);
    }
    return result;
  }

  void setValueNotifier({int money}) {
    balance = ValueNotifier(money ?? _allPlayers[_mainPlayerIndex].money);
  }

  void setAllPlayersValues(List<List<shareCard.Card>> playerCards,
      List<List<shareCard.Card>> processedPlayerCards) {
    _allPlayers.setNewCards(playerCards, processedPlayerCards);
  }

  ///returns -1 in case of name doesn't exist.
  int getPlayerIndex(String playerName) {
    for (int i = 0; i < _allPlayers.length; i++)
      if (_allPlayers[i].name == playerName) return i;
    return -1;
  }

  Future<void> buyCards(Player player, int numOfCards) async {
    int index;
    for (int i = 0; i < _allPlayers.length; i++)
      if (_allPlayers[i].name == player.name) {
        index = i;
        break;
      }
    if (index == null) throw '${player.name} doesn\'t exist';
    _allPlayers[index].buyCards(numOfCards);
    if (online) {
      await Network.updateMainPlayerAndRoomData();
    }
  }

  ///Here this is the different function to set valueNotifier as in case of
  ///multiplayer there might not be need of calling generatePLayers
  bool tradeProcessOffline(TradeDetails tradeDetails) {
    int requestingPlayerIndex = tradeDetails.playerRequesting;
    int requestedPlayerIndex = tradeDetails.playerRequested;
    if (requestingPlayerIndex < 0 ||
        requestingPlayerIndex >= _allPlayers.length) {
      throw "Error: trade requseter doesn't exist, trade doesn't performed";
    }
    if (requestedPlayerIndex < 0 ||
        requestedPlayerIndex >= _allPlayers.length) {
      throw "Error: trade requseted player doesn't exist, trade doesn't performed";
    }
    if (_allPlayers[requestedPlayerIndex].tradeRequest(tradeDetails)) {
      _allPlayers[requestingPlayerIndex].makeHalfTrade(
        tradeDetails.detailsForRequestingPlayer,
        _allPlayers[requestedPlayerIndex],
      );
      _allPlayers[requestedPlayerIndex].makeHalfTrade(
        tradeDetails.detailsForRequestedPlayer,
        _allPlayers[requestingPlayerIndex],
      );
      return true;
    }
    return false;
  }

  Future<void> tradeProcessOnline(TradeDetails tradeDetails) async {
    await checkOnlineTradeIfPossible(tradeDetails);
    await Network.createDocument(
            "$kAlertDocName/${_allPlayers[tradeDetails.playerRequested].uuid}/${Network.authId}",
            TradeAlert(tradeDetails).toMap())
        .catchError((err) => throw err);
  }

  ///throws error if trade not possible
  Future<void> checkOnlineTradeIfPossible(TradeDetails tradeDetails) async {
    String requestedId = getPlayerId(index: tradeDetails.playerRequested);
    var requestedMap =
        await Network.getData('$playerDataCollectionPath/$requestedId');
    Player requested = Player.fromMap(requestedMap, 2);
    Player requester = mainPlayer();
    tradeDetails.checkIfTradePossible(requester, requested);
  }

  ///provide either [index] of player or [name] of player. In case of both, index will
  ///be given priority.
  ///
  ///It is required to provide at least one of them.
  String getPlayerId({int index, String name}) {
    assert(index != null || name != null);
    if (index == null && name != null) index = getPlayerIndex(name);
    if (index == -1 && name != null) throw 'name does not exist';
    if (index >= 0 && index < totalPlayers)
      return _allPlayers[index].uuid;
    else
      throw 'index out of range';
  }

  int checkNumOfTradingCards(int fromPlayer, int toPlayer, int numOfCards) {
    String logName = "checkNumOfTradingCards";
    log("to: $toPlayer, from: $fromPlayer, numOfCards: $numOfCards",
        name: logName);
    return getPossibleTradingCards(
      cardsProvider: _allPlayers[fromPlayer],
      cardsAcceptor: _allPlayers[toPlayer],
      numOfCards: numOfCards,
      providerIndex: fromPlayer,
      acceptorIndex: toPlayer,
    );
  }

  void otherPlayersTurn(bool beforeMainPlayer) {
    List<Player> players = [];
    players.length = totalPlayers;
    for (int i = 0; i < _allPlayers.length; i++) {
      players[_allPlayers[i].turn] = _allPlayers[i];
    }
    if (beforeMainPlayer)
      for (int i = 0; i < mainPlayerTurn; i++) {
        players[i].autoPlay();
      }
    else
      for (int i = totalPlayers - 1; i > mainPlayerTurn; i--)
        players[i].autoPlay();
    yourTurn = false;
  }

  void incrementPlayerTurns() {
    for (int i = 0; i < _allPlayers.length; i++)
      _allPlayers[i].incrementPlayerTurn();
    if (!online) currentTurnChanged.value = mainPlayerTurn;
  }

  Player mainPlayer() {
    return _allPlayers[_mainPlayerIndex];
  }

  void setMainPlayerValues(Player mainPlayer) {
    _allPlayers[_mainPlayerIndex] = mainPlayer;
    balance.value = mainPlayer.money;
    Network.updateMainPlayerAndRoomData();
  }

  void setOfflineMainPlayerData(Player mainPlayer) {
    _allPlayers[_mainPlayerIndex] = mainPlayer;
    balance.value = mainPlayer.money;
  }

  void setPlayerData(Player player) {
    for (int i = 0; i < _allPlayers.length; i++)
      if (_allPlayers[i].uuid == player.uuid) {
        playerDataChanged.value++;
        _allPlayers[i] = player;
        return;
      }
  }

  int getPlayerMoney(int playerIndex) {
    if (playerIndex >= 0 && playerIndex < totalPlayers)
      return _allPlayers[playerIndex].money;
    else
      return -1;
  }

  ///Graph Data
  List<PieChartData> allPlayersPieChartDataForCompany(int companyIndex) {
    List<PieChartData> result = [];
    for (int i = 0; i < _allPlayers.length; i++) {
      if (_allPlayers[i].shares[companyIndex] > 0)
        result.add(PieChartData(_allPlayers[i].name,
            _allPlayers[i].shares[companyIndex], colors[i]));
    }
    result.add(PieChartData(companies[companyIndex].name,
        companies[companyIndex].leftShares, Colors.white12));
    return result;
  }

  ///if both player and playerIndex is provided than player will be considered
  ///over playerIndex.
  ///If neither are provided than it returns null;
  List<BarChartData> playerBarGraphAllSharesData(
      {Player player, int playerIndex}) {
    if (player == null && playerIndex == null) return null;
    if (player == null) player = _allPlayers[playerIndex];
    List<BarChartData> result = [];
    for (int i = 0; i < player.shares.length; i++)
      result.add(BarChartData(companies[i].name, player.shares[i].toDouble()));
    return result;
  }

  List<BarChartData> allPlayersAssetsBarGraph() {
    List<BarChartData> result = [];
    List<Player> players = [];
    players.length = totalPlayers;

    for (Player player in _allPlayers) {
      if (players[player.turn] == null)
        players[player.turn] = player;
      else
        players.add(player);
    }
    for (Player player in players) {
      if (player != null) result.add(player.totalAssets());
    }
    return result;
  }

  List<Map<String, dynamic>> allPlayersDataMap() {
    List<Map<String, dynamic>> playersData = [];
    for (Player player in _allPlayers) {
      playersData.add(player.toMap());
    }
    return playersData;
  }
}
