import 'package:flutter/material.dart';
import 'package:stockexchange/components/input_board.dart';
import 'package:stockexchange/backend_files/player.dart';
import 'package:stockexchange/global.dart';
import 'package:stockexchange/components/common_alert_dialog.dart';
import 'dart:math' as maths;

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
      onPressedButton: (specs) {
        Player mainPlayer = playerManager.mainPlayer();
        int numOfCards, pricePerCard = mainPlayer.getCardPrice(), price;
        try {
          numOfCards = int.parse(specs.inputTextControllers[0].text);
        } catch (e) {
          print(e);
          numOfCards = 0;
        }
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
          if (playerManager.buyCards(mainPlayer, numOfCards)) {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return CommonAlertDialog(
                    "Purchase Successful",
                  );
                });
          } else {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return CommonAlertDialog(
                    "Purchase unsuccessful",
                    icon: Icon(
                      Icons.block,
                      color: Colors.red,
                    ),
                  );
                });
          }
        }
      },
    );
  }
}

Function buyCardsOnChanged({bool priceTextField: false}) {
  return (InputBoardSpecs specs) {
    print("checking on change price: $priceTextField");
    Player mainPlayer = playerManager.mainPlayer();
    int numOfCards;
    int price;
    int cardPrice = playerManager.mainPlayer().getCardPrice();
    try {
      if (priceTextField) {
        price = int.parse(specs.value);
        numOfCards = price ~/ cardPrice;
      } else {
        numOfCards = int.parse(specs.value);
        price = numOfCards * cardPrice;
      }
    } catch (e) {
      print("Error: $e");
      specs.setBoardState(() {
        specs.inputTextControllers[0].text = "";
        specs.inputTextControllers[1].text = "";
        specs.errorText[0] = "";
        specs.errorText[1] = "";
      });
    }
    print("numOfCards: $numOfCards \t price: $price");
    int maxCards =
        cardBank.getBuyableCardsLength() - mainPlayer.getTotalBoughtCard();
    maxCards = maths.min(maxCards, mainPlayer.money ~/ cardPrice);
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
