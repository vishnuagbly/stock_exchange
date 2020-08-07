import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:stockexchange/backend_files/backend_files.dart';
import 'package:stockexchange/components/dialogs/future_dialog.dart';
import 'package:stockexchange/global.dart';
import 'package:stockexchange/components/input_board.dart';
import 'package:stockexchange/components/dialogs/common_alert_dialog.dart';

class TradePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InputBoard(
      buttonText: "TRADE",
      dropDownList: playerManager.otherPlayerNames(),
      initialDropDownValue: playerManager.otherPlayerNames()[0],
      totalTextFields: 4,
      inputText: [
        "Number of Offering Carsds",
        "Offereing Money",
        "Number of cards want",
        "Money want"
      ],
      inputOnChanged: [
        (specs) {
          int numOfCards = specs.getAllTextFieldIntValues()[0];
          int fromPlayer = playerManager.mainPlayerIndex;
          int toPlayer = playerManager.getPlayerIndex(specs.dropDownValue);
          int correctNumOfCards = playerManager.checkNumOfTradingCards(
              fromPlayer, toPlayer, numOfCards);
          if (numOfCards != correctNumOfCards) {
            numOfCards = correctNumOfCards;
            specs.setBoardState(() {
              specs.inputTextControllers[0].text = numOfCards.toString();
              specs.errorText[0] = "You don't have more Cards to Offer";
            });
          }
        },
        (specs) {
          int intValue = specs.getAllTextFieldIntValues()[1];
          if (intValue > playerManager.mainPlayer().money) {
            intValue = playerManager.mainPlayer().money;
            specs.setBoardState(() {
              specs.inputTextControllers[1].text = intValue.toString();
              specs.errorText = ["", "You don't have more money"];
            });
          }
        },
        (specs) {
          int numOfCards = specs.getTextFieldIntValue(2);
          int fromPlayer = playerManager.getPlayerIndex(specs.dropDownValue);
          int toPlayer = playerManager.mainPlayerIndex;
          int correctNumOfCards = playerManager.checkNumOfTradingCards(
              fromPlayer, toPlayer, numOfCards);
          if (numOfCards != correctNumOfCards) {
            numOfCards = correctNumOfCards;
            specs.setBoardState(() {
              specs.inputTextControllers[2].text = numOfCards.toString();
              specs.errorText[2] = "This is maximum cards person can offer";
            });
          }
        },
        (specs) {
          int money = specs.getTextFieldIntValue(3);
          int fromPlayer = playerManager.getPlayerIndex(specs.dropDownValue);
          int actualMoney = playerManager.getPlayerMoney(fromPlayer);
          if (money > actualMoney) {
            money = actualMoney;
            specs.inputTextControllers[3].text = money.toString();
            specs.showAllErrors(
                ["", "", "", "this is the maximum money person can offer"]);
          } else if (money < 0) {
            money = 0;
            specs.inputTextControllers[3].text = money.toString();
            specs.showAllErrors(["", "", "", "money should be greater than 0"]);
          }
        },
      ],
      onPressedButton: (specs) async {
        print("<------------------Pressed Trade Button------------------->");
        log(
            "total inputTextControllers: ${specs.inputTextControllers.length}", name: 'tradeButton');
        bool allFieldsEmpty =
            await specs.checkAndTakeActionIfAllFieldsAreEmpty(context);
        if (!allFieldsEmpty) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => FutureDialog<bool>(
              future: makeTrade(specs, tradeDetails(specs)),
              loadingText: 'Trading...',
              hasData: (res) {
                if (res == null)
                  return CommonAlertDialog('Trade Request Sent');
                else if (res)
                  return CommonAlertDialog('Trade Successful');
                else {
                  return CommonAlertDialog(
                    'Trade Unsuccessful',
                    icon: Icon(
                      Icons.block,
                      color: Colors.red,
                    ),
                  );
                }
              },
            ),
          );
        }
      },
    );
  }

  TradeDetails tradeDetails(InputBoardSpecs specs) {
    String playerName = specs.dropDownValue;
    List<String> errorText = [];
    errorText.length = 4;
    if (playerName == null || playerName == "") {
      errorText[3] = "please select player";
      specs.showAllErrors(errorText);
    }
    List<int> inputValues = specs.getAllTextFieldIntValues();
    for (int i = 0; i < inputValues.length; i++)
      if (inputValues[i] == null) inputValues[i] = 0;
    return TradeDetails(inputValues, playerManager.getPlayerIndex(playerName),
        playerManager.mainPlayerIndex);
  }

  Future<bool> makeTrade(
      InputBoardSpecs specs, TradeDetails tradeDetails) async {
    bool tradeSuccessFull;
    try {
      if (!online)
        tradeSuccessFull = playerManager.tradeProcessOffline(tradeDetails);
      else
        await playerManager.tradeProcessOnline(tradeDetails);
    } catch (error) {
      specs.errorText.length = specs.inputTextControllers.length;
      tradeSuccessFull = false;
      log(error.toString(), name: makeTrade.toString());
      throw error;
    }
    return tradeSuccessFull;
  }
}
