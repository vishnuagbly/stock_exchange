import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stockexchange/backend_files/backend_files.dart';
import 'package:stockexchange/global.dart';
import 'package:stockexchange/json_classes/json_classes.dart';
import 'package:stockexchange/network/network.dart';

class Transaction {
  static final firestore = Firestore.instance;

  static Future<void> buySellShares(
      int companyIndex, int shares, bool sellShares) async {
    Player mainPlayer;
    await firestore.runTransaction((transaction) async {
      var companiesSnapshot =
          await transaction.get(Network.companiesDataDocRef);
      var mainPlayerSnapshot =
          await transaction.get(Network.mainPlayerFullDataDocRef);
      companies =
          Company.allCompaniesFromMap(companiesSnapshot.data['companies']);
      mainPlayer = Player.fromFullMap(mainPlayerSnapshot.data);
      if (sellShares)
        mainPlayer.sellShares(companyIndex, shares);
      else
        mainPlayer.buyShares(companyIndex, shares);
      var roomDataSnapshot = await transaction.get(Network.roomDataDocRef);
      RoomData roomData = RoomData.fromMap(roomDataSnapshot.data);
      var totalAssets = roomData.allPlayersTotalAssetsBarCharData;
      for (int i = 0; i < totalAssets.length; i++)
        if (totalAssets[i].domain == mainPlayer.name)
          totalAssets[i] = mainPlayer.totalAssets();
      await transaction.update(Network.mainPlayerFullDataDocRef, {
        "_money": mainPlayer.money,
        "shares": mainPlayer.shares,
      });
      await transaction.update(Network.mainPlayerDataDocRef, {
        "_money": mainPlayer.money,
        "shares": mainPlayer.shares,
      });
      await transaction.update(Network.roomDataDocRef, roomData.toMap());
      await transaction.update(Network.companiesDataDocRef, {
        'companies': Company.allCompaniesToMap(companies),
      });
    }).then((_) => playerManager.setOfflineMainPlayerData(mainPlayer));
  }
}
