import 'package:flutter/material.dart';
import 'sprite_gallery.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea( // 添加 SafeArea
        child: Column(
          children: [
            _buildAppBar(),
            _buildSpriteCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 45,
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
      child: const Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.only(left: 16),
          child: Text(
            'SEER',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpriteCard(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 155,
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: InkWell(
        onTap: () {
          _goToSpriteGallery(context);
        },
        borderRadius: BorderRadius.circular(16),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              // 使用图片背景替代渐变背景
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/dihuang.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // 可以添加半透明遮罩来调整图片效果
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black.withOpacity(0.1),
                ),
              ),
              // 文字部分
              const Positioned(
                right: 38,
                bottom: 10,
                child: Text(
                  '精灵图鉴',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goToSpriteGallery(BuildContext context) {
    // 使用 Navigator 进行页面跳转
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SpriteGalleryPage(),
      ),
    );
  }
}