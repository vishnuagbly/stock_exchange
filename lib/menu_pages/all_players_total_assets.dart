import 'dart:developer';

import 'package:flutter/material.dart';
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
          Container(
            child: Center(
              child: Container(
                margin: EdgeInsets.all(20),
                padding: EdgeInsets.all(20),
                height:
                screen.orientation == Orientation.portrait
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
                        playerManager
                            .allPlayersAssetsBarGraph(),
                        color: Colors.red,
                      ),
                      true,
                      screen,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
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
          .document("${Network.gameDataPath}/${Network.roomDataDocumentName}")
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          log("room does not exsts", name: logName);
          return Container();
        }
        log("room exists", name: logName);
        DocumentSnapshot roomDataDocument = snapshot.data;
        if (roomDataDocument.data == null) return Container();
        RoomData roomData = RoomData.fromMap(roomDataDocument.data);
        log("room Data successfully created", name: logName);
        List<BarChartData> barChartData =
            roomData.allPlayersTotalAssetsBarCharData;
        log("got Bar Chart Data", name: logName);
        for(int i = 0; i < barChartData.length; i++)
          log("i: $i ${barChartData[i].toString()}");
        return BarChart(
          barChartDataGenerator(
            barChartData,
            color: Colors.red,
          ),
          true,
          screen,
        );
      },
    );
  }
}