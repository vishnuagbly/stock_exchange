import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:stockexchange/global.dart';
import 'package:stockexchange/backend_files/card_data.dart' as shareCard;

class ShareCard extends StatelessWidget {
  final shareCard.Card card;
  final bool hero;

  ShareCard({this.card, this.hero: true});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: Container(
          decoration: kSlateBackDecoration,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  (card.traded ?? false) || (card.bought ?? false)
                      ? Row(
                          children: <Widget>[
                            Text(
                              (card.bought ?? false) ? "BOUGHT" : "",
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.03,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              (card.traded ?? false) ? "TRADED" : "",
                              style: TextStyle(
                                color: Colors.greenAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.03,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                          ],
                        )
                      : SizedBox(),
                  hero
                      ? Padding(
                          padding: EdgeInsets.only(right: 5.0),
                          child: GestureDetector(
                            onTap: () {
                              log(
                                "tapped on ${companies[card.companyNum].name}",
                                name: 'cardWidget',
                              );
                              pageCompany = companies[card.companyNum];
                              Navigator.of(context).pushNamed("/company_page");
                            },
                            child: Icon(
                              Icons.arrow_drop_down,
                            ),
                          ),
                        )
                      : SizedBox(
                          height: 10,
                        ),
                ],
              ),
              Text(
                companies[card.companyNum].name,
                style: kSlateCompanyNameStyle,
              ),
              SizedBox(
                height: 30,
              ),
              Center(
                child: GestureDetector(
                  onTap: () {
                    log(
                      "tapped on ${companies[card.companyNum].name}",
                      name: 'cardWidget',
                    );
                    if (hero) {
                      pageCompany = companies[card.companyNum];
                      Navigator.of(context).pushNamed("/company_page");
                    }
                  },
                  child: Container(
                    width: screenWidth * 0.22,
                    child: hero
                        ? Hero(
                            tag: companies[card.companyNum].name.toLowerCase(),
                            child: Image.asset(
                                "images/${companies[card.companyNum].name}.png",
                                fit: BoxFit.fill),
                          )
                        : Image.asset(
                            "images/${companies[card.companyNum].name}.png",
                            fit: BoxFit.fill),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                  (card.shareValueChange >= 0 ? "+" : "-") +
                      "$kRupeeChar" +
                      card.shareValueChange.abs().toString(),
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color:
                        card.shareValueChange >= 0 ? Colors.green : Colors.red,
                  )),
            ],
          )),
    );
  }
}
