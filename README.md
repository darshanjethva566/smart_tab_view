# SmartTabView

[![pub version](https://img.shields.io/pub/v/smart_tab_view)](https://pub.dev/packages/smart_tab_view)
[![GitHub Repo](https://img.shields.io/badge/github-smart__tab__view-blue?logo=github)](https://github.com/darshanjethva566/smart_tab_view)

A scroll-aware tab view widget that syncs tab selection based on scroll and supports both horizontal and vertical tab layouts.

---

## ✨ Features

- Auto-selects tab while scrolling through sections
- Supports both `horizontal` and `vertical` tab layouts
- Custom widgets for both tabs and sections
- Lightweight and easy to integrate

---

## 🚀 Usage

```dart
SmartTabView(
  tabPosition: TabPosition.top, // or TabPosition.left
  tabs: const [
    Tab(text: "Overview"),
    Tab(text: "Benefits"),
    Tab(text: "Process"),
    Tab(text: "Requirement"),
  ],
  sections: const [
    MySection(title: 'Overview'),
    MySection(title: 'Benefits'),
    MySection(title: 'Process'),
    MySection(title: 'Requirement'),
  ],
)
