- # 🎵 音乐日记 (Music Diary)

  **让音乐与影像，镌刻生活的每一个瞬间。**

  这是一个基于 **Flutter** 开发的个人日记应用。它不仅仅是文字的堆砌，更是情感的载体——你可以为每一篇日记配上此时此刻的 BGM、捕捉当下的光影图片，并通过 GitHub 风格的热力图见证自己的成长。

  ------

  ## ✨ 功能特性

  - **🎧 随心旋律 (BGM Integration)**：支持为每篇日记添加背景音乐名称，记录文字时的听觉氛围。
  - **📸 定格瞬间 (Local Images)**：集成 `image_picker`，支持从相册选择或直接拍摄照片存入日记。
  - **📊 习惯足迹 (GitHub Heatmap)**：内置平滑渐变绿色的热力图，直观展现你的创作频率。
  - **🔍 灵感搜索 (Smart Search)**：支持全文搜索，通过关键词快速唤醒深藏的回忆。
  - **💾 本地持久化 (SQLite)**：基于 `sqflite` 实现高性能本地存储，数据安全触手可及。

  ------

  ## 🛠️ 技术栈

  - **框架**: Flutter (Dart)
  - **数据库**: Sqflite (支持数据库平滑升级)
  - **状态管理**: StatefulWidget & ValueNotifier
  - **插件**:
    - `image_picker`: 图像获取
    - `flutter_heatmap_calendar`: 热力图渲染
    - `intl`: 时间格式化处理

  ------

  ## 🚀 快速开始

  ### 环境要求

  - Flutter SDK: `^3.0.0`
  - Dart SDK: `^3.0.0`
  - 已开启 **Windows 开发者模式**（仅限 Windows 平台运行）

  ### 安装步骤

  1. **克隆仓库**

     Bash

     ```
     git clone https://github.com/your-username/music_diary.git
     ```

  2. **安装依赖**

     Bash

     ```
     flutter pub get
     ```

  3. **运行应用**

     Bash

     ```
     flutter run
     ```

  ------

  ## 📂 项目结构

  Plaintext

  ```
  lib/
  ├── main.dart                # 应用入口及写日记页面
  ├── diary_list_page.dart     # 日记列表、热力图及搜索
  ├── diary_detail_page.dart   # 日记详情与编辑页面
  ├── database_helper.dart     # SQLite 数据库逻辑 (v2 版本)
  └── theme_config.dart        # 颜色与主题配置
  ```

  ------

  ## 📝 开发者说明

  开发时间较短，两天vibe coding而成。在开发过程中，对数据库进行了版本升级（Version 2），新增了 `imagePath` 字段以支持图片路径存储。同时，为了适配不同的系统背景，热力图采用了 `0xFFC8E6C9` 到 `0xFF388E3C` 的自然绿色过渡算法。

  ------

  ## 🤝 制作

  Made with ❤️ by **ZhongHui**
