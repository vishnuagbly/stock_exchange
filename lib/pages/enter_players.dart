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
            inputText: ["Enter number of players: ", "Enter total round: "],
            inputType: [TextInputType.number, TextInputType.number],
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
                  specs.showAllErrors(specs.errorText);
                }
              },
              (specs) {
                var totalRounds = specs.getTextFieldIntValue(1);
                if (5 <= totalRounds && totalRounds <= 100)
                  specs.showError(1, '');
              }
            ],
            onPressedButton: (specs) async {
              var totalPlayers =
                  specs.getTextFieldIntValue(0, nullIfEmpty: true);
              var totalRounds =
                  specs.getTextFieldIntValue(1, nullIfEmpty: true);
              if (totalPlayers == null) {
                specs.errorText[0] = "Total Players are important";
                specs.showAllErrors(specs.errorText);
                return;
              }
              if (!checkTotalRounds(specs)) return;
              startGame(totalPlayers, totalRounds);
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
            },
          ),
        ),
      ),
    );
  }

  bool checkTotalRounds(InputBoardSpecs specs) {
    int totalRounds = specs.getTextFieldIntValue(1);
    log('total_rounds: $totalRounds', name: 'enter_players');
    if (totalRounds > 100) {
      specs.setFieldText(1, '100');
      specs.showAllErrors(['', 'total rounds cannot be greater than 100']);
      return false;
    } else if (totalRounds < 5) {
      specs.setFieldText(1, '5');
      specs.showAllErrors(['', 'total rounds cannot be less than 5']);
      return false;
    }
    return true;
  }
}
