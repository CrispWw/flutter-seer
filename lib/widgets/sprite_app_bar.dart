import 'package:flutter/material.dart';
//精灵图鉴导航栏
class SpriteAppBar extends StatelessWidget {
  final VoidCallback onBackPressed;

  const SpriteAppBar({
    super.key,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
        border: const Border(
          bottom: BorderSide(
            color: Color(0xFF737070),
            width: 1,
          ),
        ),
      ),
      child: SizedBox(
        height: 56,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: onBackPressed,
                splashRadius: 20,
              ),
            ),
            const Align(
              alignment: Alignment.center,
              child: Text(
                '精灵图鉴',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}