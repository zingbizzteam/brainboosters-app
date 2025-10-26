// lib/screens/common/widgets/tab_section_widget.dart

import 'package:flutter/material.dart';

class TabSectionWidget extends StatelessWidget {
  final TabController tabController;
  final List<String> tabs;
  final List<Widget> tabViews;

  const TabSectionWidget({
    super.key,
    required this.tabController,
    required this.tabs,
    required this.tabViews,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 768 && screenWidth <= 1200;
    final isMobile = screenWidth <= 768;

    // ✅ FIXED: Use scrollable tabs on mobile, fixed on desktop
    final bool isScrollable = isMobile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
          ),
          child: TabBar(
            controller: tabController,
            // ✅ FIXED: Only use TabAlignment.start when isScrollable is true
            tabAlignment: isScrollable ? TabAlignment.start : null,
            isScrollable: isScrollable,
            indicatorColor: Theme.of(context).primaryColor,
            indicatorWeight: 3,
            labelColor: Colors.black,
            labelStyle: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelColor: Colors.grey[600],
            unselectedLabelStyle: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.normal,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 20 : (isTablet ? 16 : 0),
            ),
            labelPadding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 24,
            ),
            tabs: tabs.map((tab) => Tab(text: tab)).toList(),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: tabViews,
          ),
        ),
      ],
    );
  }
}
