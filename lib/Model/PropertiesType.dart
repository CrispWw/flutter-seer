class PropertiesType {
  int? id;
  String? name;
  String? imagePath; // 对应数据库的 image_path

  PropertiesType({
    this.id,
    this.name,
    this.imagePath,
  });

  factory PropertiesType.fromJson(Map<String, dynamic> json) {
    String imagePath = json['image_path'];
    // 转换路径格式
    if (imagePath != null && imagePath.startsWith('images/')) {
      imagePath = 'assets/$imagePath';
    }

    return PropertiesType(
      id: json['id'],
      name: json['name'],
      imagePath: imagePath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_path': imagePath,
    };
  }
}