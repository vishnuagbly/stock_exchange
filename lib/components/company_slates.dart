import 'package:flutter/material.dart';
import 'package:stockexchange/global.dart';
import 'buy_shares_button.dart';
import '../backend_files/company.dart';

class CompanySlates extends StatelessWidget {
  final Company currentCompany;
  final double sharePriceChange;

  CompanySlates({
    this.currentCompany,
    this.sharePriceChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 500),
          margin: EdgeInsets.only(
            left: 10,
            right: 10,
            bottom: 20,
          ),
          height: screenWidth * 0.4,
          decoration: kSlateBackDecoration,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                flex: 15,
                child: Padding(
                  padding: const EdgeInsets.all(17.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 17,
                        child: Text(
                          currentCompany.name,
                          style: kSlateCompanyNameStyle,
                        ),
                      ),
                      Text(
                        (sharePriceChange >= 0 ? "+" : "-") +
                            "$kRupeeChar" +
                            sharePriceChange.abs().toString(),
                        style: TextStyle(
                          color: sharePriceChange >= 0
                              ? Colors.yellow.withOpacity(0.8)
                              : Colors.brown,
                          fontSize: screenWidth * 0.04,
                          letterSpacing: 3.0,
                        ),
                      ),
                      Text(
                        "$kRupeeChar" + currentCompany.getCurrentSharePrice().toString(),
                        style: kSlateSharePriceStyle,
                        textAlign: TextAlign.left,
                      ),
                      Expanded(
                        flex: 20,
                        child: BuySharesButton(currentCompany: currentCompany),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 10,
                child: Container(
                  child: GestureDetector(
                    onTap: () {
                      print("tapping on icon of " + currentCompany.name.toLowerCase());
                      pageCompany = currentCompany;
                      Navigator.of(context).pushNamed("/company_page");
                    },
                    child: FittedBox(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Hero(
                          tag: currentCompany.name.toLowerCase(),
                          child: Image.asset("images/${currentCompany.name}.png"),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
