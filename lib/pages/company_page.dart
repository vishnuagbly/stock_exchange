import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stockexchange/backend_files/backend_files.dart';
import 'package:stockexchange/components/components.dart';
import 'package:stockexchange/charts/pie_chart.dart';
import 'package:stockexchange/charts/point_line_chart.dart';
import 'package:stockexchange/global.dart';
import 'package:stockexchange/main.dart';
import 'package:flutter/material.dart';
import 'package:stockexchange/backend_files/card_data.dart' as shareCard;
import 'package:stockexchange/network/network.dart';

class CompanyPage extends StatefulWidget {
  final Company company;

  CompanyPage(this.company);

  @override
  _CompanyPageState createState() => _CompanyPageState();
}

class _CompanyPageState extends State<CompanyPage> {
  String pointGraphButtonString = "All Rounds";

  List<Widget> cardList(List<shareCard.Card> cards) {
    List<ShareCard> result = [];
    for (int i = 0; i < cards.length; i++)
      if (companies[cards[i].companyNum].name == widget.company.name)
        result.add(ShareCard(card: cards[i], hero: false));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context);
    if (screen.orientation == Orientation.portrait) {
      screenWidth = screen.size.width;
      screenHeight = screen.size.height;
    } else {
      screenWidth = screen.size.height;
      screenHeight = screen.size.width;
    }

    List<ShareCard> shareCards =
        cardList(playerManager.mainPlayer().getAllCards());

    return ScrollConfiguration(
      behavior: MyBehavior(),
      child: WillPopScope(
        onWillPop: () {
          if (currentPage.value != StockPage.cards) currentPage.value = StockPage.home;
          Navigator.pop(context);
          return Future<bool>.value(false);
        },
        child: Container(
          color: Colors.black,
          child: Stack(
            children: <Widget>[
              Container(
                height: screenWidth,
                decoration: kSquareBackDecoration(screen),
              ),
              Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  title: Text("\t" + widget.company.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.05,
                      )),
                  elevation: 0.0,
                  backgroundColor: Color(0x00),
                  actions: <Widget>[
                    AppBarActions(),
                    IconButton(
                      icon: Icon(
                        Icons.info_outline,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return MainAlertDialog(
                                title: "Company Page Help",
                                content: CompanyPageHelp(),
                              );
                            });
                      },
                    ),
                  ],
                ),
                body: SingleChildScrollView(
                  child: Stack(
                    children: <Widget>[
                      Center(
                        child: Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(
                                top: screenHeight * 0.2,
                              ),
                              padding: EdgeInsets.only(
                                top: 80,
                              ),
                              width: screen.orientation == Orientation.portrait
                                  ? screenWidth * 0.93
                                  : screenHeight * 0.8,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20.0),
                                ),
                                color: Color(0xFF121212),
                              ),
                              child: CompanyStats(widget.company),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10.0),
                              constraints: BoxConstraints(
                                maxWidth: screenHeight * 0.8,
                              ),
                              child: GridView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      screen.orientation == Orientation.portrait
                                          ? 2
                                          : (screenHeight * 1.6) ~/ screenWidth,
                                  childAspectRatio: 0.75,
                                ),
                                itemCount: shareCards.length,
                                itemBuilder: (context, index) {
                                  List<Widget> cards = shareCards;
                                  return cards[index];
                                },
                              ),
                            ),
                          ],
                          mainAxisAlignment: MainAxisAlignment.center,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: screenHeight * 0.12,
                        ),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(100.0),
                              ),
                              color: Color(0xFF070707),
                            ),
                            padding: EdgeInsets.all(10),
                            height: 150,
                            width: 150,
                            child: Hero(
                                tag: widget.company.name.toLowerCase(),
                                child: Image.asset(
                                  "images/${widget.company.name}.png",
                                  fit: BoxFit.fill,
                                )),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

List<Widget> printPieChartLabels(List<PieChartData> sampleData) {
  List<Widget> result = [];
  for (int i = 0; i < sampleData.length; i++) {
    result.add(Label(sampleData[i]));
    result.add(
      SizedBox(
        height: 5,
      ),
    );
  }
  return result;
}

class Label extends StatelessWidget {
  final PieChartData data;

  Label(this.data);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: screenWidth * 0.02,
          height: screenWidth * 0.02,
          color: Color.fromARGB(
              data.color.a, data.color.r, data.color.g, data.color.b),
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          flex: 10,
          child: Text(
            "${data.label}: ${data.part}",
            style: TextStyle(
              fontSize: screenWidth * 0.035,
            ),
          ),
        ),
      ],
    );
  }
}

class CompanyStats extends StatefulWidget {
  final Company company;

  CompanyStats(this.company);

  @override
  _CompanyStatsState createState() => _CompanyStatsState(company);
}

class _CompanyStatsState extends State<CompanyStats> {
  final String widgetName = "_CompanyStatsState";
  int totalPointsToShow = 5;
  String pointGraphButtonString = "All Rounds";
  Company company;
  Stream<DocumentSnapshot> stream =
      Network.getDocumentStream(Network.companiesDataDocumentName);
  StreamSubscription<DocumentSnapshot> companiesSubscription;

  _CompanyStatsState(this.company) {
    log("constructor", name: widgetName);
    checkForChangeInCompaniesStats();
  }

  @override
  Widget build(BuildContext context) {
    log("build method", name: widgetName);
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            "Share Value: $kRupeeChar" +
                company.getCurrentSharePrice().toString(),
            style: TextStyle(
              fontSize: screenWidth * 0.04,
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 200,
                  child: PointLineChart(
                      pointLineData(company, totalPointsToShow), true),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    InkWell(
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: kBuyShareButtonDecoration,
                        child: Text(
                          pointGraphButtonString,
                          style: kBuyShareButtonTextStyle,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          if (totalPointsToShow == 5) {
                            totalPointsToShow =
                                company.getAllSharePrice().length;
                            pointGraphButtonString = "Last 5";
                          } else {
                            totalPointsToShow = 5;
                            pointGraphButtonString = "All Rounds";
                          }
                        });
                      },
                    ),
                  ],
                ),
                Container(
                  height: 50,
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    "Total Shares: 100",
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                    ),
                  ),
                ),
                pieChartSection(context),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              BuySharesButton(
                currentCompany: company,
                alignment: Alignment.center,
                pagePop: true,
              ),
              SizedBox(
                width: 10,
              ),
              BuySharesButton(
                currentCompany: company,
                alignment: Alignment.center,
                pagePop: true,
                sellButton: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    companiesSubscription.cancel();
  }

  Widget pieChartSection(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Network.getCollectionStream(Network.playerDataCollectionPath),
      builder: (context, snapshot) {
        if (snapshot.data != null && snapshot.data.documents.length > 0) {
          List<Map<String, dynamic>> players = [];
          for (DocumentSnapshot document in snapshot.data.documents)
            players.add(document.data);
          playerManager.updateAllPlayersData(players);
        }
        return Row(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 200,
                child: PieChart(
                    pieChartSampleData(
                        playerManager.allPlayersPieChartDataForCompany(
                            getCompanyIndex(company.name))),
                    true),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              flex: 2,
              child: Center(
                child: Column(
                  children: printPieChartLabels(
                    playerManager.allPlayersPieChartDataForCompany(
                        getCompanyIndex(company.name)),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void checkForChangeInCompaniesStats() {
    companiesSubscription = stream.listen((DocumentSnapshot snapshot) async {
      log("companies values changed", name: widgetName);
      if (snapshot.data != null) {
        List<Company> allCompanies =
            Company.allCompaniesFromMap(snapshot.data["companies"]);
        Company newCompanyValue;
        for (Company comp in allCompanies) {
          if (comp.name == company.name) newCompanyValue = comp;
        }
        setState(() {
          company = newCompanyValue;
        });
      } else
        log("snapshot empty", name: widgetName);
    });
  }
}
