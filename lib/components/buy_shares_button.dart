import 'package:flutter/material.dart';
import 'package:stockexchange/components/components.dart';
import '../backend_files/company.dart';
import 'package:stockexchange/global.dart';

class BuySharesButton extends StatelessWidget {
  const BuySharesButton({
    Key key,
    @required this.currentCompany,
    this.alignment: Alignment.centerLeft,
    this.pagePop: false,
    this.sellButton: false,
  }) : super(key: key);

  final Company currentCompany;
  final Alignment alignment;
  final bool pagePop;
  final bool sellButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      child: InkWell(
        onTap: () {
          if(pagePop){
            Navigator.pop(context);
            fromCompanyPage = true;
          }
          if(sellButton){
            currentPage.value = StockPage.sell;
            sellPageInitialDropDownValue = currentCompany.name;
          }
          else if(currentTurn){
            currentPage.value = StockPage.buy;
            buyPageInitialDropDownValue = currentCompany.name;
          }
          else{
            showDialog(
              context: context,
              builder: (context) {
                return CommonAlertDialog(
                  "Its not your turn",
                  icon: Icon(
                    Icons.block,
                    color: Colors.red,
                  ),
                );
              }
            );
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 10.0,
            horizontal: 30.0,
          ),
          decoration: kBuyShareButtonDecoration,
          child: Text(
            sellButton ? "Sell Shares" : "Buy Shares",
            style: kBuyShareButtonTextStyle,
          ),
        ),
      ),
    );
  }
}