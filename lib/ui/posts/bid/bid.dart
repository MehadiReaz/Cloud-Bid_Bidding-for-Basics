class Bid {
  String? key;
  String bidderName;
  int bidAmount;

  Bid({required this.bidderName, required this.bidAmount});

  Bid.fromMap(Map<dynamic, dynamic> map,
      String key) // Modify this constructor to accept the Firebase key
      : key = key,
        bidderName = map['bidderName'],
        bidAmount = map['bidAmount'];

  Map<String, dynamic> toMap() {
    return {
      'bidderName': bidderName,
      'bidAmount': bidAmount,
    };
  }
}
