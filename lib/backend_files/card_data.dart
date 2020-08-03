import 'dart:math';
import 'dart:developer' as dev;
import 'company.dart';

class Card {
  final int companyNum;
  final int shareValueChange;
  final bool traded;
  final int tradedFrom;
  final bool bought;

  Card(
    this.companyNum,
    this.shareValueChange, {
    this.traded: false,
    this.tradedFrom,
    this.bought: false,
  });

  Card.fromMap(Map<String, dynamic> map)
      : companyNum = map["companyNum"],
        shareValueChange = map["shareValueChange"],
        traded = map["traded"],
        tradedFrom = map["tradedFrom"],
        bought = map["bought"];

  static List<Map<String, dynamic>> allCardsToMap(List<Card> cards) {
    List<Map<String, dynamic>> result = [];
    for (Card card in cards) result.add(card.toMap());
    return result;
  }

  static List<Card> allCardsFromMap(List<dynamic> maps) {
    if (maps == null) return null;
    List<Card> cards = [];
    for (Map<String, dynamic> map in maps) cards.add(Card.fromMap(map));
    return cards;
  }

  Map<String, dynamic> toMap() => {
        "companyNum": companyNum,
        "shareValueChange": shareValueChange,
        "traded": traded,
        "tradedFrom": tradedFrom,
        "bought": bought,
      };
}

class CardBank {
  List<Card> _allCards = [];
  List<Card> _processedCards = [];
  List<Card> _buyableCards = [];
  List<List<Card>> _eachPlayerCards = [[]];
  List<List<Card>> _eachPlayerProcessedCards = [[]];
  final int totalPlayers;
  final List<Company> allCompanies;

  CardBank(this.totalPlayers, this.allCompanies);

  CardBank.fromMap(Map<String, dynamic> map)
      : _allCards = Card.allCardsFromMap(map['_allCards']),
        _processedCards = Card.allCardsFromMap(map['_processedCards']),
        _buyableCards = Card.allCardsFromMap(map['_buyableCards']),
        _eachPlayerCards = listOfListOfCardsFromMap(map['_eachPlayerCards']),
        _eachPlayerProcessedCards =
            listOfListOfCardsFromMap(map['_eachPlayerProcessedCards']),
        totalPlayers = map['totalPlayers'],
        allCompanies = Company.allCompaniesFromMap(map['allCompanies']);

  Map<String, dynamic> toMap() => {
        '_allCards': Card.allCardsToMap(_allCards),
        '_processedCards': Card.allCardsToMap(_processedCards),
        '_buyableCards': Card.allCardsToMap(_buyableCards),
        '_eachPlayerCards': listOfListOfCardsToMap(_eachPlayerCards),
        '_eachPlayerProcessedCards':
            listOfListOfCardsToMap(_eachPlayerProcessedCards),
        'totalPlayers': totalPlayers,
        'allCompanies': Company.allCompaniesToMap(allCompanies),
      };

  static List<List<Map<String, dynamic>>> listOfListOfCardsToMap(
      List<List<Card>> cards) {
    List<List<Map<String, dynamic>>> maps = [];
    for (var subCards in cards) maps.add(Card.allCardsToMap(subCards));
    return maps;
  }

  static List<List<Card>> listOfListOfCardsFromMap(List<dynamic> maps) {
    List<List<Card>> cards = [];
    for (var map in maps) cards.add(Card.allCardsFromMap(map));
    return cards;
  }

  int getCardPrice(int playerBudget) {
    int maxIndex = 0;
    for (int i = 0; i < _processedCards.length; i++)
      if (_processedCards[maxIndex].shareValueChange <
          _processedCards[i].shareValueChange) maxIndex = i;
    if (_processedCards[maxIndex].shareValueChange <= 0) {
      maxIndex = null;
      dev.log('Cards not for sale', name: 'getCardPrice');
      throw "Cards not for Sale";
    }
    return (_processedCards[maxIndex].shareValueChange * playerBudget) ~/
        (_buyableCards.length * 50);
  }

  List<Card> get buyableCards => _buyableCards;

  List<Card> getBuyableCard(int start, int numOfCards) {
    List<Card> cards = [];
    for (int i = start; i < _buyableCards.length; i++) {
      cards.add(_buyableCards[i]);
      if (cards.length == numOfCards) return cards;
    }
    return cards;
  }

  int getBuyableCardsLength() {
    return _buyableCards.length;
  }

  List<List<Card>> getEachPlayerCards() {
    return _eachPlayerCards;
  }

  List<List<Card>> getEachPlayerProcessedCards() {
    return _eachPlayerProcessedCards;
  }

  List<Card> getProcessedCards() {
    return _processedCards;
  }

  List<Card> getMainPlayerCards() {
    return _eachPlayerCards[0];
  }

  List<Card> getMainPlayerProcessedCards() {
    return _eachPlayerProcessedCards[0];
  }

  void generateAllCards({int totalPlayers}) {
    if(totalPlayers == null)
      totalPlayers = this.totalPlayers;
    dev.log("generating cards", name: "generateAllCards");

    ///clearing all lists
    _allCards.clear();
    _processedCards.clear();
    _eachPlayerProcessedCards.clear();
    _eachPlayerCards.clear();
    _buyableCards.clear();

    ///Generating total number of cards
    int totalCards = totalPlayers * 10 + [60, totalPlayers * 20].reduce(min);
    int cardsGenerated = 0;

    ///generating all cards
    var rand = Random();
    outerLoop:
    for (int i = 0; i < allCompanies.length; i++) {
      for (int j = 0; j <= totalCards / allCompanies.length; j++) {
        int shareChangeValue;
        int outerRange = 101;
        while (true) {
          int temp = rand.nextInt(outerRange * 2);
          temp -= outerRange;
          double checkingValue = (19 * exp(-pow((temp / 25), 6)) + 1) *
              5 *
              exp(-pow(temp / 100, 4));
          int checker = rand.nextInt(101);
          if (checker <= checkingValue) {
            shareChangeValue = temp;
            break;
          } else
            outerRange = outerRange > 30 ? outerRange - 5 : outerRange;
        }
        _allCards.add(Card(i, shareChangeValue));
        if (++cardsGenerated >= totalCards) break outerLoop;
      }
    }

    ///adding processed cards
    List<int> tempArr = [];
    Set<int> addedCards = Set<int>();
    for (int i = 0; i < allCompanies.length; i++) tempArr.add(0);
    for (int i = 0; i < _allCards.length; i++)
      tempArr[_allCards[i].companyNum] += _allCards[i].shareValueChange;
    for (int i = 0; i < tempArr.length; i++)
      _processedCards.add(Card(i, tempArr[i]));

    ///adding player cards
    for (int i = 0; i < totalPlayers; i++) {
      _eachPlayerCards.add([]);
      _eachPlayerProcessedCards.add([]);
      var tempMap = Map<int, int>();
      for (int j = 0; j < 10; j++) {
        int temp;
        while (true) {
          temp = rand.nextInt(_allCards.length);
          if (addedCards == null || !addedCards.contains(temp)) {
            break;
          }
        }
        _eachPlayerCards[i].add(_allCards[temp]);
        addedCards.add(temp);
        if (tempMap != null && tempMap.containsKey(_allCards[temp].companyNum))
          tempMap[_allCards[temp].companyNum] +=
              _allCards[temp].shareValueChange;
        else
          tempMap[_allCards[temp].companyNum] =
              _allCards[temp].shareValueChange;
      }
      tempMap.forEach(
        (key, value) => _eachPlayerProcessedCards[i].add(Card(key, value)),
      );
    }

    ///adding buyable cards
    while (
        _buyableCards.length <= (_allCards.length - (totalPlayers * 10)) / 2) {
      int index = rand.nextInt(_allCards.length);
      if (!addedCards.contains(index)) _buyableCards.add(_allCards[index]);
    }
  }

  List<Company> updateCompanyPrices() {
    for (int i = 0; i < allCompanies.length; i++)
      allCompanies[i].setCurrentSharePrice(_processedCards[i].shareValueChange);
    return allCompanies;
  }
}
