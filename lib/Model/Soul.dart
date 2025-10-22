class Soul {
  int id;
  int petId;
  String spiritSoul;

  Soul({
    required this.id,
    required this.petId,
    required this.spiritSoul,
  });

  factory Soul.fromJson(Map<String, dynamic> json) {
    return Soul(
      id: json['id'] ?? 0,
      petId: json['petId'] ?? 0,
      spiritSoul: json['spirit_soul'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'spirit_soul': spiritSoul,
    };
  }

  @override
  String toString() {
    return 'Soul{id: $id, petId: $petId, spiritSoul: $spiritSoul}';
  }

  Soul copyWith({
    int? id,
    int? petId,
    String? spiritSoul,
  }) {
    return Soul(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      spiritSoul: spiritSoul ?? this.spiritSoul,
    );
  }
}