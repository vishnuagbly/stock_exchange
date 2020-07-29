import 'package:flutter/material.dart';
import 'package:stockexchange/global.dart';
import 'package:stockexchange/charts/bar_chart.dart';

class AllSharesBarChartMenu extends StatelessWidget {

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
                    child: BarChart(
                      barChartDataGenerator(playerManager
                          .allPlayersBarGraphAllSharesData(
                          playerManager.mainPlayer())),
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