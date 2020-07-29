import 'package:flutter/material.dart';
import 'package:stockexchange/global.dart';

class AppBarActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.all(5),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.account_balance,
                color: Colors.black54,
              ),
              SizedBox(
                width: 7.5,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: ValueListenableBuilder(
                  valueListenable: balance,
                  builder: (context, value, child) {
                    return Text(
                      "$kRupeeChar$value",
                      style: TextStyle(
                        fontSize: screenWidth * 0.0465,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 13,
        ),
      ],
    );
  }
}
