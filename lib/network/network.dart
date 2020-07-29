import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stockexchange/charts/bar_chart.dart';
import 'package:stockexchange/global.dart';
import 'package:stockexchange/backend_files/player.dart';
import 'package:stockexchange/backend_files/company.dart';
import 'package:stockexchange/json_classes/json_classes.dart';
import 'dart:math' as maths;

class Network {
  static final firestore = Firestore.instance;
  static final maths.Random rand = maths.Random();
  static final onlineMode = false;
  static String authId;

  static Network get instance => Network();

  static String roomName = "null";
  static final String roomDataDocumentName = "room_data";
  static final String nextRoundStatusDocName = "round_loading_status";
  static final String alertDocumentName = "alert";

  static String get alertCollectionPath => "$alertDocumentName/$authId";

  static final String playerDataDocumentName = "players_data";

  static String get playerDataCollectionPath =>
      "$roomDataDocumentName/$playerDataDocumentName";

  static final String companiesDataDocumentName = "companies_data";

  static String get companiesDataDocumentPath => companiesDataDocumentName;

  static final String playersFullDataDocumentName = "Players_full_data";

  static String get playerFullDataCollectionPath =>
      "$roomDataDocumentName/$playersFullDataDocumentName";

  static final String playersTurnDocumentName = "players_turn";

  static String get gameDataPath => "$roomName";

  static Future<bool> checkInternetConnection() async {
    try{
//      log("checking Internet connection", name: "checkInternetConnection");
      final result = await InternetAddress.lookup("google.com");
      if(result.isNotEmpty && result[0].rawAddress.isNotEmpty){
        log("got Internet connection", name: "checkInternetConnection");
        return true;
      }
      return false;
    } on SocketException catch(_){
      return false;
    }
  }

  static void setAuthId(String uuid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    authId = uuid;
    var mainPlayer = playerManager.mainPlayer();
    mainPlayer.uuid = authId;
    playerManager.setMainPlayerValues(mainPlayer);
    await prefs.setString("uuid", uuid);
  }

  static Future<String> getAuthId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uuid = prefs.getString('uuid');
    if (uuid != null) setAuthId(uuid);
    return uuid;
  }

  static Future<void> createRoomName() async {
    roomName = playerManager.mainPlayerName + rand.nextInt(1000).toString();
    if (await documentExists(roomDataDocumentName)) createRoomName();
    print("room name: $roomName");
  }

  static Future<void> createRoom() async {
    log("calling to create room name", name: 'createRoom');
    await createRoomName();
    log("room created", name: 'createRoom');
    log("total players: ${playerManager.totalPlayers}", name: 'createRoom');
    createDocument(
        roomDataDocumentName,
        RoomData(
          playerManager.totalPlayers,
          [PlayerId(playerManager.mainPlayerName, authId)],
          [playerManager.mainPlayer().totalAssets()],
        ).toMap());
    createDocument(companiesDataDocumentName, {
      "companies": Company.allCompaniesToMap(companies),
    });
    createDocument("$playerDataCollectionPath/$authId",
        playerManager.mainPlayer().toMap());
    createDocument("$playerFullDataCollectionPath/$authId",
        playerManager.mainPlayer().toFullDataMap());
    resetPlayerTurns();
    setTimestamp();
    log('room created', name: 'createRoom');
  }

  static void resetPlayerTurns() {
    createDocument(playersTurnDocumentName, {
      "turns": 0,
    });
  }

  static Future<bool> joinRoom() async {
    Map<String, dynamic> dataMap = await getData(roomDataDocumentName);
    Map<String, dynamic> mainPlayerData =
        await getData("$playerFullDataCollectionPath/$authId");
    Map<String, dynamic> companiesMap =
        await getData(companiesDataDocumentName);
    if (dataMap == null) throw "Room does not exist";
    RoomData data = RoomData.fromMap(dataMap);
    outerIf:
    if (data.playerIds.length < data.totalPlayers) {
      for (PlayerId playerId in data.playerIds) {
        if (playerId.uuid == authId) {
          playerManager.setMainPlayerValues(Player.fromFullMap(mainPlayerData));
          companies = Company.allCompaniesFromMap(companiesMap["companies"]);
          break outerIf;
        } else if (playerId.name == playerManager.mainPlayerName)
          throw "${playerId.name} already exist in room restart game with different name";
      }
      data.playerIds.add(PlayerId(playerManager.mainPlayerName, authId));
      data.allPlayersTotalAssetsBarCharData
          .add(playerManager.mainPlayer().totalAssets());
      updateData(roomDataDocumentName, data.toMap());
      uploadMainPlayerAllData();
    } else {
      for (int i = 0; i < data.playerIds.length; i++)
        if (data.playerIds[i].uuid == authId) {
          print(mainPlayerData);
          playerManager.setMainPlayerValues(Player.fromFullMap(mainPlayerData));
          break outerIf;
        }
      throw "Room is Full";
    }
    return Future.value(true);
  }

  static Future<void> uploadMainPlayerAllData() async {
    createDocument("$playerFullDataCollectionPath/$authId",
        playerManager.mainPlayer().toFullDataMap());
    createDocument("$playerDataCollectionPath/$authId",
        playerManager.mainPlayer().toMap());
  }

  static Future<void> updateAllMainPlayerData() async {
    if(roomName == "null")
      return;
    log("roomName: $roomName", name: "updateAllMainPlayerData");
    mainPlayerCards.value++;
    balance.value = playerManager.mainPlayer().money;
    updateData("$playerDataCollectionPath/$authId",
        playerManager.mainPlayer().toMap());
    updateMainPlayerFullData();
    Map<String, dynamic> dataMap = await getData(roomDataDocumentName);
    RoomData roomData = RoomData.fromMap(dataMap);
    List<BarChartData> totalAssets = roomData.allPlayersTotalAssetsBarCharData;
    for (int i = 0; i < totalAssets.length; i++)
      if (totalAssets[i].domain == playerManager.mainPlayerName)
        totalAssets[i] = playerManager.mainPlayer().totalAssets();
    roomData.allPlayersTotalAssetsBarCharData = totalAssets;
    updateData("$roomDataDocumentName", roomData.toMap());
  }

  static Future<void> updateMainPlayerFullData() async {
    if(roomName == "null")
      return;
    updateData("$playerFullDataCollectionPath/$authId",
        playerManager.mainPlayer().toFullDataMap());
  }

  static Future<void> updateCompaniesData() async {
    if(roomName == "null")
      return;
    updateData(companiesDataDocumentName, {
      "companies": Company.allCompaniesToMap(companies),
    });
  }

  static Future<void> checkAndDownLoadCompaniesData() async {
    Stream<DocumentSnapshot> stream = getDocumentStream("$companiesDataDocumentName");
    stream.listen((DocumentSnapshot snapshot) {
      Map<String, dynamic> companiesDataMap = snapshot.data;
      homeListChanged.value++;
      log("downloaded companies data", name: "checkAndDownloadCompaniesData");
//      for(Company company in companies)
//        log("company: ${company.toMap().toString()}", name: "checkAndDownloadCompaniesData");
      companies = Company.allCompaniesFromMap(companiesDataMap["companies"]);
//      log("companies data map received: ${companiesDataMap.toString()}", name: "checkAndDownloadCompaniesData");
      log("companies data received", name: "checkAndDownloadCompaniesData");
//      for(Company company in companies)
//        log("company: ${company.toMap().toString()}", name: "checkAndDownloadCompaniesData");
    });
  }

  static Future<void> checkAndDownloadPlayersData() async {
    Stream<QuerySnapshot> stream =
        Network.getCollectionStream("$playerDataCollectionPath");
    stream.listen((QuerySnapshot snapshot) {
      log("downloaded players data", name: "checkAndDownloadPlayersData");
      List<Map<String, dynamic>> allPlayersData = [];
      for(DocumentSnapshot documentSnapshot in snapshot.documents)
        allPlayersData.add(documentSnapshot.data);
      playerManager.updateAllPlayersData(allPlayersData);
      log("updated players data", name: "checkAndDownloadPlayersData");
    });
  }

  static Future<List<Map<String, dynamic>>> getAllDocuments(
      String collectionPath) async {
    List<Map<String, dynamic>> result = [];
    QuerySnapshot querySnapshot =
        await firestore.collection("$roomName/$collectionPath").getDocuments();
    for (DocumentSnapshot document in querySnapshot.documents)
      result.add(document.data);
    return Future.value(result);
  }

  static Stream<QuerySnapshot> getCollectionStream(String collectionPath) {
    return firestore.collection("$roomName/$collectionPath").snapshots();
  }

  static Future<Map<String, dynamic>> getData(String documentName) async {
    DocumentSnapshot document = await getDocument(documentName);
    return document.data;
  }

  static Stream<DocumentSnapshot> getDocumentStream(String documentName) {
    return firestore.document("$gameDataPath/$documentName").snapshots();
  }

  static Future<DocumentSnapshot> getDocument(String documentName) async {
    DocumentSnapshot document;
    try {
      document = await firestore.document("$gameDataPath/$documentName").get();
      if (document.data != null) {
        print(document.data.toString());
        setTimestamp();
      }
    } catch (error) {
      print(error);
      document = null;
    }
    return document;
  }

  static Future<void> updateData(
      String documentName, Map<String, dynamic> data) async {
    try {
      await firestore.document("$gameDataPath/$documentName").updateData(data);
      await setTimestamp();
    } catch (error) {
      print(error);
    }
  }

  static void setData(String documentName, Map<String, dynamic> data) async {
    try {
      firestore
          .document("$gameDataPath/$documentName")
          .setData(data, merge: true);
      setTimestamp();
    } catch (error) {
      print(error);
    }
  }

  static Future<bool> setTimestamp() => createDocument(
        "room_created",
        {
          "timestamp": FieldValue.serverTimestamp(),
        },
      );

  static Future<bool> createDocument(
      String documentName, Map<String, dynamic> data) {
    try {
      print("trying to create document: $documentName");
      if (documentName != null)
        firestore.document("$gameDataPath/$documentName").setData(data);
      else
        firestore.collection(gameDataPath).add(data);
      return Future.value(true);
    } catch (error) {
      print(error);
      return Future.value(false);
    }
  }

  static Future<bool> documentExists(String documentPath,
      {printConsole: true}) async {
    if (printConsole) print("checking if document exists");
    DocumentSnapshot snapshot =
        await firestore.document("$gameDataPath/$documentPath").get();
    if (snapshot == null || !snapshot.exists) {
      if (printConsole) print("$gameDataPath/$documentPath does not exists");
      return Future.value(false);
    }
    if (printConsole) print("$gameDataPath/$documentPath exists");
    return Future.value(true);
  }

  static deleteAllDocuments(String collectionPath) async {
    QuerySnapshot querySnapshot = await firestore
        .collection("$gameDataPath/$collectionPath")
        .getDocuments();
    for (DocumentSnapshot document in querySnapshot.documents)
      await deleteDocument("$collectionPath/${document.documentID}");
  }

  static Future<void> deleteDocument(String documentPath) async {
    await firestore
        .document("$gameDataPath/$documentPath")
        .delete()
        .catchError((error) => print(error));
  }
}
