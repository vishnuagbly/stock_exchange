import 'package:flutter/material.dart';
import 'package:stockexchange/network/network.dart';
import 'package:stockexchange/components/input_board.dart';
import 'package:stockexchange/pages/all_pages.dart';

class JoinRoom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Join Room"),
      ),
      body: Center(
        child: Container(
          height: 400,
          child: InputBoard(
              sliverListType: false,
              showDropDownMenu: false,
              dropDownList: [],
              totalTextFields: 1,
              inputText: ["Room Name"],
              inputType: [TextInputType.text],
              onPressedButton: (specs) {
                Network.roomName = specs.inputTextControllers[0].text;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoadingScreen<bool>(
                      future: Network.joinRoom(),
                      func: (_) => OnlineRoom(),
                    ),
                  ),
                );
              }),
        ),
      ),
    );
  }
}
