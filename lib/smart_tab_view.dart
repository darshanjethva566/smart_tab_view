library smart_tab_view;

import 'package:flutter/material.dart';

enum TabPosition { top, left }

class SmartTabView extends StatefulWidget {
  final List<Widget> tabs;
  final List<Widget> sections;
  final TabPosition tabPosition;
  final double verticalTabWidth;
  final EdgeInsetsGeometry? verticalTabPadding;
  final Color? verticalTabBgColor;
  final Color? selectedTabColor;
  final Color? unselectedTabColor;
  final Color? indicatorColor;
  final bool isScrollable;

  const SmartTabView({
    super.key,
    required this.tabs,
    required this.sections,
    this.tabPosition = TabPosition.top,
    this.verticalTabWidth = 120,
    this.verticalTabPadding,
    this.verticalTabBgColor,
    this.selectedTabColor = Colors.orange,
    this.unselectedTabColor = Colors.grey,
    this.indicatorColor,
    this.isScrollable = true,
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
  int _currentVisibleIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.tabs.length, vsync: this);
    _sectionKeys.addAll(List.generate(widget.sections.length, (_) => GlobalKey()));
    // The listener on the controller is sufficient.
    _scrollController.addListener(_handleScroll);
  }

  // ----------------- [ START OF FIXED CODE ] -----------------

  void _handleScroll() {
    // If a tab was just clicked, ignore scroll events to avoid conflicts.
    if (isTabClicked || !mounted) return;

    // Calculate the offset from the top of the screen where a section is considered "active".
    // This accounts for the status bar and the TabBar if it's on top.
    final topOffset = MediaQuery.of(context).padding.top +
        (widget.tabPosition == TabPosition.top
            ? kToolbarHeight + kTextTabBarHeight // Approximate height of AppBar + TabBar
            : 0);

    // Find the first section (iterating from the end) that is visible at the top.
    // This is more robust than the previous forward-iterating logic.
    int? visibleIndex;
    for (int i = _sectionKeys.length - 1; i >= 0; i--) {
      final key = _sectionKeys[i];
      final context = key.currentContext;
      if (context != null) {
        final box = context.findRenderObject() as RenderBox;
        final position = box.localToGlobal(Offset.zero);

        // If the top of the section is at or above our target offset,
        // it's the one we're currently viewing.
        if (position.dy <= topOffset) {
          visibleIndex = i;
          break; // Found the active section, no need to check earlier ones.
        }
      }
    }

    // If a visible section was found and it's different from the current one, update the tab.
    if (visibleIndex != null && _currentVisibleIndex != visibleIndex) {
      setState(() {
        _currentVisibleIndex = visibleIndex!;
      });
      _tabController.animateTo(visibleIndex!);
    }
  }

  // ----------------- [  END OF FIXED CODE  ] -----------------


  Future<void> _scrollTo(GlobalKey key, int index) async {
    // Set a flag to indicate that the scroll is initiated by a tab click.
    isTabClicked = true;
    _currentVisibleIndex = index; // Update the index immediately for responsive UI
    _tabController.animateTo(index); // Animate tab change right away
    setState(() {});

    // Ensure the section is visible.
    await Scrollable.ensureVisible(
      key.currentContext!,
      duration: const Duration(milliseconds: 400),
      alignment: 0.0, // Scroll to the very top of the section
      curve: Curves.easeInOut,
    );

    // After scrolling, reset the flag.
    // A small delay ensures the scroll listener doesn't misfire.
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      isTabClicked = false;
    }
  }

  Widget _buildTabs() {
    if (widget.tabPosition == TabPosition.top) {
      return TabBar(
        controller: _tabController,
        isScrollable: widget.isScrollable,
        labelColor: widget.selectedTabColor,
        unselectedLabelColor: widget.unselectedTabColor,
        indicatorColor: widget.indicatorColor ?? widget.selectedTabColor,
        onTap: (index) => _scrollTo(_sectionKeys[index], index),
        tabs: widget.tabs,
      );
    } else {
      return Container(
        width: widget.verticalTabWidth,
        color: widget.verticalTabBgColor ?? Colors.grey[200],
        child: ListView.builder(
          physics: const ClampingScrollPhysics(),
          itemCount: widget.tabs.length,
          itemBuilder: (_, index) {
            final isSelected = _currentVisibleIndex == index;
            return InkWell(
              onTap: () => _scrollTo(_sectionKeys[index], index),
              child: Container(
                padding: widget.verticalTabPadding ??
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: isSelected ? (widget.selectedTabColor ?? Colors.orange) : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  color: isSelected
                      ? (widget.selectedTabColor ?? Colors.orange).withOpacity(0.15)
                      : Colors.transparent,
                ),
                child: DefaultTextStyle.merge(
                  style: TextStyle(
                    color: isSelected
                        ? widget.selectedTabColor ?? Colors.orange
                        : widget.unselectedTabColor ?? Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  child: widget.tabs[index],
                ),
              ),
            );
          },
        ),
      );
    }
  }

  Widget _buildContent() {
    // The NotificationListener was redundant because we already have a listener
    // on the _scrollController. Removing it prevents _handleScroll from being
    // called twice for every scroll event.
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const ClampingScrollPhysics(),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.tabPosition == TabPosition.top
        ? Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        _buildTabs(),
        const Divider(height: 1, thickness: 1),
        Expanded(child: _buildContent()),
      ],
    )
        : Row(
      children: [
        _buildTabs(),
        const VerticalDivider(width: 1, thickness: 1),
        Expanded(child: _buildContent()),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}