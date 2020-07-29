import 'package:flutter/material.dart';
import 'package:stockexchange/global.dart';
import 'help_contents/help_contents.dart';

class Help extends StatelessWidget {
  final Widget content;

  Help (StockPage page) : content = getContent(page);

  @override
  Widget build(BuildContext context) {
    return content;
  }

  static Widget getContent (StockPage page){
    switch(page) {
      case StockPage.home: return HomePageHelp();
      case StockPage.cards: return CardsPageHelp();
      case StockPage.buy: return BuyPageHelp();
      case StockPage.sell: return SellPageHelp();
      case StockPage.trade: return TradePageHelp();
      case StockPage.buyCards: return BuyCardsPageHelp();
      case StockPage.barChart: return AllSharesPageHelp();
      case StockPage.totalAssets: return TotalAssetsPageHelp();
      case StockPage.next: return NextPageHelp();
      default: return Column(mainAxisSize: MainAxisSize.min,);
    }
  }
}
