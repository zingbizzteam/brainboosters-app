// data/live_class_dummy_data.dart
import 'package:brainboosters_app/screens/common/live_class/models/live_class_model.dart';

class LiveClassDummyData {
  static final List<LiveClass> liveClasses = [
    LiveClass(
      id: "lc001",
      slug: "generative-ai-prompt-engineering-basics",
      title: "Generative AI: Prompt Engineering Basics",
      description:
          "Learn the fundamentals of prompt engineering for AI models like ChatGPT, Claude, and other LLMs. Master the art of crafting effective prompts to get better results from AI systems.",
      imageUrl: "https://picsum.photos/400/300?random=1",
      thumbnailUrl: "https://picsum.photos/200/200?random=1",
      startTime: DateTime.now().add(const Duration(hours: 2)),
      endTime: DateTime.now().add(const Duration(hours: 3, minutes: 30)),
      academy: "Leader Academy",
      teachers: ["Dr. Sarah Johnson", "Prof. Mike Chen"],
      instructor: "Dr. Sarah Johnson",
      category: "Technology",
      subject: "Artificial Intelligence",
      duration: 90,
      isLive: false,
      isRecorded: true,
      isFree: true,
      maxParticipants: 100,
      currentParticipants: 67,
      price: 0.0,
      difficulty: "Beginner",
      tags: ["AI", "Prompt Engineering", "ChatGPT", "LLM"],
      meetingLink: "https://meet.google.com/abc-defg-hij",
      status: "upcoming",
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      rating: 4.6,
      totalRatings: 234,
      prerequisites: ["Basic computer skills", "Interest in AI"],
      language: "English",
      isRecordingAvailable: true,
      recordingUrl: "https://example.com/recordings/lc001",
      metadata: {
        "level": "introductory",
        "certification": true,
        "materials_included": true,
      },
    ),
    LiveClass(
      id: "lc002",
      slug: "ai-security-essentials",
      title: "AI Security Essentials",
      description:
          "Understanding security challenges and best practices in AI systems and machine learning models. Learn about adversarial attacks, data privacy, and secure AI deployment.",
      imageUrl: "https://picsum.photos/400/300?random=2",
      thumbnailUrl: "https://picsum.photos/200/200?random=2",
      startTime: DateTime.now().add(const Duration(days: 1, hours: 6)),
      endTime: DateTime.now().add(
        const Duration(days: 1, hours: 7, minutes: 45),
      ),
      academy: "Leader Academy",
      teachers: ["Dr. Alex Rodriguez", "Ms. Emily Watson"],
      instructor: "Dr. Alex Rodriguez",
      category: "Technology",
      subject: "Cybersecurity",
      duration: 105,
      isLive: true,
      isRecorded: true,
      isFree: false,
      maxParticipants: 150,
      currentParticipants: 89,
      price: 29.99,
      difficulty: "Intermediate",
      tags: ["AI Security", "Cybersecurity", "Machine Learning", "Privacy"],
      meetingLink: "https://zoom.us/j/123456789",
      status: "upcoming",
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
      rating: 4.8,
      totalRatings: 156,
      prerequisites: [
        "Basic AI knowledge",
        "Understanding of security concepts",
      ],
      language: "English",
      isRecordingAvailable: true,
      recordingUrl: "",
      metadata: {
        "level": "intermediate",
        "certification": true,
        "hands_on": true,
      },
    ),
    LiveClass(
      id: "lc003",
      slug: "artificial-intelligence-machine-learning",
      title: "Artificial Intelligence and Machine Learning",
      description:
          "Comprehensive introduction to AI and ML concepts, algorithms, and real-world applications. Cover supervised learning, unsupervised learning, and deep learning fundamentals.",
      imageUrl: "https://picsum.photos/400/300?random=3",
      thumbnailUrl: "https://picsum.photos/200/200?random=3",
      startTime: DateTime(2025, 6, 25, 18, 0),
      endTime: DateTime(2025, 6, 25, 20, 0),
      academy: "Leader Academy",
      teachers: ["Prof. David Kim", "Dr. Lisa Zhang", "Mr. Robert Brown"],
      instructor: "Prof. David Kim",
      category: "Technology",
      subject: "Machine Learning",
      duration: 120,
      isLive: true,
      isRecorded: true,
      isFree: false,
      maxParticipants: 200,
      currentParticipants: 156,
      price: 49.99,
      difficulty: "Advanced",
      tags: ["AI", "Machine Learning", "Deep Learning", "Neural Networks"],
      meetingLink: "https://teams.microsoft.com/l/meetup-join/xyz",
      status: "upcoming",
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      rating: 4.9,
      totalRatings: 342,
      prerequisites: [
        "Python programming",
        "Statistics basics",
        "Linear algebra",
      ],
      language: "English",
      isRecordingAvailable: true,
      recordingUrl: "",
      metadata: {
        "level": "advanced",
        "certification": true,
        "project_based": true,
        "duration_weeks": 4,
      },
    ),
    LiveClass(
      id: "lc004",
      slug: "python-for-data-science",
      title: "Python for Data Science",
      description:
          "Master Python programming for data analysis, visualization, and machine learning applications. Learn pandas, numpy, matplotlib, and scikit-learn.",
      imageUrl: "https://picsum.photos/400/300?random=4",
      thumbnailUrl: "https://picsum.photos/200/200?random=4",
      startTime: DateTime.now().add(const Duration(days: 2, hours: 4)),
      endTime: DateTime.now().add(const Duration(days: 2, hours: 6)),
      academy: "Tech Institute",
      teachers: ["Ms. Anna Thompson", "Mr. James Wilson"],
      instructor: "Ms. Anna Thompson",
      category: "Programming",
      subject: "Data Science",
      duration: 120,
      isLive: false,
      isRecorded: true,
      isFree: false,
      maxParticipants: 80,
      currentParticipants: 45,
      price: 39.99,
      difficulty: "Intermediate",
      tags: ["Python", "Data Science", "Pandas", "NumPy", "Matplotlib"],
      meetingLink: "https://meet.google.com/python-data-science",
      status: "upcoming",
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
      rating: 4.7,
      totalRatings: 189,
      prerequisites: ["Basic Python knowledge", "High school mathematics"],
      language: "English",
      isRecordingAvailable: true,
      recordingUrl: "",
      metadata: {
        "level": "intermediate",
        "certification": false,
        "practical_exercises": true,
      },
    ),
    LiveClass(
      id: "lc005",
      slug: "web-development-fundamentals",
      title: "Web Development Fundamentals",
      description:
          "Learn HTML, CSS, and JavaScript basics to build modern web applications from scratch. Build responsive websites and interactive user interfaces.",
      imageUrl: "https://picsum.photos/400/300?random=5",
      thumbnailUrl: "https://picsum.photos/200/200?random=5",
      startTime: DateTime.now().subtract(const Duration(hours: 1)),
      endTime: DateTime.now().add(const Duration(hours: 1)),
      academy: "Code Academy",
      teachers: ["Mr. Chris Martinez", "Ms. Jessica Lee"],
      instructor: "Mr. Chris Martinez",
      category: "Programming",
      subject: "Web Development",
      duration: 120,
      isLive: true,
      isRecorded: true,
      isFree: true,
      maxParticipants: 120,
      currentParticipants: 98,
      price: 0.0,
      difficulty: "Beginner",
      tags: ["HTML", "CSS", "JavaScript", "Web Development", "Frontend"],
      meetingLink: "https://zoom.us/j/webdev123",
      status: "live",
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      rating: 4.5,
      totalRatings: 267,
      prerequisites: ["Basic computer skills"],
      language: "English",
      isRecordingAvailable: true,
      recordingUrl: "https://example.com/recordings/lc005",
      metadata: {
        "level": "beginner",
        "certification": false,
        "live_coding": true,
      },
    ),
    LiveClass(
      id: "lc006",
      slug: "react-native-mobile-development",
      title: "React Native Mobile Development",
      description:
          "Build cross-platform mobile applications using React Native. Learn navigation, state management, and native device features integration.",
      imageUrl: "https://picsum.photos/400/300?random=6",
      thumbnailUrl: "https://picsum.photos/200/200?random=6",
      startTime: DateTime.now().add(const Duration(days: 3, hours: 5)),
      endTime: DateTime.now().add(const Duration(days: 3, hours: 7)),
      academy: "Mobile Dev Institute",
      teachers: ["Mr. Kevin Park", "Ms. Rachel Green"],
      instructor: "Mr. Kevin Park",
      category: "Mobile Development",
      subject: "React Native",
      duration: 120,
      isLive: true,
      isRecorded: true,
      isFree: false,
      maxParticipants: 60,
      currentParticipants: 42,
      price: 59.99,
      difficulty: "Intermediate",
      tags: [
        "React Native",
        "Mobile Development",
        "JavaScript",
        "Cross-platform",
      ],
      meetingLink: "https://meet.google.com/react-native-dev",
      status: "upcoming",
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 8)),
      rating: 4.4,
      totalRatings: 98,
      prerequisites: [
        "JavaScript knowledge",
        "React basics",
        "Mobile development interest",
      ],
      language: "English",
      isRecordingAvailable: true,
      recordingUrl: "",
      metadata: {
        "level": "intermediate",
        "certification": true,
        "app_deployment": true,
      },
    ),
    LiveClass(
      id: "lc007",
      slug: "flutter-app-development",
      title: "Flutter App Development Masterclass",
      description:
          "Create beautiful, natively compiled applications for mobile, web, and desktop from a single codebase using Flutter and Dart.",
      imageUrl: "https://picsum.photos/400/300?random=7",
      thumbnailUrl: "https://picsum.photos/200/200?random=7",
      startTime: DateTime.now().add(const Duration(days: 4, hours: 7)),
      endTime: DateTime.now().add(
        const Duration(days: 4, hours: 9, minutes: 30),
      ),
      academy: "Flutter Academy",
      teachers: ["Dr. Priya Sharma", "Mr. Tom Anderson"],
      instructor: "Dr. Priya Sharma",
      category: "Mobile Development",
      subject: "Flutter",
      duration: 150,
      isLive: true,
      isRecorded: true,
      isFree: false,
      maxParticipants: 100,
      currentParticipants: 78,
      price: 69.99,
      difficulty: "Advanced",
      tags: [
        "Flutter",
        "Dart",
        "Mobile Development",
        "Cross-platform",
        "UI/UX",
      ],
      meetingLink: "https://zoom.us/j/flutter-masterclass",
      status: "upcoming",
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 4)),
      rating: 4.8,
      totalRatings: 145,
      prerequisites: [
        "Programming experience",
        "Object-oriented concepts",
        "Mobile development basics",
      ],
      language: "English",
      isRecordingAvailable: true,
      recordingUrl: "",
      metadata: {
        "level": "advanced",
        "certification": true,
        "portfolio_project": true,
        "mentorship": true,
      },
    ),
    LiveClass(
      id: "lc008",
      slug: "blockchain-cryptocurrency-fundamentals",
      title: "Blockchain & Cryptocurrency Fundamentals",
      description:
          "Understand blockchain technology, cryptocurrencies, smart contracts, and decentralized applications (DApps). Learn about Bitcoin, Ethereum, and DeFi.",
      imageUrl: "https://picsum.photos/400/300?random=8",
      thumbnailUrl: "https://picsum.photos/200/200?random=8",
      startTime: DateTime.now().add(const Duration(hours: 8)),
      endTime: DateTime.now().add(const Duration(hours: 10)),
      academy: "Crypto Institute",
      teachers: ["Mr. Alex Bitcoin", "Ms. Sarah Ethereum"],
      instructor: "Mr. Alex Bitcoin",
      category: "Technology",
      subject: "Blockchain",
      duration: 120,
      isLive: false,
      isRecorded: true,
      isFree: true,
      maxParticipants: 200,
      currentParticipants: 167,
      price: 0.0,
      difficulty: "Beginner",
      tags: ["Blockchain", "Cryptocurrency", "Bitcoin", "Ethereum", "DeFi"],
      meetingLink: "https://teams.microsoft.com/blockchain-crypto",
      status: "upcoming",
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
      rating: 4.3,
      totalRatings: 289,
      prerequisites: ["Basic technology understanding"],
      language: "English",
      isRecordingAvailable: true,
      recordingUrl: "",
      metadata: {
        "level": "beginner",
        "certification": false,
        "investment_advice": false,
        "technical_focus": true,
      },
    ),
  ];

  // Helper methods
  static List<LiveClass> getUpcomingClasses() {
    return liveClasses.where((lc) => lc.status == "upcoming").toList();
  }

  static List<LiveClass> getLiveClasses() {
    return liveClasses.where((lc) => lc.status == "live").toList();
  }

  static List<LiveClass> getCompletedClasses() {
    return liveClasses.where((lc) => lc.status == "completed").toList();
  }

  static List<LiveClass> getClassesByCategory(String category) {
    return liveClasses
        .where((lc) => lc.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  static List<LiveClass> getClassesBySubject(String subject) {
    return liveClasses
        .where((lc) => lc.subject.toLowerCase() == subject.toLowerCase())
        .toList();
  }

  static List<LiveClass> getFreeClasses() {
    return liveClasses.where((lc) => lc.isFree).toList();
  }

  static List<LiveClass> getPaidClasses() {
    return liveClasses.where((lc) => !lc.isFree).toList();
  }

  static List<LiveClass> getClassesByDifficulty(String difficulty) {
    return liveClasses
        .where((lc) => lc.difficulty.toLowerCase() == difficulty.toLowerCase())
        .toList();
  }

  static List<LiveClass> getClassesByInstructor(String instructor) {
    return liveClasses
        .where(
          (lc) =>
              lc.instructor.toLowerCase().contains(instructor.toLowerCase()),
        )
        .toList();
  }

  static List<LiveClass> getClassesByAcademy(String academy) {
    return liveClasses
        .where((lc) => lc.academy.toLowerCase() == academy.toLowerCase())
        .toList();
  }

  static List<LiveClass> getRecordedClasses() {
    return liveClasses
        .where((lc) => lc.isRecorded && lc.isRecordingAvailable)
        .toList();
  }

  static List<LiveClass> getClassesStartingSoon() {
    return liveClasses.where((lc) => lc.isStartingSoon).toList();
  }

  static List<LiveClass> getAvailableClasses() {
    return liveClasses.where((lc) => lc.canJoin).toList();
  }

  static List<LiveClass> getClassesByLanguage(String language) {
    return liveClasses
        .where((lc) => lc.language.toLowerCase() == language.toLowerCase())
        .toList();
  }

  static List<LiveClass> getHighRatedClasses({double minRating = 4.5}) {
    return liveClasses.where((lc) => lc.rating >= minRating).toList();
  }

  static List<LiveClass> getPopularClasses({int minRatings = 200}) {
    return liveClasses.where((lc) => lc.totalRatings >= minRatings).toList();
  }

  static List<LiveClass> searchClasses(String query) {
    final lowercaseQuery = query.toLowerCase();
    return liveClasses
        .where(
          (lc) =>
              lc.title.toLowerCase().contains(lowercaseQuery) ||
              lc.description.toLowerCase().contains(lowercaseQuery) ||
              lc.instructor.toLowerCase().contains(lowercaseQuery) ||
              lc.academy.toLowerCase().contains(lowercaseQuery) ||
              lc.subject.toLowerCase().contains(lowercaseQuery) ||
              lc.category.toLowerCase().contains(lowercaseQuery) ||
              lc.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery)),
        )
        .toList();
  }

  // Get unique values for filters
  static List<String> getUniqueCategories() {
    return liveClasses.map((lc) => lc.category).toSet().toList()..sort();
  }

  static List<String> getUniqueSubjects() {
    return liveClasses.map((lc) => lc.subject).toSet().toList()..sort();
  }

  static List<String> getUniqueDifficulties() {
    return liveClasses.map((lc) => lc.difficulty).toSet().toList()..sort();
  }

  static List<String> getUniqueAcademies() {
    return liveClasses.map((lc) => lc.academy).toSet().toList()..sort();
  }

  static List<String> getUniqueInstructors() {
    return liveClasses.map((lc) => lc.instructor).toSet().toList()..sort();
  }

  static List<String> getUniqueLanguages() {
    return liveClasses.map((lc) => lc.language).toSet().toList()..sort();
  }

  // Statistics
  static int getTotalClasses() => liveClasses.length;

  static int getTotalUpcomingClasses() => getUpcomingClasses().length;

  static int getTotalLiveClasses() => getLiveClasses().length;

  static double getAverageRating() {
    if (liveClasses.isEmpty) return 0.0;
    return liveClasses.map((lc) => lc.rating).reduce((a, b) => a + b) /
        liveClasses.length;
  }

  static int getTotalParticipants() {
    return liveClasses
        .map((lc) => lc.currentParticipants)
        .reduce((a, b) => a + b);
  }
}
