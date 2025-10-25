class Properties {
  int? id;
  String? name;
  String? imagePath;

  Properties({
    this.id,
    this.name,
    this.imagePath,
  });

  factory Properties.fromJson(Map<String, dynamic> json) {
    return Properties(
      id: json['id'],
      name: json['name'],
      imagePath: json['image_path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_path': imagePath,
    };
  }

  @override
  String toString() {
    return 'Properties{id: $id, name: $name, imagePath: $imagePath}';
  }

  Properties copyWith({
    int? id,
    String? name,
    String? imagePath,
  }) {
    return Properties(
      id: id ?? this.id,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}