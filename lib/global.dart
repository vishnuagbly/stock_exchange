import 'dart:developer';
import 'package:stockexchange/network/offline_database.dart';

import 'backend_files/card_data.dart' as shareCard;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'backend_files/company.dart';
import 'backend_files/card_data.dart';
import 'backend_files/player.dart';

///enumerations
enum StockPage {
  home,
  cards,
  buy,
  sell,
  trade,
  buyCards,
  next,
  barChart,
  start,
  totalAssets,
}

enum LoadingStatus {
  timeOut,
  gettingData,
  nextRoundError,
  calculationStarted,
  calculationInProgress,
  calculationCompleted,
  startingNextRound,
  startedNextRound,
  trading,
  tradingError,
  tradeComplete,
}

String getPageTitle(StockPage page) {
  switch (page) {
    case StockPage.home:
      {
        return "Home Page";
      }
    case StockPage.cards:
      {
        return "Cards";
      }
    case StockPage.buy:
      {
        return "Buy Shares";
      }
    case StockPage.sell:
      {
        return "Sell Shares";
      }
    case StockPage.trade:
      {
        return "Trade";
      }
    case StockPage.buyCards:
      {
        return "Buy Extra Cards";
      }
    case StockPage.barChart:
      {
        return "Your Shares";
      }
    case StockPage.start:
      {
        return "Enter Details";
      }
    case StockPage.totalAssets:
      {
        return "Everyone's Assets";
      }
    default:
      {
        return "Nothing";
      }
  }
}

///screen data
MediaQueryData screen;
double screenHeight, screenWidth;

///company data
var companies = [
  Company("Reliance", 200000, 75),
  Company("Google", 200000, 120),
  Company("StarBucks", 200000, 50),
  Company("Tesla", 200000, 55),
  Company("Tisco", 200000, 40),
  Company("Apple", 200000, 100),
];

int getCompanyIndex(String name) {
  log("company name: $name", name: "global/geCompanyIndex");
  for (int i = 0; i < companies.length; i++) {
    if (companies[i].name == name) return i;
  }
  return -1;
}

Company getCompany(String name) {
  return companies
      .firstWhere((e) => e.name.toLowerCase() == name.toLowerCase());
}

Company pageCompany = companies[0];
String buyPageInitialDropDownValue = companies[0].name;
String sellPageInitialDropDownValue = companies[1].name;
State homePageState;
GlobalKey homePageGlobalKey = GlobalKey();
bool fromCompanyPage = false;

///constant values
const kRupeeChar = "\u20b9";
const kConnectionPageName = "/connection_page";
const kHomePageName = '/home_page';
const kCompanyPageName = "/company_page";
const kCreateOnlineRoomName = "/create_online_room";
const kJoinRoomName = "/join_room";
const kLoginPageName = "/login_page";
const kEnterPlayersPageName = "/enter_players";
const kRoomOptionsPageName = "/room_options";
const kLoadingPageName = '/loading_page';
const kGameFinishedPageName = '/game_finished';
const String kRoomDataDocName = "room_data";
const String kLoadingStatusDocName = "loading_status";
const String kAlertDocName = "alert";
const String kPlayerDataDocName = "players_data";
const String kRoundsDocName = 'rounds';
const Color kPrimaryColor = Color(0xFF121212);
const Color kSecondaryColor = Color(0xFF252525);

String get playerDataCollectionPath =>
    "$kRoomDataDocName/$kPlayerDataDocName";

const String kCompaniesDataDocName = "companies_data";

String get companiesDataDocumentPath => kCompaniesDataDocName;

const String playersFullDataDocName = "Players_full_data";

String get playerFullDataCollectionPath =>
    "$kRoomDataDocName/$playersFullDataDocName";

const String playersTurnsDocName = "players_turn";

///Alert Dialog Constants
const kAlertDialogBackgroundColorCode = 0xFF202020;
const kAlertDialogBorderRadius = 10.0;
const kAlertDialogElevation = 30.0;
final kAlertDialogTitleTextSize = screenWidth * 0.06;
final kAlertDialogButtonTextSize = screenWidth * 0.04;

///value notifiers
ValueNotifier<int> balance;
ValueNotifier<int> mainPlayerCards = ValueNotifier(0);
ValueNotifier<int> homeListChanged = ValueNotifier(0);
ValueNotifier<int> playerDataChanged = ValueNotifier(0);
var currentTurnChanged = ValueNotifier<int>(null);
var currentPage = ValueNotifier(StockPage.start);
var currentRoundChanged = ValueNotifier<int>(null);
var mainPlayerTurnChanged = ValueNotifier<int>(null);

void resetAllValues() {
  balance = null;
  mainPlayerCards.value = 0;
  homeListChanged.value = 0;
  playerDataChanged.value = 0;
  currentTurnChanged.value = null;
  currentPage.value = StockPage.start;
  currentRoundChanged.value = null;
  mainPlayerTurnChanged.value = null;
  online = false;
  yourTurn = false;
  gameFinished = false;
  roomCreator = false;
  tempPlayerName = '';
  playerManager = null;
  cardBank = null;
  companies = [
    Company("Reliance", 200000, 75),
    Company("Google", 200000, 120),
    Company("StarBucks", 200000, 50),
    Company("Tesla", 200000, 55),
    Company("Tisco", 200000, 40),
    Company("Apple", 200000, 100),
  ];
}

///variables
bool online = false;
bool yourTurn = false;
bool roomCreator = false;
bool gameFinished = false;
String tempPlayerName = "";

///constant styles and decorations
final kSlateSharePriceStyle = TextStyle(
  fontSize: screenWidth * 0.065,
);

final kBuyShareButtonTextStyle = TextStyle(
  color: Colors.blue,
  fontSize: screenWidth * 0.03,
);

final kBuyShareButtonDecoration = BoxDecoration(
  color: kSecondaryColor,
  borderRadius: BorderRadius.all(Radius.circular(50.0)),
  boxShadow: [
    BoxShadow(
      color: Color(0xFF050505),
      offset: Offset(0.0, 2.0),
      blurRadius: 3,
    ),
  ],
);

final kSlateBackDecoration = BoxDecoration(
  borderRadius: BorderRadius.all(Radius.circular(10)),
  color: kPrimaryColor,
);

BoxDecoration kSquareBackDecoration(MediaQueryData data) {
  return BoxDecoration(
    image: DecorationImage(
      image: AssetImage(
        data.orientation == Orientation.portrait
            ? "images/back4.jpg"
            : "images/back.jpg",
      ),
      fit: BoxFit.fitWidth,
      alignment: Alignment.topCenter,
    ),
  );
}

final kSlateCompanyNameStyle = GoogleFonts.openSans(
  textStyle:
      TextStyle(fontSize: screenWidth * 0.07, fontWeight: FontWeight.bold),
);

///Card bank
CardBank cardBank;

///Players
PlayerManager playerManager;

///start game
void startGame(int totalPlayers, int totalRounds) {
  cardBank = shareCard.CardBank(totalPlayers, companies);
  playerManager = PlayerManager(totalPlayers, 0, totalRounds);
  currentPage.value = StockPage.home;
  playerManager.generatePlayers([tempPlayerName]);
  cardBank.generateAllCards();
  mainPlayerCards.value = 0;
  playerManager.setAllPlayersValues(
      cardBank.getEachPlayerCards(), cardBank.getEachPlayerProcessedCards());
  if (!online) {
    playerManager.otherPlayersTurn(true);
    currentTurnChanged.value = playerManager.mainPlayerTurn;
  }
  mainPlayerTurnChanged.value = playerManager.mainPlayerTurn;
}

void startSavedGame() {
  cardBank = Phone.savedCardBank;
  List<Player> players = Phone.players;
  int turn;
  for (int i = 0; i < players.length; i++) {
    var player = players[i];
    if (player.mainPlayer) turn = i;
  }
  playerManager = PlayerManager(
    players.length,
    turn,
    Phone.totalRounds,
    allPlayers: players,
    currentRound: Phone.currentRound,
  );
  currentPage.value = StockPage.home;
  companies = Phone.allCompanies;
  mainPlayerTurnChanged.value = playerManager.mainPlayerTurn;
  currentTurnChanged.value = playerManager.mainPlayerTurn;
  currentRoundChanged.value = Phone.currentRound;
  playerManager.otherPlayersTurn(true);
}

///Start of each round
void startNextRound() {
  if (!online) {
    playerManager.otherPlayersTurn(false);
  }
  mainPlayerCards.value = 0;
  playerDataChanged.value = 0;
  cardBank.generateAllCards();
  playerManager.setAllPlayersValues(
      cardBank.getEachPlayerCards(), cardBank.getEachPlayerProcessedCards());
  if (!online) {
    playerManager.currentRound += 1;
    playerManager.incrementPlayerTurns();
    playerManager.otherPlayersTurn(true);
  }
  mainPlayerTurnChanged.value = playerManager.mainPlayerTurn;
}

///Chart data
charts.Color convertColor(Color color) {
  return charts.Color(
    r: color.red,
    g: color.green,
    b: color.blue,
    a: color.alpha,
  );
}
