import 'package:flutter/material.dart';
import 'package:stockexchange/components/components.dart';
import 'package:stockexchange/global.dart';
import 'dart:io';
import 'menu_slate.dart';
import 'app_bar_leading_arrow.dart';
import 'package:stockexchange/Icons/custom_icon_icons.dart';
import 'app_bar_actions.dart';
import 'locked_menu_options.dart';

WillPopScope backButtonActions(BuildContext context) {
  return WillPopScope(
    onWillPop: () {
      if (currentPage.value != StockPage.home && currentPage.value != StockPage.start) {
        if (fromCompanyPage)
          Navigator.of(context).pushNamed("/company_page");
        else
          currentPage.value = StockPage.home;
      }
      else if (currentPage.value == StockPage.start) {
        Navigator.pop(context);
      }
      else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(kAlertDialogBorderRadius),
                  ),
                ),
                elevation: kAlertDialogElevation,
                backgroundColor: Color(kAlertDialogBackgroundColorCode),
                title: Text(
                  "ARE YOU SURE TO EXIT",
                  style: TextStyle(
                    fontSize: kAlertDialogTitleTextSize,
                    fontFamily: "Roboto",
                  ),
                ),
                actions: <Widget>[
                  FlatButton(
                    color: Colors.transparent,
                    child: Text(
                      "YES",
                      style: TextStyle(
                        fontSize: kAlertDialogButtonTextSize,
                        color: Colors.teal,
                      ),
                    ),
                    onPressed: () {
                      exit(0);
                    },
                  ),
                  FlatButton(
                    color: Colors.transparent,
                    child: Text(
                      "NO",
                      style: TextStyle(
                        fontSize: kAlertDialogButtonTextSize,
                        color: Colors.teal,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            });
      }
      return Future<bool>.value(false);
    },
    child: ValueListenableBuilder(
      valueListenable: currentPage,
      builder: (context, value, _) {
        return SliverAppBar(
          pinned: true,
          leading: (value == StockPage.home || value == StockPage.start)
              ? null
              : LeadingArrow(),
          expandedHeight: screenWidth,
          title: ValueListenableBuilder(
            valueListenable: currentPage,
            builder: (context, value, _) {
              return Text(
                "\t" + getPageTitle(value),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          backgroundColor: Colors.blue,
          actions: <Widget>[
            balance != null
                ? ValueListenableBuilder(
                    valueListenable: balance,
                    builder: (context, value, child) {
                      return child;
                    },
                    child: AppBarActions(),
                  )
                : Container(),
            HelpButton(),
          ],
          flexibleSpace: FlexibleSpaceBar(
//                      collapseMode: CollapseMode.none,
            background: Container(
              decoration: kSquareBackDecoration(screen),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      LockedMenuOptions (StockPage.next),
                      MenuSlate(
                        page: StockPage.home,
                        icon: Icon(
                          Icons.home,
                          color: Color(0xFFEE7125),
                        ),
                        title: "Home",
                      ),
                      MenuSlate(
                        page: StockPage.cards,
                        icon: Icon(
                          CustomIcon.newspaper,
                          color: Colors.green,
                        ),
                        title: "Cards",
                      ),
                      LockedMenuOptions (StockPage.buy),
                      MenuSlate(
                        page: StockPage.sell,
                        icon: Icon(
                          CustomIcon.rupee,
                          color: Colors.amber,
                        ),
                        title: "Sell Shares",
                      ),
                      MenuSlate(
                        page: StockPage.trade,
                        icon: Icon(
                          Icons.compare_arrows,
                          color: Color(0xFF028910),
                        ),
                        title: "Trade",
                      ),
                      MenuSlate(
                        page: StockPage.buyCards,
                        icon: Icon(
                          Icons.filter_9_plus,
                          color: Colors.yellow[900],
                        ),
                        title: "Buy Cards",
                      ),
                      MenuSlate(
                        page: StockPage.barChart,
                        icon: Icon(
                          CustomIcon.chart_bar,
                          color: Colors.deepPurple,
                        ),
                        title: "All Shares",
                      ),
                      MenuSlate(
                        page: StockPage.totalAssets,
                        icon: Icon(
                          CustomIcon.chart_bar,
                          color: Colors.red,
                        ),
                        title: "Everyone's Assets",
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}
