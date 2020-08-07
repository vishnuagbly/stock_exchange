import 'package:flutter/material.dart';
import 'menu_slate.dart';
import 'package:stockexchange/global.dart';

class LockedMenuOptions extends StatelessWidget {
  final StockPage lockedPage;

  LockedMenuOptions(this.lockedPage);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: currentTurnChanged,
        builder: (context, value, _) {
          if(!online) return UnlockedOpt(lockedPage);
          if(currentTurnChanged.value == null) return LockedMenuOpt();
          if (value == playerManager.mainPlayerTurn){
            yourTurn = true;
            return UnlockedOpt(lockedPage);
          }
          yourTurn = false;
          return LockedMenuOpt(currentTurn: value);
        });
  }
}

class UnlockedOpt extends StatelessWidget {
  final StockPage unlockedPage;

  UnlockedOpt(this.unlockedPage);

  @override
  Widget build(BuildContext context) {
    if (unlockedPage == StockPage.buy)
      return Row(
        children: <Widget>[
          MenuSlate(
            page: StockPage.buy,
            icon: Icon(
              Icons.shopping_cart,
              color: Colors.green[900],
            ),
            title: "Buy Shares",
          ),
        ],
      );
    else
      return MenuSlate(
        page: StockPage.next,
        icon: Icon(
          Icons.arrow_forward,
          color: Colors.teal[500],
        ),
        title: playerManager != null
            ? (playerManager.lastTurn() ? "Next Round" : "Complete Turn")
            : "NA",
      );
  }
}

class LockedMenuOpt extends StatelessWidget {
  LockedMenuOpt({this.currentTurn});

  final int currentTurn;

  @override
  Widget build(BuildContext context) {
    return MenuSlate(
      getSelected: false,
      icon: Icon(
        Icons.lock,
        color: Colors.grey,
      ),
      title: 'Locked',
    );
  }
}
