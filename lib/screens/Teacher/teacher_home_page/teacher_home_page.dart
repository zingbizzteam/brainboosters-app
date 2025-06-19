import 'package:brainboosters_app/screens/Student/dashboard/widgets/Dashboard_topBar.dart';
import 'package:flutter/material.dart';
import 'widgets/stat_card.dart';
import 'widgets/live_class_list.dart';
import 'widgets/enrolled_course_list.dart';

class TeacherHomePage extends StatefulWidget {
  const TeacherHomePage({super.key});
  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFD),
      body: Row(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SafeArea(
                  // <-- Wrap here!
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWide ? 32 : 16,
                      vertical: isWide ? 24 : 12,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top bar
                          const DashboardTopBar(),
                          SizedBox(height: isWide ? 32 : 20),
                          // Stats Cards
                          isWide
                              ? Row(
                                  children: [
                                    Flexible(
                                      child: DashboardStatCard(
                                        title: "Hello Teacher!",
                                        subtitle:
                                            "Teacher Home page is under development.",
                                        icon: Icons.local_fire_department,
                                        iconColor: Colors.blue,
                                        stats: [
                                          StatItem("5", "Current"),
                                          StatItem("26", "Longest"),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Flexible(
                                      child: DashboardStatCard(
                                        title: "",
                                        subtitle: "Total Watch Hours",
                                        icon: Icons.play_circle_fill,
                                        iconColor: Colors.blue,
                                        stats: [StatItem("24", "")],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Flexible(
                                      child: DashboardStatCard(
                                        title: "",
                                        subtitle: "Total No. of Lessons",
                                        icon: Icons.bar_chart,
                                        iconColor: Colors.blue,
                                        stats: [StatItem("12", "")],
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    DashboardStatCard(
                                      title: "Learning Streak",
                                      subtitle:
                                          "Watch 5 mins a day to obtain a streak.",
                                      icon: Icons.local_fire_department,
                                      iconColor: Colors.blue,
                                      stats: [
                                        StatItem("5", "Current"),
                                        StatItem("26", "Longest"),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: DashboardStatCard(
                                            title: "",
                                            subtitle: "Total Watch Hours",
                                            icon: Icons.play_circle_fill,
                                            iconColor: Colors.blue,
                                            stats: [StatItem("24", "")],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: DashboardStatCard(
                                            title: "",
                                            subtitle: "Total No. of Lessons",
                                            icon: Icons.bar_chart,
                                            iconColor: Colors.blue,
                                            stats: [StatItem("12", "")],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                          SizedBox(height: isWide ? 32 : 20),
                          // Enrolled Live Classes
                          const Text(
                            "Enrolled Live Classes",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const LiveClassList(),
                          SizedBox(height: isWide ? 24 : 16),
                          // Enrolled Courses
                          const Text(
                            "Enrolled Courses",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const EnrolledCourseList(),
                          SizedBox(height: isWide ? 24 : 16),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
