import 'dart:developer';

import 'package:flutter/material.dart';
import 'common_alert_dialog.dart';
import 'package:stockexchange/components/dialogs/loading_dialog.dart';

class FutureDialog<T> extends StatelessWidget {
  FutureDialog({
    @required this.future,
    this.loadingText = 'Loading',
    Widget Function(T res) hasData,
    Widget Function(Object error) hasError,
  })  : assert(future != null),
        hasData = hasData,
        hasError = hasError;

  final Future<T> future;
  final String loadingText;
  final Widget Function(Object error) hasError;

  ///executes when either future is done with no error or returns data.
  ///
  ///In case of null,
  ///```
  ///hasData = (_) {
  ///     return CommonAlertDialog('Done');
  ///   }
  ///```
  final Widget Function(T res) hasData;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasData ||
            (snapshot.connectionState == ConnectionState.done &&
                !snapshot.hasError)) {
          if (hasData != null)
            return hasData(snapshot.data);
          else
            return CommonAlertDialog('DONE');
        }
        if (snapshot.hasError) {
          if (hasError != null)
            return hasError(snapshot.error);
          else {
            String errorMessage = 'SOME ERROR OCCURRED';
            if(snapshot.error is String)
              errorMessage = snapshot.error;
            log('err: ${snapshot.error.toString()}', name: 'FutureDialog');
            return CommonAlertDialog(
              errorMessage,
              icon: Icon(
                Icons.block,
                color: Colors.red,
                size: 20,
              ),
            );
          }
        }
        return LoadingDialog(loadingText);
      },
    );
  }
}
