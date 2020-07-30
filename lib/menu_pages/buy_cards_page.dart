import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:stockexchange/components/dialogs/future_dialog.dart';
import 'package:stockexchange/components/input_board.dart';
import 'package:stockexchange/backend_files/player.dart';
import 'package:stockexchange/global.dart';
import 'package:stockexchange/components/common_alert_dialog.dart';

class BuyCardsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InputBoard(
      buttonText: "BUY",
      dropDownList: [],
      showDropDownMenu: false,
      totalTextFields: 2,
      inputText: [
        "Number of Cards",
        "Price",
      ],
      inputOnChanged: [
        buyCardsOnChanged(),
        buyCardsOnChanged(priceTextField: true),
      ],
      onPressedButton: buyCardsOnPressedButton(context),
    );
  }
}

Function buyCardsOnChanged({bool priceTextField: false}) {
  return (InputBoardSpecs specs) {
    log("checking on change price: $priceTextField", name: 'buyCardsOnChanged');
    Player mainPlayer = playerManager.mainPlayer();
    int numOfCards;
    int price;
    int cardPrice;
    try {
      cardPrice = playerManager.mainPlayer().getCardPrice();
    }
    catch (err) {
      specs.showError(['', err.toString()]);
      return;
    }
    log('cardPrice: $cardPrice', name: 'buyCardsOnChanged');
    try {
      if (priceTextField) {
        price = specs.getTextFieldIntValue(1);
        numOfCards = price ~/ cardPrice;
      } else {
        numOfCards = specs.getTextFieldIntValue(0);
        price = numOfCards * cardPrice;
      }
    } catch (e) {
      log("Error: $e", name: 'buyCardsOnChanged');
      specs.setBoardState(() {
        specs.inputTextControllers[0].text = "";
        specs.inputTextControllers[1].text = "";
        specs.errorText[0] = "";
        specs.errorText[1] = "";
      });
      return;
    }
    log("numOfCards: $numOfCards \t price: $price", name: 'buyCardsOnChanged');
    int maxCards = mainPlayer.maxBuyableCards;
    if (numOfCards > maxCards) {
      int price = maxCards * mainPlayer.getCardPrice();
      specs.setBoardState(() {
        specs.errorText[0] = "This is Maximum Cards";
        specs.inputTextControllers[0].text = maxCards.toString();
        if (price > mainPlayer.money)
          specs.errorText[1] = "It's more money thab you have";
        specs.inputTextControllers[1].text = (maxCards * cardPrice).toString();
      });
    } else {
      specs.setBoardState(() {
        specs.errorText[0] = "";
        specs.errorText[1] = "";
        if (price > mainPlayer.money)
          specs.errorText[1] = "It's more money thab you have";
        if (priceTextField)
          specs.inputTextControllers[0].text = numOfCards.toString();
        else
          specs.inputTextControllers[1].text = price.toString();
      });
    }
  };
}

Function buyCardsOnPressedButton(BuildContext context) {
  Function onPressed;
  Player mainPlayer = playerManager.mainPlayer();
  int pricePerCard;
  try{
    pricePerCard = mainPlayer.getCardPrice();
  }
  catch(e) {
    onPressed = null;
    return onPressed;
  }
  return (InputBoardSpecs specs) {
    int numOfCards, price;
    numOfCards = specs.getTextFieldIntValue(0);
    price = numOfCards * pricePerCard;
    if (price > mainPlayer.money) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return CommonAlertDialog(
              "Price > your balance",
              icon: Icon(
                Icons.block,
                color: Colors.red,
              ),
            );
          });
    } else if (numOfCards <= 0) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return CommonAlertDialog(
              "Number of cards is 0",
              icon: Icon(
                Icons.block,
                color: Colors.red,
              ),
            );
          });
    } else {
      showDialog(
        context: context,
        builder: (context) => FutureDialog<void>(
          future: playerManager.buyCards(mainPlayer, numOfCards),
          loadingText: 'Buying Cards...',
          hasData: (_) => CommonAlertDialog('Purchase Successful'),
        ),
      );
    }
  };
}
