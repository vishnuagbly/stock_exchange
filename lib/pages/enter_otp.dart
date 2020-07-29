import 'package:flutter/material.dart';
import 'package:stockexchange/components/input_board.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stockexchange/global.dart';
import 'package:stockexchange/network/network.dart';

class EnterOTP extends StatelessWidget {
  static final _auth = FirebaseAuth.instance;
  final _verificationId;

  EnterOTP(this._verificationId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Enter OTP"),
      ),
      body: Center(
        child: Container(
          height: 400,
          child: InputBoard(
            showDropDownMenu: false,
            dropDownList: [],
            inputText: ["Enter OTP"],
            sliverListType: false,
            totalTextFields: 1,
            onPressedButton: (specs) {
              print("verification id: $_verificationId");
              print("entered value: ${specs.inputTextControllers[0].text}");
              AuthCredential authCredential = PhoneAuthProvider.getCredential(
                verificationId: _verificationId,
                smsCode: specs.inputTextControllers[0].text,
              );
              print("AuthCredential: " + authCredential.toString());
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
                  specs.showError(["Wrong OTP"]);
              }).catchError((error) => print(error));
            },
          ),
        ),
      ),
    );
  }
}
