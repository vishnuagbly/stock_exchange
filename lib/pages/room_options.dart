import 'dart:developer';

import 'package:flutter/material.dart';
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
                      width: screenWidth * 0.25,
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    SelectionButton(
                      "JOIN",
                      () async {
                        startGame(6, 5);
                        String authId = await Network.getAuthId();
                        if (authId == null)
                          Navigator.pushNamed(context, "/login_page");
                        else {
                          log("uuid: $authId", name: "roomOptions");
                          Navigator.pushNamed(context, kJoinRoomName);
                        }
                      },
                      width: screenWidth * 0.25,
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
}
