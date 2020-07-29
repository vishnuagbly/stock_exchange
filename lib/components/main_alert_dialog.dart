import 'package:flutter/material.dart';
import 'package:stockexchange/global.dart';

class MainAlertDialog extends AlertDialog {
  MainAlertDialog.raw({
    Key key,
    Widget title,
    this.titlePadding,
    this.titleTextStyle,
    this.content,
    this.contentPadding = const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
    this.contentTextStyle,
    this.actions,
    this.backgroundColor,
    this.elevation,
    this.semanticLabel,
    this.shape,
  }) : super(
          key: key,
          title: title,
          titlePadding: titlePadding,
          titleTextStyle: titleTextStyle,
          content: content,
          contentPadding: contentPadding,
          contentTextStyle: contentTextStyle,
          actions: actions,
          backgroundColor: backgroundColor,
          elevation: elevation,
          semanticLabel: semanticLabel,
          shape: shape,
        );

  MainAlertDialog({
    Key key,
    String title,
    this.titlePadding,
    this.titleTextStyle,
    this.content,
    this.contentPadding = const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
    this.contentTextStyle,
    this.actions,
    this.backgroundColor = const Color(kAlertDialogBackgroundColorCode),
    this.elevation = kAlertDialogElevation,
    this.semanticLabel,
    this.shape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(kAlertDialogBorderRadius),
      ),
    ),
  })  :super(
          key: key,
          title: Text(
            title,
            style: TextStyle(
              fontSize: kAlertDialogTitleTextSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          titlePadding: titlePadding,
          titleTextStyle: titleTextStyle,
          content: content,
          contentPadding: contentPadding,
          contentTextStyle: contentTextStyle,
          actions: actions,
          backgroundColor: backgroundColor,
          elevation: elevation,
          semanticLabel: semanticLabel,
          shape: shape,
        );

  final EdgeInsetsGeometry titlePadding;
  final TextStyle titleTextStyle;
  final Widget content;
  final EdgeInsetsGeometry contentPadding;
  final TextStyle contentTextStyle;
  final List<Widget> actions;
  final Color backgroundColor;
  final double elevation;
  final String semanticLabel;
  final ShapeBorder shape;
}
