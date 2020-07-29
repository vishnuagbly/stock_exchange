import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:stockexchange/components/input_board.dart';
import 'package:stockexchange/global.dart';
import 'package:stockexchange/components/selection_button.dart';
import 'package:stockexchange/network/network.dart';
import 'package:google_fonts/google_fonts.dart';

class RoomOptions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context);
    bool portrait = screen.orientation == Orientation.portrait;
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: portrait
              ? AssetImage("images/back4.jpg")
              : AssetImage("images/back.jpg"),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.black54,
        appBar: AppBar(
          title: Text("Room Options"),
        ),
        body: Container(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 150),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Create or Join Room?",
                  style: GoogleFonts.montserrat(
                    textStyle: TextStyle(
                      fontSize: screenWidth * 0.05,
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SelectionButton(
                      "CREATE",
                      () {
                        roomCreator = true;
                        Navigator.pushNamed(context, "/enter_players");
                      },
                      width: screenWidth * 0.2,
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    SelectionButton(
                      "JOIN",
                      () async {
                        startGame(4);
                        String authId = await Network.getAuthId();
                        if (authId == null)
                          Navigator.pushNamed(context, "/login_page");
                        else {
                          log("uuid: $authId", name: "roomOptions");
                          Navigator.pushNamed(context, "/join_room");
                        }
                      },
                      width: screenWidth * 0.2,
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget temp(BuildContext context) => InputBoard(
        showDropDownMenu: false,
        dropDownList: [],
        sliverListType: false,
        totalTextFields: 1,
        inputText: ["Room Options"],
        inputType: [TextInputType.text],
        onPressedButton: (specs) async {
          if (specs.inputTextControllers[0].text == "create") {
            roomCreator = true;
            Navigator.pushNamed(context, "/enter_players");
          } else if (specs.inputTextControllers[0].text == "join") {
            startGame(4);
            String authId = await Network.getAuthId();
            if (authId == null)
              Navigator.pushNamed(context, "/login_page");
            else {
              specs.showInfo(["You are now online"]);
              print("uuid: $authId");
              Navigator.pushNamed(context, "/join_room");
            }
          }
        },
      );
}
