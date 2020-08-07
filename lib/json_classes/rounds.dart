class Rounds {
  int totalRounds;
  int currentRound;

  Rounds(this.totalRounds, this.currentRound);

  factory Rounds.fromMap(Map<String, dynamic> map) =>
      Rounds(map['totalRounds'], map['currentRound']);

  Map<String, dynamic> toMap() => {
    'totalRounds': totalRounds,
    'currentRound': currentRound,
  };
}
