import 'package:flutter/material.dart';
//精灵图鉴网格
class SpriteGrid extends StatelessWidget {
  final List<Map<String, dynamic>> sprites;
  final Function(Map<String, dynamic>) onSpriteTap;

  const SpriteGrid({
    super.key,
    required this.sprites,
    required this.onSpriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.85,
      ),
      itemCount: sprites.length,
      itemBuilder: (context, index) {
        final sprite = sprites[index];
        return _buildSpriteItem(sprite);
      },
    );
  }

  Widget _buildSpriteItem(Map<String, dynamic> sprite) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () => onSpriteTap(sprite),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  image: DecorationImage(
                    image: AssetImage(sprite['image']),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                sprite['name'],
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'ID: ${sprite['id'].toString().padLeft(4, '0')}',
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF9E9E9E),
                ),
              ),
              Text(
                sprite['attribute'],
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF757575),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}