import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stockexchange/global.dart';
import 'package:stockexchange/network/network.dart';
import 'package:stockexchange/network/offline_database.dart';
import 'package:stockexchange/network/transactions.dart';

import 'dialogs/future_dialog.dart';

class PopUpMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      color: kPrimaryColor,
      icon: Icon(Icons.more_vert),
      itemBuilder: (context) {
        List<PopupMenuItem> res = [];
        res.add(PopupMenuItem(
          child: PopUpMenuAllItems(),
        ));
        return res;
      },
    );
  }
}

class PopUpMenuAllItems extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String roomName = Network.roomName;
    if (roomName == 'null' || roomName == null) roomName = 'Offline';
    return Column(
      children: [
        Text(
          roomName,
          style: GoogleFonts.montserrat(
            fontSize: screenWidth * 0.05,
          ),
        ),
        CurrentTurn(),
        Round(),
        Quit(),
        Divider(color: Colors.transparent),
      ],
    );
  }
}

class CurrentTurn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (playerManager == null) return Container();
    return ValueListenableBuilder(
      valueListenable: currentTurnChanged,
      builder: (context, _, __) => ValueListenableBuilder(
        valueListenable: mainPlayerTurnChanged,
        builder: (context, value, child) => Column(
          children: [
            Divider(color: Colors.white70),
            BooleanCounter(
              title: 'Turn',
              firstCard: SmallCustomCard(
                value: currentTurnChanged.value + 1,
                title: 'Current',
              ),
              secondCard: SmallCustomCard(
                value: value + 1,
                fontColor: Colors.blue,
                title: 'Yours',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Round extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (playerManager == null) return Container();
    return ValueListenableBuilder(
      valueListenable: currentRoundChanged,
      builder: (context, value, _) {
        return Column(
          children: [
            Divider(color: Colors.white70),
            BooleanCounter(
              title: 'Round',
              firstCard: SmallCustomCard(
                title: 'Current',
                value: value,
              ),
              secondCard: SmallCustomCard(
                title: 'Total',
                value: playerManager.totalRounds,
                fontColor: Colors.blue,
              ),
            ),
          ],
        );
      },
    );
  }
}

class BooleanCounter extends StatelessWidget {
  const BooleanCounter({
    this.title = '',
    @required this.firstCard,
    @required this.secondCard,
  }) : assert(firstCard != null && secondCard != null);

  final String title;
  final SmallCustomCard firstCard;
  final SmallCustomCard secondCard;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: screenWidth * 0.04,
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            firstCard,
            SizedBox(width: 15),
            secondCard,
          ],
        ),
      ],
    );
  }
}

class SmallCustomCard extends StatelessWidget {
  const SmallCustomCard({
    this.value = 0,
    this.title = '',
    this.fontColor = Colors.white,
  });

  final int value;
  final String title;
  final Color fontColor;

  @override
  Widget build(BuildContext context) {
    final double borderRadius = screenWidth * 0.02;
    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: screenWidth * 0.03,
          ),
        ),
        Card(
          color: kSecondaryColor,
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Container(
            width: screenWidth * 0.15,
            height: screenWidth * 0.15,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            constraints: BoxConstraints(
              minWidth: 50,
              minHeight: 50,
              maxWidth: 200,
              maxHeight: 200,
            ),
            padding: EdgeInsets.all(20),
            child: FittedBox(
              child: Text(
                value.toString(),
                style: GoogleFonts.montserrat(
                  color: fontColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class Quit extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(color: Colors.white70),
        RaisedButton(
          onPressed: () async {
            await showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  return FutureDialog(
                    future: quitGame(),
                    loadingText: "Quiting Game...",
                  );
                });
            Phoenix.rebirth(context);
          },
          color: kSecondaryColor,
          padding: EdgeInsets.zero,
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.02),
          ),
          child: Container(
            width: screenWidth * 0.3 + 23,
            //15 + (4 + 4)(for margin around above cards)
            height: screenWidth * 0.08,
            child: Center(
              child: Text(
                "Quit",
                style: GoogleFonts.montserrat(
                  fontSize: screenWidth * 0.045,
                  color: Colors.red[900],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
