import 'package:flutter/material.dart';
import 'package:stockexchange/components/components.dart';
import 'package:stockexchange/global.dart';

class HelpButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.info_outline,
        color: Colors.white,
      ),
      onPressed: () {
        showDialog(
            context: context,
            builder: (context){
              return MainAlertDialog(
                title: "${getPageTitle(currentPage.value)} Help",
                content: Help(currentPage.value),
              );
            }
        );
      },
    );
  }
}
