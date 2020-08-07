library extensions;

extension money on int {
  String toMoneyString() {
    if (this < 1000) return this.toString();
    return '${moneyAboveThousand(this ~/ 1000)},${(this % 1000).toDigitMoneyString(3)}';
  }

  String toDigitMoneyString(int aimDigits) {
    int digits = 0;
    int tempNum = this;
    while (tempNum > 0) {
      tempNum ~/= 10;
      digits++;
    }
    String res = '';
    for (int i = 0; i < aimDigits - digits; i++) res += ('0');
    if(this > 0)
      res += this.toString();
    return res;
  }
}

String moneyAboveThousand(int money) {
  if (money < 100) return money.toString();
  return '${moneyAboveThousand(money ~/ 100)},${(money % 100).toDigitMoneyString(2)}';
}
