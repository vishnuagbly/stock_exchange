import 'package:flutter/material.dart';

class LoadingScreen<T> extends StatelessWidget {
  LoadingScreen({
    @required this.future,
    @required this.func,
    this.errFunc,
  }) : assert(future != null && func != null);

  final Future<T> future;
  final Widget Function(Object error) errFunc;

  ///this function should return
  final Widget Function(T res) func;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasData) return func(snapshot.data);
        else if (snapshot.connectionState == ConnectionState.done)
          return func(snapshot.data);
        if (snapshot.hasError)
          return errFunc != null
              ? errFunc(snapshot.error)
              : Scaffold(
                  body: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Something went wrong"),
                      SizedBox(width: 20),
                      Icon(
                        Icons.block,
                        color: Colors.red,
                        size: 30,
                      ),
                    ],
                  ),
                );
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
