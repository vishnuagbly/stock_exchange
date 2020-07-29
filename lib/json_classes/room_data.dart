import 'package:stockexchange/charts/bar_chart.dart';

class PlayerId {
  String _name;

  String get name => _name;
  final String uuid;

  PlayerId.fromMap(Map<String, dynamic> map)
      : _name = map["name"],
        uuid = map["uuid"];

  PlayerId(this._name, this.uuid);

  static List<PlayerId> playerIdList(allPlayersMap) {
    List<PlayerId> allPlayerIds = [];
    for (Map<String, dynamic> map in allPlayersMap)
      allPlayerIds.add(PlayerId.fromMap(map));
    return allPlayerIds;
  }

  void setName(String newName) => _name = newName;

  Map<String, String> toMap() => {
        "name": name,
        "uuid": uuid,
      };

  static List<Map<String, String>> allPlayersMap(List<PlayerId> playerIds) {
    List<Map<String, String>> result = [];
    for (PlayerId playerId in playerIds) result.add(playerId.toMap());
    return result;
  }
}

class RoomData {
  final int totalPlayers;
  List<PlayerId> playerIds;
  List<BarChartData> allPlayersTotalAssetsBarCharData;

  RoomData.fromMap(Map<String, dynamic> map)
      : totalPlayers = map["total_players"],
        playerIds = PlayerId.playerIdList(map["players"]),
        allPlayersTotalAssetsBarCharData = BarChartData.allFromMap(map["total_assets"]);

  RoomData(
      this.totalPlayers, this.playerIds, this.allPlayersTotalAssetsBarCharData);

  Map<String, dynamic> toMap() => {
        'players': PlayerId.allPlayersMap(playerIds),
        'total_players': totalPlayers,
        'total_assets': BarChartData.allToMap(allPlayersTotalAssetsBarCharData),
      };
}
