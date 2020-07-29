import 'package:flutter/material.dart';
import 'package:stockexchange/components/components.dart';
import 'package:stockexchange/components/dialogs/future_dialog.dart';
import 'package:stockexchange/global.dart';
import 'dart:math' as maths;
import 'package:stockexchange/backend_files/backend_files.dart';
import 'package:stockexchange/network/transactions.dart';

class ShareMarket {
  static BuildContext context;

  static InputBoard buyPage(BuildContext newContext) {
    context = newContext;
    int shares;
    return InputBoard(
      buttonText: "BUY",
      dropDownList: companyNames(),
      initialDropDownValue: buyPageInitialDropDownValue,
      inputOnChanged: [
        callBuySellSharePageManager(),
        callBuySellSharePageManager(invert: true),
      ],
      inputOnSubmitted: [
        callBuySellSharePageManager(submitted: true),
        callBuySellSharePageManager(submitted: true, invert: true),
      ],
      onPressedButton: (specs) {
        if (specs.inputTextControllers[0].text.isEmpty) {
          specs.showError(["Shares are important to tell"]);
          return;
        }
        Company selectedCompany = getCompany(specs.dropDownValue);
        checkBuySellInputLimitsAndTakeAction(specs, false);
        shares = specs.getTextFieldIntValue(0);
        Player mainPlayer = playerManager.mainPlayer();
        specs.checkAndTakeActionIfCompanyIsBankrupt(context);
        if (shares > selectedCompany.leftShares) {
          specs.showError(["", "there not enough shares left"]);
          return;
        }
        if (shares <= 0){
          specs.showError(["cannot buy zero shares", ""]);
          return;
        }
        if (online) {
          int price = (shares * selectedCompany.getCurrentSharePrice()).toInt();
          specs.inputTextControllers[1].text = price.toString();
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) => FutureDialog(
              future: Transaction.buySellShares(
                  companies.indexOf(selectedCompany), shares, false),
              loadingText: 'Buying Shares',
              hasData: (_) => CommonAlertDialog(
                "Pusrchase Successful",
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('price:   $kRupeeChar${price.toString()}'),
                    Text('shares:   $shares'),
                  ],
                ),
              ),
            ),
          );
        } else {
          mainPlayer.buyShares(companies.indexOf(selectedCompany), shares);
          playerManager.setMainPlayerValues(mainPlayer);
          specs.setBoardState(() {
            specs.inputTextControllers[1].text =
                (shares * selectedCompany.getCurrentSharePrice())
                    .toInt()
                    .toString();
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return CommonAlertDialog("Purchase Successful");
              },
            );
          });
        }
      },
    );
  }

  static InputBoard sellPage(BuildContext newContext) {
    context = newContext;
    return InputBoard(
      buttonText: "SELL",
      dropDownList: companyNames(),
      initialDropDownValue: sellPageInitialDropDownValue,
      inputOnChanged: [
        callBuySellSharePageManager(sell: true),
        callBuySellSharePageManager(invert: true, sell: true),
      ],
      inputOnSubmitted: [
        callBuySellSharePageManager(submitted: true, sell: true),
        callBuySellSharePageManager(invert: true, submitted: true, sell: true),
      ],
      onPressedButton: (specs) {
        Company selectedCompany = getCompany(specs.dropDownValue);
        checkBuySellInputLimitsAndTakeAction(specs, true);
        int shares = specs.getAllTextFieldIntValues()[0];
        Player mainPlayer = playerManager.mainPlayer();
        specs.checkAndTakeActionIfCompanyIsBankrupt(context);
        if(shares <= 0){
          specs.showError(['cannor sell zeo shares', '']);
          return;
        }
        if (shares <= mainPlayer.shares[companies.indexOf(selectedCompany)]) {
          if (online) {
            int price =
                (shares * selectedCompany.getCurrentSharePrice()).toInt();
            specs.inputTextControllers[1].text = price.toString();
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => FutureDialog(
                future: Transaction.buySellShares(
                    companies.indexOf(selectedCompany), shares, true),
                loadingText: 'Selling Shares',
                hasData: (_) => CommonAlertDialog(
                  "Sold Successfully",
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('price:   $kRupeeChar${price.toString()}'),
                      Text('shares:   $shares'),
                    ],
                  ),
                ),
              ),
            );
          } else {
            mainPlayer.sellShares(companies.indexOf(selectedCompany), shares);
            playerManager.setMainPlayerValues(mainPlayer);
            specs.setBoardState(() {
              specs.inputTextControllers[1].text =
                  (shares * selectedCompany.getCurrentSharePrice())
                      .toInt()
                      .toString();
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CommonAlertDialog("Sold Successfully");
                  });
            });
          }
        }
      },
    );
  }

  static Function callBuySellSharePageManager(
      {bool invert: false, bool submitted: false, bool sell: false}) {
    return (InputBoardSpecs specs) {
      buySellSharePageManager(specs, invert, submitted, sell: sell);
    };
  }

  static void buySellSharePageManager(
    InputBoardSpecs inputBoardSpecs,
    bool invert,
    bool submitted, {
    bool sell: false,
  }) {
    print("<-------------- Reached BuySellConverter --------------->");
    inputBoardSpecs.clearErrors();
    inputBoardSpecs.checkAndTakeActionIfCompanyIsBankrupt(context);
    clearAllTextFieldsIfCurrentlyChangedOneIsEmpty(inputBoardSpecs, invert);
    checkBuySellInputLimitsAndTakeAction(inputBoardSpecs, sell);
    setNewInputFieldValues(inputBoardSpecs, invert, submitted);
  }

  static void clearAllTextFieldsIfCurrentlyChangedOneIsEmpty(
      InputBoardSpecs specs, bool invert) {
    if (invert && specs.inputTextControllers[1].text == '')
      specs.inputTextControllers[0].text = '';
    else if (!invert && specs.inputTextControllers[0].text == '')
      specs.inputTextControllers[1].text = '';
  }

  static void checkBuySellInputLimitsAndTakeAction(
      InputBoardSpecs specs, bool sell) {
    String selectedCompanyName = specs.dropDownValue;
    Company selectedCompany = getCompany(selectedCompanyName);
    List<int> inputLimits = buySellPageInputLimits(selectedCompany, sell);
    List<int> inputValues = specs.getAllTextFieldIntValues();
    print("inputValues: $inputValues");
    print("inputLimits: $inputLimits");
    for (int i = 0; i < inputLimits.length; i++) {
      if ((inputValues[i] ?? 0) > inputLimits[i]) {
        specs.inputTextControllers[i].text = inputLimits[i].toString();
        if (i == 1 && !sell)
          specs
              .showError(["", "You don't have more money to buy these shares"]);
        else
          specs.showError(["These are maximum shares", ""]);
      }
    }
  }

  static List<int> buySellPageInputLimits(Company tempCompany, bool sell) {
    List<int> inputLimits = [];
    inputLimits.length = 2;
    if (!sell) {
      inputLimits[0] = maths.min(
          tempCompany.leftShares,
          playerManager.mainPlayer().money ~/
              tempCompany.getCurrentSharePrice());
      inputLimits[1] = playerManager.mainPlayer().money;
    } else {
      inputLimits[0] =
          playerManager.mainPlayer().shares[companies.indexOf(tempCompany)];
      inputLimits[1] =
          (tempCompany.getCurrentSharePrice() * inputLimits[0]).toInt();
    }
    return inputLimits;
  }

  static void setNewInputFieldValues(
      InputBoardSpecs specs, bool invert, bool submitted) {
    List<TextEditingControllerWorkaround> inputs = specs.inputTextControllers;
    String companyName = specs.dropDownValue;
    Company tempCompany = getCompany(companyName);
    double sharePrice = tempCompany.getCurrentSharePrice();
    print("Company: ${tempCompany.name}");
    print("share price: ${tempCompany.getCurrentSharePrice()}");
    List<int> inputValues = specs.getAllTextFieldIntValues();
    print("inputValues: $inputValues");
    print("changing other textField value");
    if (invert) {
      inputs[0].text = (inputValues[1] ~/ sharePrice).toString();
      if (submitted) {
        inputs[1].text = (inputValues[0] * sharePrice).toString();
      }
    } else
      inputs[1].text = (inputValues[0] * sharePrice).toString();
  }

  static List<String> companyNames() {
    List<String> result = [];
    for (int i = 0; i < companies.length; i++) result.add(companies[i].name);
    return result;
  }
}
