import 'dart:developer';
import 'backend_files/card_data.dart' as shareCard;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'json_classes/json_classes.dart';
import 'network/network.dart';
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

enum roundLoadingStatus {
  calculationStarted,
  calculationInProgress,
  calculationCompleted,
  startingNextRound,
  startedNextRound,
}

String getPageTitle (StockPage page) {
  switch (page) {
    case StockPage.home:
      {
        return "Home StockPage";
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

///Streams
final playerTurnStream = Network.firestore
    .document("${Network.roomName}/$playersTurnDocumentName")
    .snapshots();

final playerTurnSubscription = playerTurnStream.listen((playerTurnDocument) {
  PlayerTurn playerTurn = PlayerTurn.fromMap(playerTurnDocument.data);
  if (playerTurn.turn == playerManager.mainPlayerTurn) yourTurn = true;
  yourTurn = false;
});

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
bool fromCompanyPage = false;
bool currentTurn = false;

///constant values
final kRupeeChar = "\u20b9";
final kConnectionPageName = "/connection_page";
final kCompanyPageName = "/company_page";
final kOnlineRoomName = "/online_room";
final kJoinRoomName = "/join_room";
final kLoginPageName =  "/login_page";
final kEnterPlayersPageName = "/enter_players";
final kRoomOptionsPageName = "/room_options";
final kLoadingPageName = '/loading_page';

final String roomDataDocumentName = "room_data";
final String nextRoundStatusDocName = "round_loading_status";
final String alertDocumentName = "alert";

final String playerDataDocumentName = "players_data";

String get playerDataCollectionPath =>
    "$roomDataDocumentName/$playerDataDocumentName";

final String companiesDataDocumentName = "companies_data";

String get companiesDataDocumentPath => companiesDataDocumentName;

final String playersFullDataDocumentName = "Players_full_data";

String get playerFullDataCollectionPath =>
    "$roomDataDocumentName/$playersFullDataDocumentName";

final String playersTurnDocumentName = "players_turn";

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
var currentPage = ValueNotifier (StockPage.start);

///variables
bool online = false;
bool yourTurn = false;
bool roomCreator = false;
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
  color: Color(0xFF303030),
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
  color: Color(0xff121212),
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
void startGame(int value){
  cardBank = shareCard.CardBank(value, companies);
  playerManager = PlayerManager(value, 0);
  currentPage.value = StockPage.home;
  playerManager.generatePlayers([tempPlayerName]);
  startNextRound();
}

///Start of each round
void startNextRound() {
  mainPlayerCards.value = 0;
  cardBank.generateAllCards();
  playerManager.setAllPlayersValues(
      cardBank.getEachPlayerCards(), cardBank.getEachPlayerProcessedCards());
  if (!online) {
    playerManager.otherPlayerTurns();
  }
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
