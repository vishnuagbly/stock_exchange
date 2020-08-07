import 'dart:developer';

import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stockexchange/backend_files/backend_files.dart';
import 'package:stockexchange/global.dart';
import 'package:flutter/material.dart';
import 'package:stockexchange/menu_pages/all_players_total_assets.dart';
import 'package:stockexchange/extension/extensions.dart';

void ifGameFinished() {
  if (currentRoundChanged.value == null || playerManager == null) return;
  log('currrentRoundChange.value = ${currentRoundChanged.value}', name: 'ifGameFinished');
  log('totalRounds: ${playerManager.totalRounds}', name: 'ifGameFinished');
  if (currentRoundChanged.value <= playerManager.totalRounds) return;
  gameFinished = true;
  Navigator.pushReplacement(
    homePageGlobalKey.currentContext,
    MaterialPageRoute(
      builder: (context) => GameFinished(
        players: playerManager.allPlayers,
      ),
    ),
  );
}

class GameFinished extends StatelessWidget {
  GameFinished({this.players = const []});

  final List<Player> players;

  @override
  Widget build(BuildContext context) {
    List<Player> allPlayers = players;
    allPlayers.sort(
        (a, b) => a.totalAssets().measure.compareTo(b.totalAssets().measure));
    allPlayers = allPlayers.reversed.toList();
    return WillPopScope(
      onWillPop: () {
        resetAllValues();
        return Phoenix.rebirth(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Center(
              child: Text(
            'GAME FINISHED',
            style: GoogleFonts.montserrat(
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.w500,
              color: Colors.amber,
            ),
          )),
        ),
        body: DefaultTextStyle(
          style: GoogleFonts.montserrat(),
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TotalAssetsCard(),
              ),
              Text(
                ' Total Assets:- ',
                style: GoogleFonts.montserrat(
                  fontSize: screenWidth * 0.06,
                ),
              ),
              Row(
                children: [
                  SizedBox(width: 50),
                  Expanded(
                    child: Column(
                      children: List.generate(
                        allPlayers.length,
                        (index) {
                          Color color = Colors.red;
                          if (index == 0) color = Colors.amber;
                          if (index == 1 && allPlayers.length > 3)
                            color = Colors.white70;
                          if (index == 2 && allPlayers.length > 4)
                            color = Colors.brown;
                          return Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.all(5),
                                  child: Text(
                                    allPlayers[index].name,
                                    style: GoogleFonts.montserrat(
                                      color: color,
                                      fontSize: screenWidth * 0.05,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  child: Text(
                                    '$kRupeeChar ${allPlayers[index].totalAssets().measure.toInt().toMoneyString()}',
                                    style: GoogleFonts.roboto(
                                      fontSize: screenWidth * 0.04,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ),
                              SizedBox(width: 50),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
