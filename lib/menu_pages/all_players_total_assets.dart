import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:stockexchange/backend_files/player.dart';
import 'package:stockexchange/components/components.dart';
import 'package:stockexchange/global.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stockexchange/network/network.dart';
import 'package:stockexchange/json_classes/json_classes.dart';
import 'package:stockexchange/charts/bar_chart.dart';

class TotalAssetsMenuPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TotalAssetsCard(),
          ),
        ],
      ),
    );
  }
}

class TotalAssetsCard extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          height: screen.orientation == Orientation.portrait
              ? screenWidth * 0.85
              : screenWidth * 1.5 * 0.85,
          constraints: BoxConstraints(
            maxWidth: screenWidth * 1.5,
          ),
          decoration: kSlateBackDecoration,
          child: Center(
            child: Container(
              child: online
                  ? TotalAssetsPlayersOnline()
                  : BarChart(
                      barChartDataGenerator(
                        playerManager.allPlayersAssetsBarGraph(),
                        color: Colors.red,
                      ),
                      true,
                      screen,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class TotalAssetsPlayersOnline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String logName = "TotalAssetsPlayerOnline";
    return StreamBuilder<DocumentSnapshot>(
      stream: Network.firestore
          .document("${Network.gameDataPath}/$kRoomDataDocName")
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          log("room does not exsts", name: logName);
          return Container();
        }
        log("room exists", name: logName);
        DocumentSnapshot roomDataDocument = snapshot.data;
        if (roomDataDocument.data == null) return Container();
        List<BarChartData> data = [];
        List<BarChartData> barChartData;
        RoomData roomData = RoomData.fromMap(roomDataDocument.data);
        log("room Data successfully created", name: logName);
        try {
          List<Player> allPlayers = playerManager.allPlayers;
          barChartData = roomData.allPlayersTotalAssetsBarCharData;
          data.length = barChartData.length;
          for (var player in allPlayers) {
            for (var barData in barChartData)
              if (barData.domain == player.name) data[player.turn] = barData;
          }
          log("got Bar Chart Data", name: logName);
          for (var subData in data)
            if (subData == null) {
              data = barChartData;
              break;
            }
        } catch (err) {
          if (barChartData != null)
            data = barChartData;
          else
            return CommonAlertDialog(
              'Some Error',
              icon: Icon(
                Icons.block,
                color: Colors.red,
              ),
            );
        }
        return BarChart(
          barChartDataGenerator(
            data,
            color: Colors.red,
          ),
          true,
          screen,
        );
      },
    );
  }
}
