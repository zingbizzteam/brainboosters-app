// screens/widgets/common/tab_section_widget.dart
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
    final isMobile = screenWidth <= 768;
    
    return Column(
      children: [
        // Tab Bar
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
          ),
          child: TabBar(
            controller: tabController,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: Colors.blue,
            indicatorWeight: 2,
            isScrollable: isMobile,
            labelStyle: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.normal,
            ),
            tabs: tabs.map((tab) => Tab(text: tab)).toList(),
          ),
        ),
        
        // Tab Content
        SizedBox(
          height: 400,
          child: TabBarView(
            controller: tabController,
            children: tabViews,
          ),
        ),
      ],
    );
  }
}
