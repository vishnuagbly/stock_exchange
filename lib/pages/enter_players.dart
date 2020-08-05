import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:stockexchange/components/components.dart';
import 'package:stockexchange/network/network.dart';
import 'package:stockexchange/global.dart';

class EnterTotalPlayers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Enter total players"),
      ),
      body: Center(
        child: Container(
          height: 400,
          child: InputBoard(
            showDropDownMenu: false,
            sliverListType: false,
            dropDownList: [],
            totalTextFields: 1,
            inputText: ["Enter number of players: "],
            inputType: [TextInputType.number],
            inputOnChanged: [
              (specs) {
                int totalPlayers = specs.getTextFieldIntValue(0);
                log("total_players: $totalPlayers", name: 'enter_players');
                if (totalPlayers > 6 || totalPlayers <= 1) {
                  specs.inputTextControllers[0].text =
                      totalPlayers > 6 ? 6.toString() : "";
                  specs.setBoardState(() {
                    specs.errorText[0] = "Total players should be from 2 to 6";
                    log(specs.errorText.toString(), name: 'enter_players');
                  });
                } else {
                  specs.errorText[0] = "";
                  specs.showError(specs.errorText);
                }
              }
            ],
            onPressedButton: (specs) async {
              var inputs = specs.inputTextControllers;
              if (inputs[0].text == null || inputs[0].text == "") {
                specs.errorText[0] = "Total Players are important";
                specs.showError(specs.errorText);
              } else {
                List<int> inputValue = [];
                inputValue.addAll([0]);
                inputValue[0] = specs.getTextFieldIntValue(0);
                startGame(inputValue[0]);
                if (!online)
                  Navigator.popUntil(context, ModalRoute.withName(kHomePageName));
                else if (online) {
                  String authId = await Network.getAuthId();
                  if (authId == null)
                    Navigator.pushNamed(context, kLoginPageName);
                  else {
                    specs.showInfo(["You are now online"]);
                    log("uuid: $authId", name: 'enter_players');
                    Navigator.pushNamed(context, kCreateOnlineRoomName);
                  }
                }
              }
            },
          ),
        ),
      ),
    );
  }
}
