class SeerSkills {
  String? spiritName;
  String? name;
  String? power;      // 威力
  String? pp;         // 次数
  String? accuracy;   // 命中
  String? priority;   // 先制
  String? type;       // 攻击类型
  String? strong;     // 暴击
  String? effect;     // 效果

  SeerSkills({
    this.spiritName,
    this.name,
    this.power,
    this.pp,
    this.accuracy,
    this.priority,
    this.type,
    this.strong,
    this.effect,
  });

  factory SeerSkills.fromJson(Map<String, dynamic> json) {
    return SeerSkills(
      spiritName: json['spirit_name'],
      name: json['name'],
      power: json['power'],
      pp: json['pp'],
      accuracy: json['accuracy'],
      priority: json['priority'],
      type: json['type'],
      strong: json['strong'],
      effect: json['effect'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'spirit_name': spiritName,
      'name': name,
      'power': power,
      'pp': pp,
      'accuracy': accuracy,
      'priority': priority,
      'type': type,
      'strong': strong,
      'effect': effect,
    };
  }

  @override
  String toString() {
    return '技能: $name\n'
        '威力: $power | PP: $pp | 命中: $accuracy | 先制: $priority\n'
        '类型: $type | 暴击: $strong\n'
        '效果: $effect';
  }

  SeerSkills copyWith({
    String? spiritName,
    String? name,
    String? power,
    String? pp,
    String? accuracy,
    String? priority,
    String? type,
    String? strong,
    String? effect,
  }) {
    return SeerSkills(
      spiritName: spiritName ?? this.spiritName,
      name: name ?? this.name,
      power: power ?? this.power,
      pp: pp ?? this.pp,
      accuracy: accuracy ?? this.accuracy,
      priority: priority ?? this.priority,
      type: type ?? this.type,
      strong: strong ?? this.strong,
      effect: effect ?? this.effect,
    );
  }
}