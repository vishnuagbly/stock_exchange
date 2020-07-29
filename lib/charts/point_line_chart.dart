import 'package:charts_flutter/flutter.dart' as charts;
import 'package:stockexchange/global.dart';
import 'package:flutter/material.dart';
import 'package:stockexchange/backend_files/company.dart';

class PointLineGraphData {
  final int round;
  final double price;

  PointLineGraphData(this.round, this.price);
}

final samplePointLineGraphData = [
  PointLineGraphData(3, 1),
  PointLineGraphData(4, 4),
  PointLineGraphData(5, 3),
  PointLineGraphData(6, 7),
];

List<charts.Series<PointLineGraphData, int>> pointLineData(
    Company company, int num) {
  List<PointLineGraphData> data = [];
  List<double> shareData = company.getAllSharePrice();
  for (int i = shareData.length >= num ? shareData.length - num : 0;
  i < shareData.length;
  i++) data.add(PointLineGraphData(i, shareData[i]));

  return [
    charts.Series<PointLineGraphData, int>(
      id: "Shares",
      data: data,
      domainFn: (PointLineGraphData shares, _) => shares.round,
      measureFn: (PointLineGraphData shares, _) => shares.price,
      seriesColor: convertColor(shareData.length >= num
          ? (shareData.last - shareData[shareData.length - num] > 0
          ? Colors.green
          : Colors.red)
          : (shareData.last - shareData[0] > 0 ? Colors.green : Colors.red)),
    ),
  ];
}


class PointLineChart extends StatelessWidget {

  final List<charts.Series> seriesList;
  final bool animate;

  PointLineChart(this.seriesList, this.animate);

  @override
  Widget build(BuildContext context) {
    return charts.LineChart(
      seriesList,
      animate: animate,
      animationDuration: Duration(milliseconds: 1000),
      defaultRenderer: charts.LineRendererConfig(
        includeArea: true,
        includePoints: true,
      ),
      primaryMeasureAxis: charts.NumericAxisSpec(
        renderSpec: charts.GridlineRendererSpec(
          lineStyle: charts.LineStyleSpec(
            color: convertColor(Colors.white12),
          ),
        ),
        tickProviderSpec: charts.BasicNumericTickProviderSpec(
          zeroBound: false,
          desiredMinTickCount: 3,
        ),
      ),
      domainAxis: charts.NumericAxisSpec(
        tickProviderSpec: charts.BasicNumericTickProviderSpec(
          zeroBound: false,
        ),
      ),
    );
  }

}
