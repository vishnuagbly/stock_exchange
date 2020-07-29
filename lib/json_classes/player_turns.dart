import 'package:stockexchange/global.dart';

class PlayerTurn {
  int _turn;
  int get turn => _turn;

  PlayerTurn.fromMap(Map<String, dynamic> map):
      _turn = map["turns"];

  PlayerTurn(): _turn = playerManager.mainPlayerTurn;

  PlayerTurn.next(): _turn = (playerManager.mainPlayerTurn + 1) % playerManager.totalPlayers;

  Map<String, dynamic> toMap() => {
    "turns": _turn,
  };
}