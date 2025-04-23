class Character {
  final String name;
  final String image;
  final String house;
  final String gender;

  Character({
    required this.name,
    required this.image,
    required this.house,
    required this.gender,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      name: json['name'] ?? 'Unknown',
      image: json['image'] ?? '',
      house: json['house'] ?? 'Unknown',
      gender: json['gender'] ?? 'unknown',
    );
  }
}
