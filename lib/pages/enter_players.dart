import 'package:flutter/material.dart';
import 'package:stockexchange/components/components.dart';
import 'package:stockexchange/network/network.dart';
import 'package:stockexchange/global.dart';
import 'package:stockexchange/pages/all_pages.dart';

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
                print("total_players: $totalPlayers");
                if (totalPlayers > 6 || totalPlayers <= 1) {
                  specs.inputTextControllers[0].text =
                      totalPlayers > 6 ? 6.toString() : "";
                  specs.setBoardState(() {
                    specs.errorText[0] = "Total players should be from 2 to 6";
                    print(specs.errorText);
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
                try {
                  inputValue[0] = int.parse(inputs[0].text);
                } catch (e) {
                  print(e);
                  inputValue[0] = 0;
                }
                startGame(inputValue[0]);
                if (!online)
                  Navigator.popUntil(context, ModalRoute.withName("/"));
                else if (online) {
                  String authId = await Network.getAuthId();
                  if (authId == null)
                    Navigator.pushNamed(context, "/login_page");
                  else {
                    specs.showInfo(["You are now online"]);
                    print("uuid: $authId");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoadingScreen<void>(
                          future: Network.createRoom(),
                          func: (_) => OnlineRoom(),
                        ),
                      ),
                    );
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
