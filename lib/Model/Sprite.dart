class Sprite {
  int? id;
  String? name;
  String? imageUrl;
  String? attribute;
  int attack;
  int defense;
  int specialAttack;
  int specialDefense;
  int speed;
  int hp;
  int totalAbility;
  Properties? properties;

  Sprite({
    this.id,
    this.name,
    this.imageUrl,
    this.attribute,
    this.attack = 0,
    this.defense = 0,
    this.specialAttack = 0,
    this.specialDefense = 0,
    this.speed = 0,
    this.hp = 0,
    this.totalAbility = 0,
    this.properties,
  });

  factory Sprite.fromJson(Map<String, dynamic> json) {
    return Sprite(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image_url'],
      attribute: json['attribute'],
      attack: json['attack'] ?? 0,
      defense: json['defense'] ?? 0,
      specialAttack: json['special_attack'] ?? 0,
      specialDefense: json['special_defense'] ?? 0,
      speed: json['speed'] ?? 0,
      hp: json['hp'] ?? 0,
      totalAbility: json['totalability'] ?? 0,
      properties: json['properties'] != null
          ? Properties.fromJson(json['properties'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'attribute': attribute,
      'attack': attack,
      'defense': defense,
      'special_attack': specialAttack,
      'special_defense': specialDefense,
      'speed': speed,
      'hp': hp,
      'totalability': totalAbility,
      'properties': properties?.toJson(),
    };
  }

  @override
  String toString() {
    return 'Sprite{id: $id, name: $name, imageUrl: $imageUrl, attribute: $attribute, attack: $attack, defense: $defense, specialAttack: $specialAttack, specialDefense: $specialDefense, speed: $speed, hp: $hp, totalAbility: $totalAbility, properties: $properties}';
  }

  Sprite copyWith({
    int? id,
    String? name,
    String? imageUrl,
    String? attribute,
    int? attack,
    int? defense,
    int? specialAttack,
    int? specialDefense,
    int? speed,
    int? hp,
    int? totalAbility,
    Properties? properties,
  }) {
    return Sprite(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      attribute: attribute ?? this.attribute,
      attack: attack ?? this.attack,
      defense: defense ?? this.defense,
      specialAttack: specialAttack ?? this.specialAttack,
      specialDefense: specialDefense ?? this.specialDefense,
      speed: speed ?? this.speed,
      hp: hp ?? this.hp,
      totalAbility: totalAbility ?? this.totalAbility,
      properties: properties ?? this.properties,
    );
  }
}

class Properties {
  // 根据你的实际 Properties 结构添加字段
  // 示例字段：
  String? type;
  String? description;

  Properties({
    this.type,
    this.description,
  });

  factory Properties.fromJson(Map<String, dynamic> json) {
    return Properties(
      type: json['type'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'description': description,
    };
  }

  @override
  String toString() {
    return 'Properties{type: $type, description: $description}';
  }
}