import 'package:flutter/material.dart';
import 'package:stockexchange/components/input_board.dart';
import 'package:stockexchange/global.dart';
import 'package:stockexchange/network/network.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stockexchange/pages/enter_otp.dart';

class LoginPage extends StatelessWidget {
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login Page"),
      ),
      body: Center(
        child: Container(
          height: 400,
          width: screenWidth,
          child: InputBoard(
            showDropDownMenu: false,
            dropDownList: [],
            totalTextFields: 1,
            sliverListType: false,
            inputText: ["Phone Number(+91)"],
            textPrefix: <Widget>[Text("+91 ")],
            inputOnChanged: [
              (specs) {
                int phoneNumber = specs.getTextFieldIntValue(0);
                TextEditingControllerWorkaround controller;
                controller = specs.inputTextControllers[0];
                if (phoneNumber > 9999999999) {
                  phoneNumber = phoneNumber ~/ 10;
                  controller.setTextAndPosition(phoneNumber.toString());
                }
              },
            ],
            onPressedButton: (specs) {
              int phoneNumber = specs.getTextFieldIntValue(0);
              if (phoneNumber < 1000000000)
                specs.showError(["Enter Correct Phone Number"]);
              else
                _verifyPhoneNumber(context, phoneNumber, specs);
            },
          ),
        ),
      ),
    );
  }

  void _verifyPhoneNumber(
      BuildContext context, int enteredNumber, InputBoardSpecs specs) async {
    String phoneNumber = "+91" + enteredNumber.toString();
    print(phoneNumber);
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: Duration(seconds: 5),
      verificationCompleted: (authCredentials) =>
          _autoRetrievalVerificationCompleted(context, authCredentials),
      verificationFailed: (authException) =>
          _verificationFailed(context, authException),
      codeSent: (verificationId, [tokens]) => _codeSent(verificationId, specs),
      codeAutoRetrievalTimeout: (verificationId) =>
          _afterAutoRetrievalTimeout(context, verificationId),
    );
  }

  void _autoRetrievalVerificationCompleted(
      context, AuthCredential authCredential) {
    _auth.signInWithCredential(authCredential).then((authResult) {
      if (authResult.user != null) {
        print("<-----------authentication successfull----------->");
        print("UUID: ${authResult.user.uid}");
        Network.setAuthId(authResult.user.uid);
        if(roomCreator){
          Network.createRoom();
          Navigator.pushNamed(context, "/online_room");
        }
        else
          Navigator.pushNamed(context, "/join_room");
      } else
        print("Wrong Error");
    }).catchError((error) => print(error));
  }

  void _verificationFailed(context, AuthException authException) {
    print("ERROR message: ${authException.message}");
    print("ERROR CODE: ${authException.code}");
  }

  void _codeSent(String verificationId, InputBoardSpecs specs) {
    print("Code is sent");
    specs.showInfo(["Code is sent to your phone"]);
  }

  void _afterAutoRetrievalTimeout(BuildContext context, String verificationId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnterOTP(verificationId),
      ),
    );
  }
}
