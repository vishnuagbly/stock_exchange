import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'pages/game_finished_page.dart';
import 'splash_screen.dart';
import 'package:stockexchange/network/network.dart';
import 'pages/all_pages.dart';
import 'global.dart';

void main() => runApp(
      Phoenix(
        child: MyApp(),
      ),
    );

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final mySystemTheme = SystemUiOverlayStyle.light
      .copyWith(systemNavigationBarColor: Colors.black);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(mySystemTheme);
    log("afterShowAlerts", name: "checkAndShowAlert");
    return MaterialApp(
      builder: (BuildContext context, Widget child) {
        final MediaQueryData data = MediaQuery.of(context);
        return MediaQuery(
          data: data.copyWith(
            textScaleFactor: 1.0,
          ),
          child: child,
        );
      },
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      routes: <String, WidgetBuilder>{
        kConnectionPageName: (BuildContext context) => ConnectionPage(),
        kCompanyPageName: (BuildContext context) => CompanyPage(
              pageCompany,
            ),
        "/": (BuildContext context) => SplashScreen(
              seconds: 5,
              navigateAfterSeconds: kHomePageName,
              backgroundColor: Colors.black,
              photoSize: 100,
              imageBackground: DecorationImage(
                image: AssetImage('images/logo.jpg'),
                fit: BoxFit.contain,
              ),
              loaderColor: Colors.white70,
            ),
        kHomePageName: (BuildContext context) => ScrollConfiguration(
              behavior: MyBehavior(),
              child: HomePage(),
            ),
        kCreateOnlineRoomName: (BuildContext context) => LoadingScreen(
              future: Network.createRoom(),
              func: (_) => OnlineRoom(),
            ),
        kJoinRoomName: (BuildContext context) => JoinRoom(),
        kLoginPageName: (BuildContext context) => LoginPage(),
        kEnterPlayersPageName: (BuildContext context) => EnterTotalPlayers(),
        kRoomOptionsPageName: (BuildContext context) => RoomOptions(),
        kGameFinishedPageName: (BuildContext context) => GameFinished(),
      },
    );
  }
}
