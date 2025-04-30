class Brand {
  final int id;
  final String name;
  final String? country;

  Brand({
    required this.id,
    required this.name,
    this.country,
  });

  // Фабричный метод для создания объекта из JSON
  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'],
      name: json['name'],
      country: json['country'],
    );
  }

  // Метод для преобразования объекта в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country,
    };
  }
}
