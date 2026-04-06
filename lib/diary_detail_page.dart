import 'dart:ui';
import 'dart:io'; // 处理本地文件
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // 引入插件
import 'database_helper.dart';
import 'theme_config.dart';

class DiaryDetailPage extends StatefulWidget {
  final Map<String, dynamic> diary;
  const DiaryDetailPage({super.key, required this.diary});
  @override
  State<DiaryDetailPage> createState() => _DiaryDetailPageState();
}

class _DiaryDetailPageState extends State<DiaryDetailPage> {
  late TextEditingController _contentController;
  bool _isEditing = false;
  late String _music;
  late String _weather;
  late String _location;

  // 编辑模式下的图片路径和选择器
  String? _editingImagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.diary['content']);
    _music = widget.diary['music'] ?? "无BGM";
    _weather = widget.diary['weather'] ?? "☀️ 晴";
    _location = widget.diary['location'] ?? "未知地点";
    _editingImagePath = widget.diary['imagePath']; // 初始化图片路径
  }

  // 选择图片方法
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
              leading: const Icon(Icons.photo_library), title: const Text("从相册选择"),
              onTap: () async {
                final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                if (image != null) { setState(() { _editingImagePath = image.path; }); }
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt), title: const Text("拍照"),
              onTap: () async {
                final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                if (image != null) { setState(() { _editingImagePath = image.path; }); }
                Navigator.pop(context);
              },
            ),
            if (_editingImagePath != null) // 增加删除图片的选项
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red), title: const Text("删除图片", style: TextStyle(color: Colors.red)),
                onTap: () { setState(() { _editingImagePath = null; }); Navigator.pop(context); },
              ),
          ],
        ),
      ),
    );
  }

  // 更新日记时传入新的图片路径
  void _updateEntry() async {
    await DatabaseHelper.instance.updateDiary(
      id: widget.diary['id'],
      content: _contentController.text,
      music: _music,
      weather: _weather,
      location: _location,
      imagePath: _editingImagePath, // 新增
    );
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    // 判断是否有图片且文件确实存在（防止相册图片被删除导致报错）
    bool hasValidImage = _editingImagePath != null && File(_editingImagePath!).existsSync();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Colors.white),
        actions: [IconButton(icon: Icon(_isEditing ? Icons.check : Icons.edit, color: Colors.white), onPressed: () { if (_isEditing) { _updateEntry(); } else { setState(() => _isEditing = true); } })],
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 顶部信息
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text("${widget.diary['time'].substring(0, 16)} · $_weather", style: const TextStyle(color: Colors.white70, fontSize: 14)), const SizedBox(height: 8),
                    Row(children: [const Icon(Icons.location_on, color: Colors.white70, size: 14), const SizedBox(width: 4), Text(_location, style: const TextStyle(color: Colors.white70, fontSize: 14))]),
                  ]),
                ),

                // 详情页展示图片（如果是编辑模式，点击可以更改）
                if (hasValidImage || _isEditing)
                  GestureDetector(
                    onTap: _isEditing ? _pickImage : null, // 只有编辑模式点击才有效
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      width: double.infinity,
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
                        border: _isEditing && !hasValidImage ? Border.all(color: Colors.white54, style: BorderStyle.solid) : null, // 编辑模式且无图时显示虚线框
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (hasValidImage)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(File(_editingImagePath!), width: double.infinity, height: 250, fit: BoxFit.cover),
                            ),
                          if (_isEditing) // 编辑模式下的遮罩和提示
                            Container(
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.black38),
                              child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.add_photo_alternate_outlined, color: Colors.white, size: 40), const SizedBox(height: 10), Text(hasValidImage ? "点击更换图片" : "点击添加图片", style: const TextStyle(color: Colors.white))])),
                            ),
                        ],
                      ),
                    ),
                  )
                else
                  const Divider(color: Colors.white24, height: 40), // 无图且非编辑模式显示分割线

                // 内容
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _isEditing
                        ? TextField(controller: _contentController, maxLines: null, style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.6), decoration: const InputDecoration(border: InputBorder.none), autofocus: true)
                        : SingleChildScrollView(child: Text(_contentController.text, style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.6))),
                  ),
                ),

                // 底部BGM
                Container(
                  margin: const EdgeInsets.all(20), padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
                  child: Row(children: [const Icon(Icons.music_note, color: Colors.white), const SizedBox(width: 10), Text(_music, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}