import 'dart:developer';

import 'package:flutter/material.dart';

///Special Accessory function for showing loading before a page.
///
///In [T] section enter type of data future function returns.
class LoadingScreen<T> extends StatelessWidget {
  LoadingScreen({
    @required this.future,
    @required this.func,
    this.errFunc,
  }) : assert(future != null && func != null);

  ///Future that will be used to get value or perform async operation needed
  ///before loading next page.
  final Future<T> future;
  final Widget Function(Object error) errFunc;

  ///This function will execute after future is complete.
  ///Also this function should return a Widget.
  final Widget Function(T res) func;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasData)
          return func(snapshot.data);
        else if (snapshot.connectionState == ConnectionState.done)
          return func(snapshot.data);
        if (snapshot.hasError) {
          log('err: ${snapshot.error}', name: 'LoadingPage');
          String errMessage = "Something went wrong";
          if(snapshot.error is String)
            errMessage = snapshot.error;
          return errFunc != null
              ? errFunc(snapshot.error)
              : Scaffold(
                  body: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(errMessage),
                      SizedBox(width: 20),
                      Icon(
                        Icons.block,
                        color: Colors.red,
                        size: 30,
                      ),
                    ],
                  ),
                );
        }
        return Scaffold(
          body: Center(
            child: SizedBox(
              height: 30,
              width: 30,
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }
}
