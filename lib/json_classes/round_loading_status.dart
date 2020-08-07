import 'package:stockexchange/global.dart';
import 'package:stockexchange/network/network.dart';

class Status {
  Status(this.status);

  Status.fromMap(Map<String, dynamic> map)
      : status = LoadingStatus.values
            .firstWhere((test) => test.index == map["status"]);

  LoadingStatus status;

  Map<String, dynamic> toMap() => {
        "status": status.index,
      };

  String toString() {
    switch (status) {
      case LoadingStatus.nextRoundError:
        return 'Some Error occured';
      case LoadingStatus.timeOut:
        return 'It was just taking so much time';
      case LoadingStatus.gettingData:
        return 'Getting Data';
      case LoadingStatus.calculationStarted:
        return "Round Completed";
      case LoadingStatus.calculationInProgress:
        return "Preparing Next Round";
      case LoadingStatus.calculationCompleted:
        return "Loading Next Round";
      case LoadingStatus.startingNextRound:
        return "Starting Next Round";
      case LoadingStatus.trading:
        return "Trading";
      case LoadingStatus.tradingError:
        return 'Some error while trading occured';
      case LoadingStatus.tradeComplete:
        return 'Trade Successful';
      default:
        return "Loading";
    }
  }

  Future<void> sendStatus() async => await send(status);

  static Future<void> send(LoadingStatus statusEnum) async {
    Status status = Status(statusEnum);
    await Network.createDocument(
        kLoadingStatusDocName, status.toMap());
  }
}
