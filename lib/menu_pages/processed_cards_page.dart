import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:stockexchange/global.dart';
import 'package:stockexchange/backend_files/card_data.dart' as shareCard;
import 'package:stockexchange/components/components.dart';

class ProcessedCardsPage extends StatefulWidget {
  @override
  _ProcessedCardsPageState createState() => _ProcessedCardsPageState();
}

class _ProcessedCardsPageState extends State<ProcessedCardsPage> {
  List<Widget> cardList() {
    List<Widget> result = [];
    List<shareCard.Card> cards = playerManager.mainPlayer().getProcessedCards();
    for (int i = 0; i < cards.length; i++) {
      result.add(ShareCard(card: cards[i]));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    log("page changed to Page.cards", name: 'cards_page');
    log("Total Cards: ${playerManager.mainPlayer().getAllCardsLength()}",
        name: "cards_page");
    return ValueListenableBuilder(
      valueListenable: mainPlayerCards,
      builder: (context, value, _){
        return SliverGrid.count(
          crossAxisCount: screen.orientation == Orientation.portrait
              ? 2
              : (screenHeight * 2) ~/ screenWidth,
          childAspectRatio: 0.75,
          children: cardList(),
        );
      },
    );
  }
}
