import 'dart:developer';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast/utils/value_utils.dart';
import 'package:stockexchange/backend_files/backend_files.dart';
import 'package:stockexchange/global.dart';

class Phone {
  static const String dbName = 'saved_game.db';
  static const String playerStoreName = 'players';
  static const String cardsStoreName = 'cards';
  static const String companiesStoreName = 'companies';
  static const String roundsStoreName = 'rounds';
  static const List<String> allStoresName = [
    playerStoreName,
    cardsStoreName,
    companiesStoreName,
    roundsStoreName,
  ];
  static List<Player> players;
  static int totalRounds;
  static int currentRound;
  static List<Company> allCompanies;
  static CardBank savedCardBank;
  static Database _db;

  static Future<Database> get db async {
    if (_db == null) {
      final appDocumentDir = await getApplicationDocumentsDirectory();
      // Path with the form: /platform-specific-directory/demo.db
      final dbPath = join(appDocumentDir.path, dbName);
      var dbFactory = databaseFactoryIo;
      _db = await dbFactory.openDatabase(dbPath);
    }
    return _db;
  }

  static Future<void> deleteGame() async {
    for(var storeName in allStoresName) {
      var store = intMapStoreFactory.store(storeName);
      store.delete(await db);
    }
  }

  static Future<void> saveGame() async {
    await savePlayers(playerManager.allPlayers);
    await saveCompanies(companies);
    await saveCards(cardBank.toMap());
    await saveRounds(
        playerManager.totalRounds, playerManager.currentRound);
  }

  static Future<bool> getGame() async {
    players = await getPlayers();
    allCompanies = await getCompanies();
    await getRounds();
    if (players == null || allCompanies == null) return false;
    var cardBankMap = await getCards();
    if (cardBankMap == null) return false;
    savedCardBank = CardBank.fromMap(cardBankMap);
    bool gameExists = false;
    for (var player in players) if (player != null) gameExists = true;
    for (var company in allCompanies) if (company == null) gameExists = false;
    return gameExists;
  }

  static Future<void> saveRounds(int totalRounds, int currentRound) async {
    var store = intMapStoreFactory.store(roundsStoreName);
    var map = {
      'totalRounds': totalRounds,
      'currentRound': currentRound,
    };
    await store.delete(await db);
    await store.record(0).put(await db, map);
  }

  static Future<void> getRounds() async {
    var store = intMapStoreFactory.store(roundsStoreName);
    var map = cloneMap(await store.record(0).get(await db));
    if(map == null)
      return null;
    totalRounds = map['totalRounds'];
    currentRound = map['currentRound'];
  }

  static Future<void> savePlayers(List<Player> allPlayers) async {
    var store = intMapStoreFactory.store(playerStoreName);
    List<Map<String, dynamic>> allPlayersMaps = [];
    for (Player player in allPlayers)
      allPlayersMaps.add(player.toFullDataMap());
    await store.delete(await db);
    for (int i = 0; i < allPlayersMaps.length; i++)
      await store.record(i).put(await db, allPlayersMaps[i]);
  }

  static Future<void> saveCompanies(List<Company> companies) async {
    var store = intMapStoreFactory.store(companiesStoreName);
    var maps = Company.allCompaniesToMap(companies);
    await store.delete(await db);
    for (int i = 0; i < maps.length; i++)
      await store.record(i).put(await db, maps[i]);
  }

  static Future<List<Player>> getPlayers() async {
    var store = intMapStoreFactory.store(playerStoreName);
    List<Map<String, dynamic>> maps = [];
    for (int i = 0; i < 6; i++) {
      var map = await store.record(i).get(await db);
      if (map != null) maps.add(cloneMap(map));
    }
    if (maps.length == 0) return null;
    log('map length: ${maps.length}', name: getPlayers.toString());
    return Player.allFullPlayersFromMap(maps, savedOffline: true);
  }

  static Future<List<Company>> getCompanies() async {
    var store = intMapStoreFactory.store(companiesStoreName);
    List<Map<String, dynamic>> maps = [];
    for (int i = 0; i < 6; i++) {
      var map = await store.record(i).get(await db);
      if (map != null)
        maps.add(cloneMap(map));
      else
        return null;
    }
    return Company.allCompaniesFromMap(maps);
  }

  static Future<void> saveCards(Map<String, dynamic> map) async {
    var store = intMapStoreFactory.store(cardsStoreName);
    await store.delete(await db);
    await store.record(0).put(await db, map);
  }

  static Future<Map<String, dynamic>> getCards() async {
    var store = intMapStoreFactory.store(cardsStoreName);
    var map = cloneMap(await store.record(0).get(await db));
    return map;
  }
}
