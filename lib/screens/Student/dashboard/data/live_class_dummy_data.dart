// data/dummy_data.dart

 

import 'package:brainboosters_app/screens/Student/dashboard/data/models/live_class_model.dart';

class LiveClassDummyData {
  static final List<LiveClass> liveClasses = [
    LiveClass(
      id: "lc001",
      slug: "generative-ai-prompt-engineering-basics",
      title: "Generative AI: Prompt Engineering Basics",
      description: "Learn the fundamentals of prompt engineering for AI models like ChatGPT, Claude, and other LLMs.",
      imageUrl: "https://picsum.photos/200/200?random=1",
      startTime: DateTime.now().add(const Duration(hours: 2)),
      endTime: DateTime.now().add(const Duration(hours: 3, minutes: 30)),
      academy: "Leader Academy",
      teachers: ["Dr. Sarah Johnson", "Prof. Mike Chen"],
      category: "Technology",
      subject: "Artificial Intelligence",
      duration: 90,
      isLive: false,
      isRecorded: true,
      maxParticipants: 100,
      currentParticipants: 67,
      price: 0.0,
      difficulty: "Beginner",
      tags: ["AI", "Prompt Engineering", "ChatGPT", "LLM"],
      meetingLink: "https://meet.google.com/abc-defg-hij",
      status: "upcoming",
    ),
    LiveClass(
      id: "lc002",
      slug: "ai-security-essentials",
      title: "AI Security Essentials",
      description: "Understanding security challenges and best practices in AI systems and machine learning models.",
      imageUrl: "https://picsum.photos/200/200?random=2",
      startTime: DateTime.now().add(const Duration(days: 1, hours: 6)),
      endTime: DateTime.now().add(const Duration(days: 1, hours: 7, minutes: 45)),
      academy: "Leader Academy",
      teachers: ["Dr. Alex Rodriguez", "Ms. Emily Watson"],
      category: "Technology",
      subject: "Cybersecurity",
      duration: 105,
      isLive: true,
      isRecorded: true,
      maxParticipants: 150,
      currentParticipants: 89,
      price: 29.99,
      difficulty: "Intermediate",
      tags: ["AI Security", "Cybersecurity", "Machine Learning", "Privacy"],
      meetingLink: "https://zoom.us/j/123456789",
      status: "upcoming",
    ),
    LiveClass(
      id: "lc003",
      slug: "artificial-intelligence-machine-learning",
      title: "Artificial Intelligence and Machine Learning",
      description: "Comprehensive introduction to AI and ML concepts, algorithms, and real-world applications.",
      imageUrl: "https://picsum.photos/200/200?random=3",
      startTime: DateTime(2025, 5, 25, 18, 0),
      endTime: DateTime(2025, 5, 25, 20, 0),
      academy: "Leader Academy",
      teachers: ["Prof. David Kim", "Dr. Lisa Zhang", "Mr. Robert Brown"],
      category: "Technology",
      subject: "Machine Learning",
      duration: 120,
      isLive: true,
      isRecorded: true,
      maxParticipants: 200,
      currentParticipants: 156,
      price: 49.99,
      difficulty: "Advanced",
      tags: ["AI", "Machine Learning", "Deep Learning", "Neural Networks"],
      meetingLink: "https://teams.microsoft.com/l/meetup-join/xyz",
      status: "upcoming",
    ),
    LiveClass(
      id: "lc004",
      slug: "python-for-data-science",
      title: "Python for Data Science",
      description: "Master Python programming for data analysis, visualization, and machine learning applications.",
      imageUrl: "https://picsum.photos/200/200?random=4",
      startTime: DateTime.now().add(const Duration(days: 2, hours: 4)),
      endTime: DateTime.now().add(const Duration(days: 2, hours: 6)),
      academy: "Tech Institute",
      teachers: ["Ms. Anna Thompson", "Mr. James Wilson"],
      category: "Programming",
      subject: "Data Science",
      duration: 120,
      isLive: false,
      isRecorded: true,
      maxParticipants: 80,
      currentParticipants: 45,
      price: 39.99,
      difficulty: "Intermediate",
      tags: ["Python", "Data Science", "Pandas", "NumPy", "Matplotlib"],
      meetingLink: "https://meet.google.com/python-data-science",
      status: "upcoming",
    ),
    LiveClass(
      id: "lc005",
      slug: "web-development-fundamentals",
      title: "Web Development Fundamentals",
      description: "Learn HTML, CSS, and JavaScript basics to build modern web applications from scratch.",
      imageUrl: "https://picsum.photos/200/200?random=5",
      startTime: DateTime.now().subtract(const Duration(hours: 1)),
      endTime: DateTime.now().add(const Duration(hours: 1)),
      academy: "Code Academy",
      teachers: ["Mr. Chris Martinez", "Ms. Jessica Lee"],
      category: "Programming",
      subject: "Web Development",
      duration: 120,
      isLive: true,
      isRecorded: true,
      maxParticipants: 120,
      currentParticipants: 98,
      price: 0.0,
      difficulty: "Beginner",
      tags: ["HTML", "CSS", "JavaScript", "Web Development", "Frontend"],
      meetingLink: "https://zoom.us/j/webdev123",
      status: "live",
    ),
  ];

  // Helper methods
  static List<LiveClass> getUpcomingClasses() {
    return liveClasses.where((lc) => lc.status == "upcoming").toList();
  }

  static List<LiveClass> getLiveClasses() {
    return liveClasses.where((lc) => lc.status == "live").toList();
  }

  static List<LiveClass> getClassesByCategory(String category) {
    return liveClasses.where((lc) => lc.category == category).toList();
  }

  static List<LiveClass> getFreeClasses() {
    return liveClasses.where((lc) => lc.price == 0.0).toList();
  }
}
