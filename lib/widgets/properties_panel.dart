// widgets/properties_panel.dart
import 'package:flutter/material.dart';
import '../Model/PropertiesType.dart';

class PropertiesPanel extends StatefulWidget {
  final List<PropertiesType> propertiesList;
  final VoidCallback onClose;
  final void Function(PropertiesType)? onPropertySelected;
  final String? selectedPropertyName;

  const PropertiesPanel({
    Key? key,
    required this.propertiesList,
    required this.onClose,
    this.onPropertySelected,
    this.selectedPropertyName,
  }) : super(key: key);

  @override
  State<PropertiesPanel> createState() => _PropertiesPanelState();
}

class _PropertiesPanelState extends State<PropertiesPanel> {
  String? _selectedPropertyName;

  @override
  void initState() {
    super.initState();
    _selectedPropertyName = widget.selectedPropertyName;
  }

  @override
  void didUpdateWidget(PropertiesPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedPropertyName != widget.selectedPropertyName) {
      setState(() {
        _selectedPropertyName = widget.selectedPropertyName;
      });
    }
  }

  void _handlePropertyTap(PropertiesType property) {
    setState(() {
      if (_selectedPropertyName == property.name) {
        _selectedPropertyName = null;
      } else {
        _selectedPropertyName = property.name;
      }
    });

    widget.onPropertySelected?.call(property);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 半透明背景，点击关闭
        GestureDetector(
          onTap: widget.onClose,
          child: Container(
            color: Colors.black54,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        // 属性选择面板
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  '选择属性',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: widget.propertiesList.length,
                    itemBuilder: (context, index) {
                      PropertiesType pt = widget.propertiesList[index];
                      bool isSelected = _selectedPropertyName == pt.name;

                      return GestureDetector(
                        onTap: () => _handlePropertyTap(pt),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 圆形背景容器
                            Container(
                              width: 40, // 圆形背景大小
                              height: 40, // 圆形背景大小
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected ? Colors.blue.shade100 : Colors.transparent,
                              ),
                              child: Center(
                                child: pt.imagePath != null
                                    ? Image.asset(
                                  pt.imagePath!,
                                  width: 24, // 图标大小
                                  height: 24, // 图标大小
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.error, size: 20, color: Colors.red);
                                  },
                                )
                                    : const Icon(Icons.question_mark, size: 20),
                              ),
                            ),
                            const SizedBox(height: 6),
                            // 属性名称
                            Text(
                              pt.name ?? '未知',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: widget.onClose,
                  child: const Text(
                    '关闭',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}