library smart_tab_view;

import 'package:flutter/material.dart';

/// Enum for tab placement
enum TabPosition { top, left }

/// A scroll-aware tab view widget with customizable tab widgets
class SmartTabView extends StatefulWidget {
  /// List of tab widgets (e.g., Text, Tab, Icon+Text, etc.)
  final List<Widget> tabs;

  /// List of corresponding content sections (must match tabs length)
  final List<Widget> sections;

  /// Layout direction of tabs (top/horizontal or left/vertical)
  final TabPosition tabPosition;

  const SmartTabView({
    super.key,
    required this.tabs,
    required this.sections,
    this.tabPosition = TabPosition.top,
  }) : assert(tabs.length == sections.length, "Tabs and sections must be equal");

  @override
  State<SmartTabView> createState() => _SmartTabViewState();
}

class _SmartTabViewState extends State<SmartTabView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _sectionKeys = [];
  bool isTabClicked = false;
  int? _pendingTabIndex;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.tabs.length, vsync: this);
    _sectionKeys.addAll(List.generate(widget.sections.length, (_) => GlobalKey()));
  }

  void _handleScroll() {
    if (isTabClicked) return;

    final topOffset = kToolbarHeight +
        MediaQuery.of(context).padding.top +
        kTextTabBarHeight;

    double getOffset(GlobalKey key) {
      final context = key.currentContext;
      if (context == null) return double.infinity;
      final box = context.findRenderObject() as RenderBox?;
      return box?.localToGlobal(Offset.zero).dy ?? double.infinity;
    }

    final offsets = _sectionKeys.map(getOffset).toList();

    for (int i = 0; i < offsets.length; i++) {
      final current = offsets[i];
      final next = i < offsets.length - 1 ? offsets[i + 1] : double.infinity;

      if (current < topOffset && next > topOffset) {
        if (_tabController.index != i) {
          _tabController.animateTo(i);
        }
        return;
      }
    }

    final position = _scrollController.position;
    if ((position.maxScrollExtent - position.pixels).abs() < 50) {
      if (_tabController.index != _sectionKeys.length - 1) {
        _tabController.animateTo(_sectionKeys.length - 1);
      }
    }
  }

  Future<void> _scrollTo(GlobalKey key, int index) async {
    isTabClicked = true;
    _pendingTabIndex = index;

    await Scrollable.ensureVisible(
      key.currentContext!,
      duration: const Duration(milliseconds: 400),
      alignment: 0,
      curve: Curves.easeInOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_pendingTabIndex == index) {
          _tabController.animateTo(index);
          isTabClicked = false;
        }
      });
    });
  }

  Widget _buildTabs() {
    return widget.tabPosition == TabPosition.top
        ? TabBar(
      controller: _tabController,
      isScrollable: true,
      labelColor: Colors.orange,
      unselectedLabelColor: Colors.grey,
      onTap: (index) => _scrollTo(_sectionKeys[index], index),
      tabs: widget.tabs,
    )
        : Container(
      width: 120,
      color: Colors.grey[100],
      child: ListView.builder(
        itemCount: widget.tabs.length,
        itemBuilder: (_, index) => InkWell(
          onTap: () => _scrollTo(_sectionKeys[index], index),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            color: _tabController.index == index
                ? Colors.orange.withOpacity(0.2)
                : Colors.transparent,
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: _tabController.index == index ? Colors.orange : Colors.black,
                fontWeight: _tabController.index == index ? FontWeight.bold : null,
              ),
              child: widget.tabs[index],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollUpdateNotification) {
          _handleScroll();
        }
        return false;
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: List.generate(
            widget.sections.length,
                (i) => Container(
              key: _sectionKeys[i],
              child: widget.sections[i],
            ),
          ),
        ),
      ),
    );

    return widget.tabPosition == TabPosition.top
        ? Column(
      children: [
        _buildTabs(),
        const Divider(height: 0),
        Expanded(child: content),
      ],
    )
        : Row(
      children: [
        _buildTabs(),
        const VerticalDivider(width: 1),
        Expanded(child: content),
      ],
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
