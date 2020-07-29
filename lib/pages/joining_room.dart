import 'package:flutter/material.dart';
import 'package:stockexchange/network/network.dart';
import 'package:stockexchange/components/input_board.dart';

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
                Network.joinRoom().then((joined) {
                  Navigator.pushNamed(context, "/online_room");
                }).catchError((errorText) => specs.showError([errorText]));
              }),
        ),
      ),
    );
  }
}
