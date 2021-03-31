import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stockexchange/network/network.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stockexchange/components/selection_button.dart';
import 'package:stockexchange/global.dart';

class ConnectionPage extends StatefulWidget {
  @override
  _ConnectionPageState createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage> {
  Function onPressedOnline;
  bool portrait;

  @override
  Widget build(BuildContext context) {
    Network.checkInternetConnection().then((connected) {
      if (connected && onPressedOnline == null) {
        setState(() {
          onPressedOnline = () {
            online = true;
            Navigator.pushNamed(context, "/room_options");
          };
        });
      } else if (!connected)
        setState(() {
          onPressedOnline = null;
        });
    });
    screen = MediaQuery.of(context);
    portrait = screen.orientation == Orientation.portrait;
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: portrait
              ? AssetImage("images/back4.jpg")
              : AssetImage("images/back.jpg"),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Connection Page"),
        ),
        backgroundColor: Colors.black54,
        body: Container(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 150),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Where would you like to play?",
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
                      "ONLINE",
                      onPressedOnline,
                      width: screenWidth * 0.2,
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    SelectionButton(
                      "OFFLINE",
                      () {
                        online = false;
                        Navigator.of(context).pushNamed("/enter_players");
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

  Widget temp(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          margin: EdgeInsets.all(20),
          child: portrait
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: elements(context, portrait),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: elements(context, portrait),
                ),
        ),
        Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            width: portrait ? screenWidth : screenWidth * 0.25,
            height: portrait ? screenWidth * 0.25 : screenWidth,
            child: Center(
              child: Container(
                width: screenWidth * 0.25,
                height: screenWidth * 0.25,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.all(Radius.circular(100)),
                ),
                child: Center(
                  child: Text(
                    "Or",
                    style: GoogleFonts.imFellDwPica(
                      textStyle: TextStyle(
                        fontSize: 35,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
//                          fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> elements(BuildContext context, bool portrait) {
    return [
      Expanded(
        child: Container(
          padding: EdgeInsets.all(50),
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(100),
              topRight: Radius.circular(portrait ? 100 : 0),
              bottomLeft: Radius.circular(portrait ? 0 : 100),
            ),
          ),
          child: Center(
            child: InkWell(
              radius: 100,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: 250,
                  maxWidth: 250,
                ),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.black,
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Text(
                    "ONLINE",
                    style: GoogleFonts.montserrat(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              onTap: () {
                online = true;
                Navigator.pushNamed(context, "/room_options");
              },
            ),
          ),
        ),
      ),
      portrait
          ? Divider(
              color: Colors.red,
            )
          : VerticalDivider(
              color: Colors.red,
            ),
      Expanded(
        child: Container(
          padding: EdgeInsets.all(50),
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(portrait ? 0 : 100),
              bottomRight: Radius.circular(100),
              bottomLeft: Radius.circular(portrait ? 100 : 0),
            ),
          ),
          child: Center(
            child: InkWell(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: 250,
                  maxWidth: 250,
                ),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  image: DecorationImage(
                    image: NetworkImage(""),
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.black,
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Text(
                    "OFFLINE",
                    style: GoogleFonts.montserrat(
                        fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              onTap: () {
                online = false;
                Navigator.of(context).pushNamed("/enter_players");
              },
            ),
          ),
        ),
      ),
    ];
  }

}
