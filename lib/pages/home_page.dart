import 'package:stockexchange/components/components.dart';
import 'package:flutter/material.dart';
import 'package:stockexchange/global.dart';
import 'package:stockexchange/menu_pages/menu_pages.dart';
import 'package:stockexchange/menu_pages/processed_cards_page.dart';
import 'package:stockexchange/network/network.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  bool runCheckAlert = true;

  @override
  Widget build(BuildContext context) {
    homePageState = this;
    screen = MediaQuery.of(context);
    if (screen.orientation == Orientation.portrait) {
      screenWidth = screen.size.width;
      screenHeight = screen.size.height;
    } else {
      screenWidth = screen.size.height;
      screenHeight = screen.size.width;
    }
    if (runCheckAlert && Network.roomName != "null") {
      checkAndShowAlert(context);
      runCheckAlert = false;
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        image: DecorationImage(
          image: screen.orientation == Orientation.portrait
              ? AssetImage("images/back4.jpg")
              : AssetImage("images/back.jpg"),
          fit: BoxFit.fitWidth,
          alignment: Alignment.topCenter,
        ),
      ),
      child: Scaffold(
        body: Container(
          child: CustomScrollView(
            slivers: <Widget>[
              backButtonActions(context),
              ValueListenableBuilder(
                valueListenable: currentPage,
                builder: (context, value, _) {
                  if (value == StockPage.home) {
                    fromCompanyPage = false;
                    return ValueListenableBuilder(
                      valueListenable: homeListChanged,
                      builder: (context, value, _) {
                        return SliverList(
                          delegate: SliverChildListDelegate(
                            homeList(),
                          ),
                        );
                      },
                    );
                  } else if (value == StockPage.cards) {
                    return ProcessedCardsPage();
                  } else if (value == StockPage.buy) {
                    print("changing to StockPage.buy");
                    return ShareMarket.buyPage(context);
                  } else if (value == StockPage.sell) {
                    print("changing to StockPage.sell");
                    return ShareMarket.sellPage(context);
                  } else if (value == StockPage.trade) {
                    return TradePage();
                  } else if (value == StockPage.buyCards) {
                    return BuyCardsPage();
                  } else if (value == StockPage.barChart)
                    return AllSharesBarChartMenu();
                  else if (value == StockPage.totalAssets)
                    return TotalAssetsMenuPage();
                  else if (value == StockPage.start)
                    return StartingPage();
                  else
                    return NextRoundPage();
                },
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
    );
  }
}

List<Widget> homeList() {
  List<Widget> result = [];
  for (int i = 0; i < companies.length; i++) {
    List<double> temp = companies[i].getAllSharePrice();
    result.add(CompanySlates(
      currentCompany: companies[i],
      sharePriceChange:
          temp.length >= 2 ? temp.last - temp[temp.length - 2] : 0,
    ));
  }
  return result;
}
