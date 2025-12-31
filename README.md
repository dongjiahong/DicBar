# DicBar

macOS 状态栏英语查词工具，轻量优雅，随点随查。

![macOS](https://img.shields.io/badge/macOS-13.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)

## 功能特性

- 🔍 **实时搜索** - 输入即搜，前缀匹配
- 📖 **详细释义** - 英汉双解、例句、词形变化
- 🔄 **近义词辨析** - 同义词对比分析
- 🔊 **在线发音** - 美音/英音一键播放（有道 API）
- 📍 **状态栏驻留** - 无 Dock 图标，轻量运行

## 截图

点击状态栏图标即可打开查词面板。

## 安装

### 方式一：直接运行

```bash
open DicBar.app
```

### 方式二：复制到应用程序

```bash
cp -R DicBar.app /Applications/
```

## 从源码构建

### 依赖

- Xcode 15.0+
- macOS 13.0+

### 构建步骤

```bash
# 克隆项目
git clone <repository-url>
cd DicBar

# 构建
xcodebuild -project DicBar.xcodeproj -scheme DicBar -configuration Release build

# 运行
open ~/Library/Developer/Xcode/DerivedData/DicBar-*/Build/Products/Release/DicBar.app
```

## 项目结构

```
DicBar/
├── DicBar.xcodeproj      # Xcode 项目
├── Sources/
│   ├── App/              # 应用入口、AppDelegate
│   ├── Models/           # 数据模型
│   ├── Services/         # 数据库、音频服务
│   ├── Views/            # SwiftUI 视图
│   └── Utilities/        # 工具类
└── Resources/
    ├── dictionary.db     # SQLite 词典数据库
    └── Assets.xcassets   # 图标资源
```

## 技术栈

| 组件   | 技术                    |
| ------ | ----------------------- |
| 语言   | Swift 5.9               |
| UI     | SwiftUI + AppKit        |
| 数据库 | SQLite (GRDB.swift)     |
| 发音   | AVFoundation + 有道 API |

## 数据来源

词典数据库包含 **25,315** 个常用英语单词，每个单词包含：

- 音标
- 简明释义
- 详细释义（英汉双解）
- 例句
- 词形变化
- 近义词辨析

## License

MIT License
