class Company {
  final String name;
  final int totalShares;
  int leftShares;
  double _currentSharePrice;
  List<double> _allSharePrice = [];

  Company(this.name, this.totalShares, this._currentSharePrice) {
    this._allSharePrice.add(this._currentSharePrice);
    this.leftShares = totalShares;
  }

  static List<Company> allCompaniesFromMap(List<dynamic> companiesMap){
    List<Company> companies = [];
    for(var companyMap in companiesMap)
      companies.add(Company.fromMap(companyMap));
    return companies;
  }

  Company.fromMap(Map<String, dynamic> map)
      : name = map["name"],
        totalShares = map["totalShares"],
        leftShares = map["leftShares"],
        _currentSharePrice = map["_currentSharePrice"],
        _allSharePrice = map["_allSharePrice"].cast<double>();

  static List<Map<String, dynamic>> allCompaniesToMap(List<Company> companies){
    List<Map<String, dynamic>> result = [];
    for(Company company in companies)
      result.add(company.toMap());
    return result;
  }

  Map<String, dynamic> toMap() => {
        "name": name,
        "totalShares": totalShares,
        "leftShares": leftShares,
        "_currentSharePrice": _currentSharePrice,
        "_allSharePrice": _allSharePrice,
      };

  double getCurrentSharePrice() {
    return _currentSharePrice;
  }

  List<double> getAllSharePrice() {
    return _allSharePrice;
  }

  void setCurrentSharePrice(int value) {
    _currentSharePrice += value;
    if (_currentSharePrice < 0) _currentSharePrice = 0;
    _allSharePrice.add(_currentSharePrice);
  }
}
