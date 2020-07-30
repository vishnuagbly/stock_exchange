import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stockexchange/components/components.dart';
import 'package:stockexchange/components/dialogs/loading_dialog.dart';
import 'package:stockexchange/components/input_board.dart';
import 'package:stockexchange/global.dart';
import 'package:stockexchange/network/network.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stockexchange/pages/all_pages.dart';
import 'package:stockexchange/pages/enter_otp.dart';

class LoginPage extends StatelessWidget {
  final _auth = FirebaseAuth.instance;

  static final controller = StreamController<PlatformException>(sync: true);
  static final Stream<PlatformException> stream = controller.stream;

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
            onPressedButton: (specs) async {
              int phoneNumber = specs.getTextFieldIntValue(0);
              if (phoneNumber < 1000000000)
                specs.showError(["Enter Correct Phone Number"]);
              else {
                _verifyPhoneNumber(context, phoneNumber, specs);
                await showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) => StreamBuilder<PlatformException>(
                    stream: stream,
                    builder: (context, snapshot) {
                      print('recieverd something: ${snapshot.data.toString()}');
                      if (snapshot.hasData) {
                        if (snapshot.data.code == 'Code Sent') {
                          return CommonAlertDialog('Code Sent', onPressed: () {
                            controller.add(
                                PlatformException(code: 'Waiting for code'));
                          });
                        }
                        if (snapshot.data.code == 'Waiting for code') {
                          return LoadingDialog('Waiting for Code...');
                        }
                        if (snapshot.data.code == 'Got code') {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (roomCreator) {
                              Navigator.popAndPushNamed(context, kCreateOnlineRoomName);
                            } else
                              Navigator.popAndPushNamed(context, "/join_room");
                          });
                          return CommonAlertDialog('OTP Recieved');
                        }
                        if (snapshot.data.code == 'verification_failed') {
                          return CommonAlertDialog(
                            'Verification Failed',
                            icon: Icon(
                              Icons.block,
                              color: Colors.red,
                            ),
                          );
                        }
                        if (snapshot.data.code == 'timed out') {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EnterOTP(snapshot.data.message),
                              ),
                            );
                          });
                        }
                      }
                      if (snapshot.hasError) {
                        return CommonAlertDialog(
                          'Some Error Occured',
                          icon: Icon(
                            Icons.block,
                            color: Colors.red,
                          ),
                        );
                      }
                      return LoadingDialog('Sending Code...');
                    },
                  ),
                );
                await controller.close();
              }
            },
          ),
        ),
      ),
    );
  }

  Future<void> _verifyPhoneNumber(
      BuildContext context, int enteredNumber, InputBoardSpecs specs) async {
    String phoneNumber = "+91" + enteredNumber.toString();
    log(phoneNumber, name: '_verifyPhoneNumber');
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
        controller.add(PlatformException(code: 'Got code'));
      } else
        print("Wrong Error");
    }).catchError((error) => print(error));
  }

  void _verificationFailed(context, AuthException authException) {
    print("ERROR message: ${authException.message}");
    print("ERROR CODE: ${authException.code}");
    controller.add(PlatformException(code: 'verification_failed'));
  }

  void _codeSent(String verificationId, InputBoardSpecs specs) {
    print("Code is sent");
    try {
      controller.add(PlatformException(code: 'Code Sent'));
    } catch (err) {
      log("err: ${err.toString()}", name: '_codeSent');
      throw err;
    }
    print("Code is sent");
    specs.showInfo(["Code is sent to your phone"]);
  }

  void _afterAutoRetrievalTimeout(BuildContext context, String verificationId) {
    controller
        .add(PlatformException(code: 'timed out', message: verificationId));
  }
}
