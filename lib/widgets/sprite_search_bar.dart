import 'package:flutter/material.dart';

class SpriteSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final bool showClearButton;

  const SpriteSearchBar({
    super.key,
    required this.controller,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.showClearButton,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: '输入精灵名称搜索...',
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            isDense: true,
            prefixIcon: const Icon(
              Icons.search,
              color: Colors.grey,
              size: 20,
            ),
            suffixIcon: showClearButton
                ? IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
              onPressed: onClearSearch,
              splashRadius: 16,
              padding: EdgeInsets.zero,
            )
                : null,
          ),
          maxLines: 1,
          textInputAction: TextInputAction.search,
          onChanged: onSearchChanged,
        ),
      ),
    );
  }
}