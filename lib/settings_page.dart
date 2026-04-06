import 'dart:ui';
import 'package:flutter/material.dart';
import 'theme_config.dart';
import 'database_helper.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // 切换主题底部弹窗
  void _showThemePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("选择主题", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Wrap(
                spacing: 15,
                runSpacing: 15,
                children: AppTheme.themeOptions.map((theme) {
                  return GestureDetector(
                    onTap: () {
                      AppTheme.backgroundColors.value = theme['colors'];
                      Navigator.pop(context);
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: theme['colors'],
                            ),
                            border: Border.all(color: Colors.black12, width: 2),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(theme['name'], style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // 确认清空数据弹窗
  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("⚠️ 警告"),
          content: const Text("这将会永久删除你写过的所有日记，且无法恢复。确定要继续吗？"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("取消", style: TextStyle(color: Colors.grey))),
            TextButton(
              onPressed: () async {
                await DatabaseHelper.instance.clearAllDiaries();
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("所有数据已清空")));
              },
              child: const Text("确认清空", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettingsItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: ListTile(
            onTap: onTap,
            tileColor: Colors.white.withOpacity(0.15),
            leading: Icon(icon, color: Colors.white),
            title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("设置", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // 动态响应全局主题
          ValueListenableBuilder<List<Color>>(
            valueListenable: AppTheme.backgroundColors,
            builder: (context, colors, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
                ),
              );
            },
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildSettingsItem(icon: Icons.color_lens_outlined, title: "个性化主题", onTap: _showThemePicker),
                _buildSettingsItem(icon: Icons.delete_sweep_outlined, title: "清空所有日记", onTap: _showClearDataDialog),
                _buildSettingsItem(
                  icon: Icons.info_outline,
                  title: "关于音乐随笔",
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => const AlertDialog(
                        title: Text("关于"),
                        content: Text("音乐随笔 v1.0.0\n\n由 ZhongHui 开发。"),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}