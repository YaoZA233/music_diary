import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'database_helper.dart';
import 'main.dart';
import 'diary_detail_page.dart';
import 'theme_config.dart'; // 引入主题
import 'settings_page.dart'; // 引入设置页

class DiaryListPage extends StatefulWidget {
  const DiaryListPage({super.key});
  @override
  State<DiaryListPage> createState() => _DiaryListPageState();
}

class _DiaryListPageState extends State<DiaryListPage> {
  List<Map<String, dynamic>> allDiaries = [];
  List<Map<String, dynamic>> displayedDiaries = [];
  Map<DateTime, int> heatMapDatasets = {};
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  int totalCount = 0;
  int totalWords = 0;

  @override
  void initState() {
    super.initState();
    loadDiaries();
  }

  Future<void> loadDiaries() async {
    final data = await DatabaseHelper.instance.getDiaries();
    int words = 0;
    Map<DateTime, int> datasets = {};

    for (var diary in data) {
      words += (diary['content'] as String).length;
      try {
        // 将时间解析后，只保留年、月、日，去掉时分秒
        DateTime fullDate = DateTime.parse(diary['time']);
        DateTime pureDate = DateTime(fullDate.year, fullDate.month, fullDate.day);

        // 累计当天的日记篇数
        datasets[pureDate] = (datasets[pureDate] ?? 0) + 1;
      } catch (e) {
        print("日期解析出错: $e");
      }
    }

    setState(() {
      allDiaries = data;
      displayedDiaries = data;
      totalCount = data.length;
      totalWords = words;
      heatMapDatasets = datasets; // 更新数据集
    });
  }

  void _runFilter(String enteredKeyword) {
    setState(() {
      displayedDiaries = enteredKeyword.isEmpty ? allDiaries : allDiaries.where((diary) => diary['content'].toString().toLowerCase().contains(enteredKeyword.toLowerCase())).toList();
    });
  }

  void deleteDiary(int id) async {
    await DatabaseHelper.instance.deleteDiary(id);
    loadDiaries();
  }

  void goToWritePage() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => const DiaryPage()));
    loadDiaries();
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
          controller: _searchController, autofocus: true, style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(hintText: "搜索日记...", border: InputBorder.none, hintStyle: TextStyle(color: Colors.white54)),
          onChanged: (value) => _runFilter(value),
        )
            : const Text("我的记录", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // 非搜索状态显示设置按钮
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
                loadDiaries(); // 从设置页回来后刷新数据（如果清空了数据，列表会归零）
              },
            ),
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) { _searchController.clear(); _runFilter(""); }
              });
            },
          )
        ],
      ),
      body: Stack(
        children: [
          // 动态监听主题背景
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
          ListView(
            padding: const EdgeInsets.only(top: 100, bottom: 80),
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem("累计篇数", totalCount.toString()),
                        Container(width: 1, height: 30, color: Colors.white24),
                        _buildStatItem("累计字数", totalWords.toString()),
                      ],
                    ),
                    const SizedBox(height: 20),
                    HeatMap(
                      datasets: heatMapDatasets,
                      colorMode: ColorMode.color, // 颜色深浅
                      showText: false,
                      scrollable: true,
                      startDate: DateTime.now().subtract(const Duration(days: 90)), // 显示最近三个月
                      endDate: DateTime.now(),

                      // 1-5篇及以上的颜色
                      colorsets: {
                        1: const Color(0xFFC8E6C9), // 自然淡绿色
                        2: const Color(0xFFA5D6A7), // 2篇：淡绿色
                        3: const Color(0xFF81C784), // 3篇：标准绿
                        4: const Color(0xFF66BB6A), // 4篇：中绿色
                        5: const Color(0xFF388E3C), // 深绿色
                      },
                      defaultColor: Colors.white10,
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text("最近日记", style: TextStyle(color: Colors.white70, fontSize: 14)),
              ),
              ...displayedDiaries.map((item) {
                return Dismissible(
                  key: Key(item['id'].toString()), direction: DismissDirection.endToStart,
                  onDismissed: (direction) => deleteDiary(item['id']),
                  background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
                  child: _buildDiaryCard(item),
                );
              }).toList(),
              const Padding(
                padding: EdgeInsets.only(top: 24, bottom: 16),
                child: Center(child: Text("Made by ZhongHui", style: TextStyle(color: Colors.white54, fontSize: 12))),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: goToWritePage,
        backgroundColor: Colors.white,
        child: const Icon(Icons.edit, color: Colors.black87), // 图标颜色适配
      ),
    );
  }

  Widget _buildDiaryCard(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () async {
        bool? updated = await Navigator.push(context, MaterialPageRoute(builder: (context) => DiaryDetailPage(diary: item)));
        if (updated == true) loadDiaries();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(item['time'].toString().substring(5, 16), style: const TextStyle(color: Colors.white60, fontSize: 12)),
                      const Spacer(),
                      Text("${item['weather'] ?? '☀️'} · ${item['location'] ?? '地球'}", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(item['content'], maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}