import 'dart:developer';

import 'package:flutter/material.dart';

class FutureDialog<T> extends StatelessWidget {
  FutureDialog({
    @required this.future,
    this.loadingText = 'Loading',
    Widget Function(
      Widget Function(String text, Icon icon,
              {Function onPressed, String buttonText})
          dialog,
    )
        hasData,
    Widget Function(
      Widget Function(String text, Icon icon,
              {Function onPressed, String buttonText})
          dialog,
    )
        hasError,
  })  : assert(future != null),
        hasData = hasData,
        hasError = hasError;

  final Future<T> future;
  final String loadingText;
  final Widget Function(
      Widget Function(String text, Icon icon,
              {Function onPressed, String buttonText})
          dialog) hasError;
  final Widget Function(
      Widget Function(String text, Icon icon,
              {Function onPressed, String buttonText})
          dialog) hasData;

  @override
  Widget build(BuildContext context) {
    Widget dialog(
      String text,
      Icon icon, {
      Function onPressed,
      String buttonText = 'OK',
    }) {
      return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(text),
            SizedBox(width: 20),
            icon,
          ],
        ),
        actions: [
          FlatButton(
            child: Text(buttonText),
            onPressed: onPressed ?? () => Navigator.pop(context),
          )
        ],
      );
    }

    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasData ||
            (snapshot.connectionState == ConnectionState.done &&
                !snapshot.hasError)) {
          if (hasData != null)
            return hasData(dialog);
          else
            return dialog(
              'DONE',
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 20,
              ),
            );
        }
        if (snapshot.hasError) {
          if (hasError != null)
            return hasError(dialog);
          else {
            log('err: ${snapshot.error.toString()}', name: 'FutureDialog');
            return dialog(
              'SOME ERROR OCCURRED',
              Icon(
                Icons.block,
                color: Colors.red,
                size: 20,
              ),
            );
          }
        }
        return AlertDialog(
          title: Row(
            children: [
              Text(loadingText),
              SizedBox(width: 20),
              SizedBox(
                width: 20,
                height: 20,
                child: FittedBox(
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
