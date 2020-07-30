import 'package:flutter/material.dart';

class LoadingDialog extends StatelessWidget {
  LoadingDialog(this.loadingText);

  final String loadingText;

  @override
  Widget build(BuildContext context) {
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
  }
}
