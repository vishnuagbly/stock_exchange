import 'package:stockexchange/global.dart';
import 'package:stockexchange/network/network.dart';

class RoundLoadingStatus {
  RoundLoadingStatus(this.status);

  RoundLoadingStatus.fromMap(Map<String, dynamic> map)
      : status = roundLoadingStatus.values
            .firstWhere((test) => test.index == map["status"]);

  roundLoadingStatus status;

  Map<String, dynamic> toMap() => {
        "status": status.index,
      };

  String toString() {
    switch (status) {
      case roundLoadingStatus.calculationStarted:
        return "Round Completed";
      case roundLoadingStatus.calculationInProgress:
        return "Preparing Next Round";
      case roundLoadingStatus.calculationCompleted:
        return "Loading Next Round";
      case roundLoadingStatus.startingNextRound:
        return "Starting Next Round";
      default:
        return "Loading";
    }
  }

  static Future<void> send(roundLoadingStatus statusEnum) async {
    RoundLoadingStatus status = RoundLoadingStatus(statusEnum);
    await Network.createDocument(
        Network.nextRoundStatusDocName, status.toMap());
  }
}
