import 'package:flutter/material.dart';
import 'package:stockexchange/backend_files/backend_files.dart';
import 'package:stockexchange/global.dart';
import 'package:stockexchange/charts/bar_chart.dart';

class AllSharesBarChartMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: playerDataChanged,
      builder: (context, value, _) => SliverList(
        delegate: SliverChildListDelegate(
          allSharesGraphs(),
        ),
      ),
    );
  }
}

List<Widget> allSharesGraphs() {
  List<Widget> res = [];
  List<Player> allPlayers = playerManager.allPlayers;
  for (int i = 0; i < playerManager.totalPlayers; i++) {
    var shareGraph = Container(
      margin: EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            '${allPlayers[i].name}',
            style: TextStyle(fontSize: screenWidth * 0.04),
          ),
          SizedBox(height: 5),
          Container(
            padding: EdgeInsets.all(20),
            height: screen.orientation == Orientation.portrait
                ? screenWidth * 0.85
                : screenWidth * 1.5 * 0.85,
            constraints: BoxConstraints(
              maxWidth: screenWidth * 1.5,
            ),
            decoration: kSlateBackDecoration,
            child: Container(
              child: BarChart(
                barChartDataGenerator(
                  playerManager.playerBarGraphAllSharesData(
                    player: allPlayers[i],
                  ),
                ),
                true,
                screen,
              ),
            ),
          ),
        ],
      ),
    );
    if (allPlayers[i].mainPlayer)
      res.insert(0, shareGraph);
    else
      res.add(shareGraph);
  }
  return res;
}
