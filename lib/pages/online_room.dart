import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stockexchange/json_classes/json_classes.dart';
import 'package:stockexchange/global.dart';
import 'package:stockexchange/network/network.dart';
import 'package:flutter/material.dart';

class OnlineRoom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${Network.roomName} Room"),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Wrap(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Color(0xFF121212),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: StreamBuilder<DocumentSnapshot>(
                stream: Network.firestore
                    .document(
                        "${Network.gameDataPath}/$roomDataDocumentName")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return CircularProgressIndicator();
                  if (!snapshot.hasData) return RoomDoesNotExist();
                  log("snapshot contains data creating online room", name: 'OnlineRoom');
                  log("data: ${snapshot.data.documentID}", name: 'OnlineRoom');
                  DocumentSnapshot roomDataDocument = snapshot.data;
                  if (roomDataDocument.data == null) return RoomDoesNotExist();
                  RoomData roomData = RoomData.fromMap(roomDataDocument.data);
                  List<Widget> result = [];
                  log("mainPlayer UUID: ${Network.authId}", name: 'OnlineRoom');
                  for (PlayerId player in roomData.playerIds) {
                    log("player UUID: ${player.uuid}", name: 'OnlineRoom');
                    if (player.uuid == Network.authId)
                      result.add(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(player.name),
                            SizedBox(width: 20),
                            Text(
                              "-YOU",
                              style: TextStyle(
                                color: Colors.greenAccent,
                              ),
                            ),
                          ],
                        ),
                      );
                    else
                      result.add(Text(player.name));
                  }
                  if (roomData.playerIds.length == roomData.totalPlayers) {
                    log(roomData.toMap().toString(), name: 'OnlineRoom');
                    startGame(context).then(
                      (value) =>
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.popUntil(context, ModalRoute.withName("/"));
                      }),
                    );
                  }
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: result,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> startGame(BuildContext context) async {
    await getAndSetPlayerData();
  }

  Future<void> getAndSetPlayerData() async {
    playerManager.setAllPlayersData(
        await Network.getAllDocuments(playerDataCollectionPath));
    await Network.checkAndDownloadPlayersData();
    await Network.checkAndDownLoadCompaniesData();
  }
}

class RoomDoesNotExist extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        "Room does not exist, create one to play".toUpperCase(),
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
