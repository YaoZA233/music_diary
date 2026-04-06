import 'dart:ui';
import 'dart:io'; // 用于处理 File 图片
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart'; // 引入插件
import 'diary_list_page.dart';
import 'database_helper.dart';
import 'theme_config.dart';

void main() { runApp(const MyApp()); }

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, title: '音乐日记',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const DiaryListPage(),
    );
  }
}

class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});
  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  final TextEditingController _contentController = TextEditingController();
  String musicName = "未选择"; String selectedWeather = "☀️ 晴";
  String locationName = "地球某处"; String currentDateStr = "";
  final List<String> weathers = ["☀️ 晴", "☁️ 多云", "🌧️ 雨", "⛄ 雪", "⚡ 雷雨", "🌫️ 雾"];

  // 图片相关变量和方法
  String? _selectedImagePath; // 存储选中的图片路径
  final ImagePicker _picker = ImagePicker(); // 图片选择器实例

  // 选择图片的方法
  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.9),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("从相册选择"),
              onTap: () async {
                final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80); // 压缩一下质量，防止图片太大
                if (image != null) {
                  setState(() { _selectedImagePath = image.path; });
                }
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("拍照"),
              onTap: () async {
                final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                if (image != null) {
                  setState(() { _selectedImagePath = image.path; });
                }
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    currentDateStr = DateFormat('yyyy年MM月dd日 HH:mm').format(DateTime.now());
  }

  // 保存时传入图片路径
  void saveDiary() async {
    if (_contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("此刻的想法，不记录下来吗？")));
      return;
    }
    await DatabaseHelper.instance.insertDiary(
      content: _contentController.text,
      music: musicName,
      weather: selectedWeather,
      location: locationName,
      imagePath: _selectedImagePath, // 新增
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("日记已珍藏。")));
    Navigator.pop(context);
  }


  void selectMusic() { showDialog(context: context, builder: (context) { TextEditingController musicController = TextEditingController(); return AlertDialog(title: const Text("🎵 此时此刻的BGM"), content: TextField(controller: musicController), actions: [TextButton(onPressed: () { setState(() => musicName = musicController.text.isEmpty ? "无BGM" : musicController.text); Navigator.pop(context); }, child: const Text("确定"))],);});}
  void selectWeatherDialog() { showDialog(context: context, builder: (context) { return AlertDialog(title: const Text("🌈 窗外的天气情况"), content: SizedBox(width: double.maxFinite, child: GridView.builder( shrinkWrap: true, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10), itemCount: weathers.length, itemBuilder: (context, index) { return InkWell( onTap: () { setState(() => selectedWeather = weathers[index]); Navigator.pop(context); }, child: Container(alignment: Alignment.center, child: Text(weathers[index])), );},)),);});}
  void inputLocationDialog() { showDialog(context: context, builder: (context) { TextEditingController locController = TextEditingController(); return AlertDialog(title: const Text("📍 身在何方"), content: TextField(controller: locController), actions: [TextButton(onPressed: () { setState(() => locationName = locController.text.isEmpty ? "未命名地点" : locController.text); Navigator.pop(context); }, child: const Text("确定"))],);});}

  Widget _buildInfoTag({required IconData icon, required String text, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ClipRRect(borderRadius: BorderRadius.circular(20), child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), child: InkWell(
        onTap: onTap, child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.2))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: Colors.white70, size: 16), const SizedBox(width: 4), Text(text, style: const TextStyle(color: Colors.white, fontSize: 13))]),
      ),
      ),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(currentDateStr, style: const TextStyle(color: Colors.white70, fontSize: 16)),
        backgroundColor: Colors.transparent, elevation: 0, centerTitle: true, iconTheme: const IconThemeData(color: Colors.white),
        actions: [TextButton(onPressed: saveDiary, child: const Text("保存", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)))],
      ),
      body: Stack(
        children: [
          ValueListenableBuilder<List<Color>>(
            valueListenable: AppTheme.backgroundColors,
            builder: (context, colors, child) {
              return Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors)));
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [
                      _buildInfoTag(icon: Icons.wb_sunny_outlined, text: selectedWeather, onTap: selectWeatherDialog),
                      _buildInfoTag(icon: Icons.location_on_outlined, text: locationName, onTap: inputLocationDialog),
                      // 添加图片的标签
                      _buildInfoTag(
                          icon: _selectedImagePath == null ? Icons.add_photo_alternate_outlined : Icons.collections_outlined,
                          text: _selectedImagePath == null ? "添加图片" : "更换图片",
                          onTap: _pickImage
                      ),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  // 图片预览区域
                  if (_selectedImagePath != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(File(_selectedImagePath!), width: double.infinity, height: 200, fit: BoxFit.cover), // 使用 Image.file 展示本地图片
                          ),
                          Positioned(
                            right: 8, top: 8,
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedImagePath = null), // 删除选中的图片
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                child: const Icon(Icons.close, color: Colors.white, size: 20),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),

                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
                      child: TextField(
                        controller: _contentController, maxLines: null, keyboardType: TextInputType.multiline, style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.6),
                        decoration: InputDecoration(hintText: "写下今天的故事...", hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)), border: InputBorder.none),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.1))),
                        child: Row(
                          children: [
                            const Icon(Icons.music_note_rounded, color: Colors.white, size: 28), const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("BGM", style: TextStyle(color: Colors.white70, fontSize: 12)), Text(musicName, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))])),
                            OutlinedButton(
                              onPressed: selectMusic,
                              style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                              child: const Text("更改"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}