import 'dart:math';
import 'package:charts_flutter/flutter.dart' as charts;
// ignore: implementation_imports
import 'package:charts_common/src/chart/layout/layout_view.dart';
// ignore: implementation_imports
import 'package:charts_common/src/chart/pie/arc_renderer_decorator.dart' show ArcRendererDecorator;

class CustomArcRendererConfig<D> extends charts.ArcRendererConfig<D> {
  /// Stroke color of the border of the arcs.
  final charts.Color stroke;

  /// Color of the "no data" state for the chart, used when an empty series is
  /// drawn.
  final charts.Color noDataColor;

  CustomArcRendererConfig({
    customRendererId,
    arcLength = 2 * pi,
    arcRendererDecorators = const <ArcRendererDecorator>[],
    arcRatio,
    arcWidth,
    layoutPaintOrder = LayoutViewPaintOrder.arc,
    minHoleWidthForCenterContent = 30,
    startAngle = -pi / 2,
    strokeWidthPx = 2.0,
    symbolRenderer,
    this.noDataColor,
    this.stroke,
  }) : super(
    customRendererId: customRendererId,
    arcLength: arcLength,
    arcRendererDecorators: arcRendererDecorators,
    arcRatio: arcRatio,
    arcWidth: arcWidth,
    layoutPaintOrder: layoutPaintOrder,
    minHoleWidthForCenterContent: minHoleWidthForCenterContent,
    startAngle: startAngle,
    strokeWidthPx: strokeWidthPx,
    symbolRenderer: symbolRenderer,
  );
}