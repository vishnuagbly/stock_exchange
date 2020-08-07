import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'custom_arc_render_config.dart';
import 'package:stockexchange/global.dart';

class PieChartData {
  static int count = 0;
  final String label;
  final int part;
  final charts.Color color;

  PieChartData(this.label, this.part, Color color)
      : this.color = convertColor(color);
}

var samplePieChartData = [
  PieChartData("Player1", 33, Colors.red),
  PieChartData("Player2", 28, Colors.blue),
  PieChartData("Player3", 54, Colors.yellow),
  PieChartData("Vishnu Sir", 100, Colors.green),
];

List<charts.Series<PieChartData, String>> pieChartSampleData(
    List<PieChartData> data) {
  return [
    charts.Series<PieChartData, String>(
      id: 'shares',
      domainFn: (PieChartData shares, _) => shares.label,
      measureFn: (PieChartData shares, _) => shares.part,
      labelAccessorFn: (PieChartData shares, _) => shares.label,
      colorFn: (PieChartData shares, _) => shares.color,
      seriesColor: convertColor(Colors.transparent),
      data: data,
    ),
  ];
}

class PieChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  PieChart(this.seriesList, this.animate);

  @override
  Widget build(BuildContext context) {
    return charts.PieChart(
      seriesList,
      animate: animate,
      animationDuration: Duration(
        milliseconds: 500,
      ),
      defaultRenderer: CustomArcRendererConfig(
        stroke: convertColor(kPrimaryColor),
        arcWidth: (screenWidth * 0.06).toInt(),
        strokeWidthPx: 5.0,
      ),
    );
  }
}
