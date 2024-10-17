class Item {
  final String id;
  final String name;
  final int price;
  final String sportFieldId;
  final String time;

  Item({
    required this.id,
    required this.name,
    required this.price,
    required this.sportFieldId,
    required this.time,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toInt(),
      sportFieldId: json['sport_field_id'] ?? '',
      time: json['time'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'sport_field_id': sportFieldId,
      'time': time,
    };
  }
}
