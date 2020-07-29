import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  LoadingScreen(this.future, this.func, {this.errFunc});

  final Future future;
  final Widget Function() errFunc;
  final Widget Function(dynamic) func;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasData) return func(snapshot.data);
        if (snapshot.hasError)
          return errFunc != null
              ? errFunc()
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
