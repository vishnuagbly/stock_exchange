import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stockexchange/charts/bar_chart.dart';
import 'package:stockexchange/components/check_and_show_alert.dart';
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
  static StreamSubscription<QuerySnapshot> alertDocSubscription;

  static String get alertCollectionPath => "$alertDocumentName/$authId";

  static String get gameDataPath => "$roomName";

  static Network get instance => Network();

  static String _roomName = "null";
  static String get roomName => _roomName;

  static Future<void> setRoomName(String name) async {
    _roomName = name;
    if(alertDocSubscription != null)
      await alertDocSubscription.cancel();
    alertDocSubscription = checkAndShowAlert();
  }

  static DocumentReference get mainPlayerFullDataDocRef =>
      playerFullDataRef(authId);

  static List<DocumentReference> get allPlayersFullDataRefs {
    List<DocumentReference> refs = [];
    for(int i = 0; i < playerManager.totalPlayers; i++)
      refs.add(playerFullDataRef(playerManager.getPlayerId(index: i)));
    return refs;
  }

  static DocumentReference playerFullDataRef(String uuid) =>
      firestore.document('$roomName/$playerFullDataCollectionPath/$uuid');

  static DocumentReference get mainPlayerDataDocRef => playerDataDocRef(authId);

  static DocumentReference playerDataDocRef(String uuid) =>
      firestore.document('$roomName/$playerDataCollectionPath/$uuid');

  static DocumentReference get roomDataDocRef =>
      firestore.document('$roomName/$roomDataDocumentName');

  static DocumentReference get companiesDataDocRef =>
      firestore.document('$roomName/$companiesDataDocumentPath');

  static Future<bool> checkInternetConnection() async {
    try {
//      log("checking Internet connection", name: "checkInternetConnection");
      final result = await InternetAddress.lookup("google.com");
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        log("got Internet connection", name: "checkInternetConnection");
        return true;
      }
      return false;
    } on SocketException catch (_) {
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
    log('trying to get authId', name: 'getAuthId');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uuid = prefs.getString('uuid');
    log('got authId: $uuid', name: 'getAuthId');
    if (uuid != null) setAuthId(uuid);
    return uuid;
  }

  static void deleteAuthId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    authId = null;
    await prefs.remove('uuid');
  }

  static Future<void> createRoomName() async {
    String roomName = playerManager.mainPlayerName + rand.nextInt(1000).toString();
    await setRoomName(roomName);
    if (await documentExists(roomDataDocumentName)) createRoomName();
    log("room name: $roomName", name: 'createRoomName');
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

  static Future<void> resetPlayerTurns() async {
    await createDocument(playersTurnsDocName, {
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
    var mainPlayer = playerManager.mainPlayer();
    outerIf:
    if (data.playerIds.length < data.totalPlayers) {
      log("mainPlayer name: ${playerManager.mainPlayerName}", name: 'joinRoom');
      for (PlayerId playerId in data.playerIds) {
        log('player[${playerId.name}] exists', name: 'joinRoom');
        if (playerId.uuid == authId) {
          playerManager.setMainPlayerValues(Player.fromFullMap(mainPlayerData));
          companies = Company.allCompaniesFromMap(companiesMap["companies"]);
          break outerIf;
        } else if (playerId.name == playerManager.mainPlayerName) {
          log('player name already exists', name: 'joinRoom');
          throw "${playerId.name} already exist in room restart game with different name";
        }
      }
      mainPlayer.turn = data.playerIds.length;
      mainPlayer.totalPlayers = data.totalPlayers;
      playerManager.setMainPlayerValues(mainPlayer);
      data.playerIds.add(PlayerId(playerManager.mainPlayerName, authId));
      data.allPlayersTotalAssetsBarCharData
          .add(playerManager.mainPlayer().totalAssets());
      await uploadMainPlayerAllData();
      await updateData(roomDataDocumentName, data.toMap());
    } else {
      for (int i = 0; i < data.playerIds.length; i++)
        if (data.playerIds[i].uuid == authId) {
          log(mainPlayerData.toString(), name: 'joinRoom');
          playerManager.setMainPlayerValues(Player.fromFullMap(mainPlayerData));
          break outerIf;
        }
      throw "Room is Full";
    }
    return Future.value(true);
  }

  static Future<void> getAndSetMainPlayerFullData() async {
    var mainPlayerData = await getData("$playerFullDataCollectionPath/$authId");
    playerManager.setOfflineMainPlayerData(Player.fromFullMap(mainPlayerData));
  }

  static Future<void> uploadMainPlayerAllData() async {
    createDocument("$playerFullDataCollectionPath/$authId",
        playerManager.mainPlayer().toFullDataMap());
    createDocument("$playerDataCollectionPath/$authId",
        playerManager.mainPlayer().toMap());
  }

  ///update all main player data online with data on device.
  static Future<void> updateAllMainPlayerData() async {
    if (roomName == "null") return;
    log("roomName: $roomName", name: "updateAllMainPlayerData");
    mainPlayerCards.value++;
    balance.value = playerManager.mainPlayer().money;
    await updateData("$playerDataCollectionPath/$authId",
        playerManager.mainPlayer().toMap());
    await updateMainPlayerFullData();
    Map<String, dynamic> dataMap = await getData(roomDataDocumentName);
    RoomData roomData = RoomData.fromMap(dataMap);
    List<BarChartData> totalAssets = roomData.allPlayersTotalAssetsBarCharData;
    for (int i = 0; i < totalAssets.length; i++)
      if (totalAssets[i].domain == playerManager.mainPlayerName)
        totalAssets[i] = playerManager.mainPlayer().totalAssets();
    roomData.allPlayersTotalAssetsBarCharData = totalAssets;
    await updateData("$roomDataDocumentName", roomData.toMap());
  }

  static Future<void> updateMainPlayerFullData() async {
    if (roomName == "null") return;
    updateData("$playerFullDataCollectionPath/$authId",
        playerManager.mainPlayer().toFullDataMap());
  }

  static Future<void> updateCompaniesData() async {
    if (roomName == "null") return;
    updateData(companiesDataDocumentName, {
      "companies": Company.allCompaniesToMap(companies),
    });
  }

  static Future<void> checkAndDownLoadCompaniesData() async {
    Stream<DocumentSnapshot> stream =
        getDocumentStream("$companiesDataDocumentName");
    stream.listen((DocumentSnapshot snapshot) {
      if (snapshot.data == null)
        throw PlatformException(code: 'COMPANIES_DATA_NULL');
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
      for (DocumentSnapshot documentSnapshot in snapshot.documents)
        allPlayersData.add(documentSnapshot.data);
      playerManager.updateAllPlayersData(allPlayersData);
      log("updated players data", name: "checkAndDownloadPlayersData");
    });
  }

  static Future<List<Map<String, dynamic>>> getAllDocuments(
      String collectionPath) async {
    QuerySnapshot querySnapshot =
        await firestore.collection("$roomName/$collectionPath").getDocuments();
    return getAllDataFromDocuments(querySnapshot.documents);
  }

  static List<Map<String, dynamic>> getAllDataFromDocuments(
       List<DocumentSnapshot> documents) {
    List<Map<String, dynamic>> result = [];
    for (DocumentSnapshot document in documents)
      result.add(document.data);
    return result;
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
        log('got doc $documentName: ${document.data.toString()}', name: 'getDocument');
        setTimestamp();
      }
    } catch (error) {
      log(error.toString(), name: 'getDocument');
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
      log(error.toString(), name: 'updateData');
    }
  }

  static void setData(String documentName, Map<String, dynamic> data) async {
    try {
      firestore
          .document("$gameDataPath/$documentName")
          .setData(data, merge: true);
      setTimestamp();
    } catch (error) {
      log(error, name: 'setData');
    }
  }

  static Future<bool> setTimestamp() => createDocument(
        "room_created",
        {
          "timestamp": FieldValue.serverTimestamp(),
        },
      );

  static Future<bool> createDocument(
      String documentName, Map<String, dynamic> data) async {
    try {
      log(
        'trying to create document: $documentName data: ${data.toString()}',
        name: "createDocument",
      );
      if (documentName != null)
        await firestore.document("$gameDataPath/$documentName").setData(data);
      else
        await firestore.collection(gameDataPath).add(data);
      return Future.value(true);
    } catch (error) {
      log(error, name: 'createDocument');
      throw error;
    }
  }

  static Future<bool> documentExists(String documentPath,
      {printConsole: true}) async {
    if (printConsole) log("checking if document exists", name: 'documentExists');
    DocumentSnapshot snapshot =
        await firestore.document("$gameDataPath/$documentPath").get();
    if (snapshot == null || !snapshot.exists) {
      if (printConsole) log("$gameDataPath/$documentPath does not exists", name: 'documentExists');
      return Future.value(false);
    }
    if (printConsole) log("$gameDataPath/$documentPath exists", name: 'documentExists');
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
        .catchError((error) => log(error, name: 'deleteDocument'));
  }
}
