import 'package:flutter/material.dart';
import 'package:stockexchange/components/input_board.dart';
import 'package:stockexchange/global.dart';

class StartingPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    print("<--------------reached Start Page----------------->");
    return InputBoard(
      showDropDownMenu: false,
      dropDownList: [],
      totalTextFields: 1,
      inputType: [TextInputType.text],
      inputText: [
        "Enter Your Name:",
      ],
      inputOnChanged: [
        (specs) {
          specs.errorText[0] = "";
          specs.showAllErrors(specs.errorText);
        },
      ],
      onPressedButton: (specs) async {
        var inputs = specs.inputTextControllers;
        if (inputs[0].text == null || inputs[0].text == "") {
          specs.errorText[0] = "Name is important to write";
          specs.showAllErrors(specs.errorText);
        } else {
          tempPlayerName = inputs[0].text;
          await Navigator.pushNamed(context, '/connection_page');
          // ignore: invalid_use_of_protected_member
          homePageState.setState(() {});
        }
      },
    );
  }
}
