library smart_tab_view;

import 'package:flutter/material.dart';

enum TabPosition { top, left }

class SmartTabView extends StatefulWidget {
  final List<Widget> tabs;
  final List<Widget> sections;
  final TabPosition tabPosition;
  final double verticalTabWidth;

  /// Use this for general padding (applied to both horizontal and vertical tabs if provided).
  final EdgeInsetsGeometry? tabPadding;

  /// Optional: only used for vertical tabs if `tabPadding` is not provided.
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
    this.tabPadding,
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
  int? _pendingTabIndex;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.tabs.length, vsync: this);
    _sectionKeys.addAll(List.generate(widget.sections.length, (_) => GlobalKey()));
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (isTabClicked || !mounted) return;

    final topOffset = MediaQuery.of(context).padding.top +
        (widget.tabPosition == TabPosition.top
            ? kToolbarHeight + kTextTabBarHeight
            : 0);

    int? visibleIndex;
    for (int i = _sectionKeys.length - 1; i >= 0; i--) {
      final key = _sectionKeys[i];
      final context = key.currentContext;
      if (context != null) {
        final box = context.findRenderObject() as RenderBox;
        final position = box.localToGlobal(Offset.zero);
        if (position.dy <= topOffset) {
          visibleIndex = i;
          break;
        }
      }
    }

    if (visibleIndex != null && _currentVisibleIndex != visibleIndex) {
      setState(() {
        _currentVisibleIndex = visibleIndex!;
      });
      _tabController.animateTo(visibleIndex);
    }
  }

  Future<void> _scrollTo(GlobalKey key, int index) async {
    isTabClicked = true;
    _pendingTabIndex = index;

    final context = key.currentContext;
    if (context != null) {
      await Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 400),
        alignment: 0.0,
        curve: Curves.easeInOut,
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_pendingTabIndex == index && mounted) {
          setState(() {
            _currentVisibleIndex = index;
            isTabClicked = false;
          });
          _tabController.animateTo(index);
        }
      });
    });
  }

  Widget _buildTabs() {
    final padding = widget.tabPadding;

    if (widget.tabPosition == TabPosition.top) {
      return TabBar(
        controller: _tabController,
        isScrollable: widget.isScrollable,
        labelColor: widget.selectedTabColor,
        unselectedLabelColor: widget.unselectedTabColor,
        indicatorColor: widget.indicatorColor ?? widget.selectedTabColor,
        onTap: (index) => _scrollTo(_sectionKeys[index], index),
        tabAlignment: TabAlignment.start,
        tabs: widget.tabs
            .asMap()
            .entries
            .map((entry) => Padding(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: entry.value,
        ))
            .toList(),
      );
    } else {
      return Container(
        width: widget.verticalTabWidth,
        color: widget.verticalTabBgColor ?? Colors.grey[200],
        child: ListView.builder(
          itemCount: widget.tabs.length,
          physics: const ClampingScrollPhysics(),
          itemBuilder: (_, index) {
            final isSelected = _currentVisibleIndex == index;
            return InkWell(
              onTap: () => _scrollTo(_sectionKeys[index], index),
              child: Container(
                padding: padding ??
                    widget.verticalTabPadding ??
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: isSelected
                          ? (widget.selectedTabColor ?? Colors.orange)
                          : Colors.transparent,
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
