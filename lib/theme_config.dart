import 'package:flutter/material.dart';

class AppTheme {
  // 当前正在使用的全局背景颜色（使用 ValueNotifier 监听变化）
  static final ValueNotifier<List<Color>> backgroundColors = ValueNotifier<List<Color>>([
    const Color(0xFF2C3E50), const Color(0xFFFD746C), const Color(0xFFFF8235) // 默认：日落
  ]);

  // 主题
  static final List<Map<String, dynamic>> themeOptions = [
    {
      "name": "日落黄昏",
      "colors": [const Color(0xFF2C3E50), const Color(0xFFFD746C), const Color(0xFFFF8235)]
    },
    {
      "name": "深海暗夜",
      "colors": [const Color(0xFF0F2027), const Color(0xFF203A43), const Color(0xFF2C5364)]
    },
    {
      "name": "薄荷森林",
      "colors": [const Color(0xFF1D976C), const Color(0xFF93F9B9), const Color(0xFF93F9B9)]
    },
    {
      "name": "紫雾梦境",
      "colors": [const Color(0xFF41295a), const Color(0xFF2F0743), const Color(0xFF2F0743)]
    },
    {
      "name": "樱花初雪",
      "colors": [const Color(0xFFff9a9e), const Color(0xFFfecfef), const Color(0xFFfecfef)]
    },
  ];
}