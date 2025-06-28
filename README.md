# SmartTabView

[![pub version](https://img.shields.io/pub/v/smart_tab_view)](https://pub.dev/packages/smart_tab_view)  
[![GitHub Repo](https://img.shields.io/badge/github-smart__tab__view-blue?logo=github)](https://github.com/darshanjethva566/smart_tab_view)

A scroll-aware tab view widget that automatically syncs the selected tab with scroll position. Supports both horizontal (top) and vertical (left) tab layouts. Perfect for multi-section pages with dynamic content.

---

## ✨ Features

- ✅ Auto tab selection while scrolling through sections (like Blinkit/Swiggy/Zomato)
- 🧭 Scroll-to-section on tab tap
- ↕️ Supports both top (horizontal) and left (vertical) tab layouts
- 🎨 Accepts custom widgets for both tabs and sections
- 📱 Responsive & lightweight integration with customizable properties
- 📏 Handles short sections using minimum height constraints

---

## ⚠️ Important Note

To ensure proper scrolling and tab synchronization:

> 🔸 Each section should have enough vertical content.  
> If all sections are very short (e.g., only 1–2 lines), the page will not scroll, and automatic tab switching will not work as expected.

📌 **Best Practice:** Use more content per section or apply a `minHeight` constraint to ensure a scrollable layout.

---

## 📦 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  smart_tab_view: ^<latest_version>
