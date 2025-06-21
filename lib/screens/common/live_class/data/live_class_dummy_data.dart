// data/live_class_dummy_data.dart
import 'package:brainboosters_app/screens/common/live_class/models/live_class_model.dart';

class LiveClassDummyData {
  static final List<LiveClass> liveClasses = [
    LiveClass(
      id: "lc001",
      slug: "generative-ai-prompt-engineering-basics",
      title: "Generative AI: Prompt Engineering Basics",
      description: "Learn the fundamentals of prompt engineering for AI models like ChatGPT, Claude, and other LLMs. Master the art of crafting effective prompts to get better results from AI systems.",
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
      // Analytics
      viewCount: 1250,
      chatMessageCount: 89,
      reactionCount: 156,
      averageEngagementScore: 0.78,
      engagementScores: {
        "u001": 0.85,
        "u002": 0.72,
        "u003": 0.91,
        "u004": 0.68,
      },
      questionsAsked: 15,
      resourceDownloads: 45,
      // Comments
      comments: [
        LiveClassComment(
          id: "c001",
          userId: "u001",
          userName: "Alex Johnson",
          userAvatarUrl: "https://i.pravatar.cc/150?img=1",
          text: "Great introduction to prompt engineering! Very clear explanations.",
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          likes: 12,
          sentiment: Sentiment.positive,
        ),
        LiveClassComment(
          id: "c002",
          userId: "u002",
          userName: "Priya Sharma",
          userAvatarUrl: "https://i.pravatar.cc/150?img=2",
          text: "Could you share more examples of effective prompts?",
          timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
          likes: 8,
          sentiment: Sentiment.neutral,
          replies: [
            LiveClassComment(
              id: "c002r1",
              userId: "instructor1",
              userName: "Dr. Sarah Johnson",
              userAvatarUrl: "https://i.pravatar.cc/150?img=10",
              text: "Absolutely! I'll share a comprehensive list in the resources section.",
              timestamp: DateTime.now().subtract(const Duration(minutes: 40)),
              likes: 5,
              sentiment: Sentiment.positive,
            ),
          ],
        ),
        LiveClassComment(
          id: "c003",
          userId: "u003",
          userName: "Mike Chen",
          userAvatarUrl: "https://i.pravatar.cc/150?img=3",
          text: "The ChatGPT examples were really helpful!",
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
          likes: 15,
          sentiment: Sentiment.positive,
        ),
      ],
    ),
    
    LiveClass(
      id: "lc002",
      slug: "ai-security-essentials",
      title: "AI Security Essentials",
      description: "Understanding security challenges and best practices in AI systems and machine learning models. Learn about adversarial attacks, data privacy, and secure AI deployment.",
      imageUrl: "https://picsum.photos/400/300?random=2",
      thumbnailUrl: "https://picsum.photos/200/200?random=2",
      startTime: DateTime.now().add(const Duration(days: 1, hours: 6)),
      endTime: DateTime.now().add(const Duration(days: 1, hours: 7, minutes: 45)),
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
      prerequisites: ["Basic AI knowledge", "Understanding of security concepts"],
      language: "English",
      isRecordingAvailable: true,
      recordingUrl: "",
      metadata: {
        "level": "intermediate",
        "certification": true,
        "hands_on": true,
      },
      // Analytics
      viewCount: 890,
      chatMessageCount: 124,
      reactionCount: 203,
      averageEngagementScore: 0.82,
      engagementScores: {
        "u005": 0.88,
        "u006": 0.79,
        "u007": 0.85,
        "u008": 0.76,
      },
      questionsAsked: 22,
      resourceDownloads: 67,
      // Comments
      comments: [
        LiveClassComment(
          id: "c004",
          userId: "u005",
          userName: "Sarah Kim",
          userAvatarUrl: "https://i.pravatar.cc/150?img=4",
          text: "The adversarial attack examples were eye-opening!",
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          likes: 18,
          sentiment: Sentiment.positive,
        ),
        LiveClassComment(
          id: "c005",
          userId: "u006",
          userName: "David Wilson",
          userAvatarUrl: "https://i.pravatar.cc/150?img=5",
          text: "How do we implement these security measures in production?",
          timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
          likes: 10,
          sentiment: Sentiment.confused,
        ),
      ],
    ),

    LiveClass(
      id: "lc003",
      slug: "artificial-intelligence-machine-learning",
      title: "Artificial Intelligence and Machine Learning",
      description: "Comprehensive introduction to AI and ML concepts, algorithms, and real-world applications. Cover supervised learning, unsupervised learning, and deep learning fundamentals.",
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
      prerequisites: ["Python programming", "Statistics basics", "Linear algebra"],
      language: "English",
      isRecordingAvailable: true,
      recordingUrl: "",
      metadata: {
        "level": "advanced",
        "certification": true,
        "project_based": true,
        "duration_weeks": 4,
      },
      // Analytics
      viewCount: 1580,
      chatMessageCount: 267,
      reactionCount: 445,
      averageEngagementScore: 0.91,
      engagementScores: {
        "u009": 0.94,
        "u010": 0.89,
        "u011": 0.92,
        "u012": 0.88,
      },
      questionsAsked: 35,
      resourceDownloads: 128,
      // Comments
      comments: [
        LiveClassComment(
          id: "c006",
          userId: "u009",
          userName: "Emma Thompson",
          userAvatarUrl: "https://i.pravatar.cc/150?img=6",
          text: "The neural network visualization was fantastic!",
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          likes: 25,
          sentiment: Sentiment.positive,
        ),
        LiveClassComment(
          id: "c007",
          userId: "u010",
          userName: "James Rodriguez",
          userAvatarUrl: "https://i.pravatar.cc/150?img=7",
          text: "Can we get more hands-on coding examples?",
          timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 15)),
          likes: 14,
          sentiment: Sentiment.neutral,
        ),
        LiveClassComment(
          id: "c008",
          userId: "u011",
          userName: "Lisa Wang",
          userAvatarUrl: "https://i.pravatar.cc/150?img=8",
          text: "Best ML course I've attended so far!",
          timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
          likes: 32,
          sentiment: Sentiment.positive,
        ),
      ],
    ),

    LiveClass(
      id: "lc004",
      slug: "python-for-data-science",
      title: "Python for Data Science",
      description: "Master Python programming for data analysis, visualization, and machine learning applications. Learn pandas, numpy, matplotlib, and scikit-learn.",
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
      // Analytics
      viewCount: 720,
      chatMessageCount: 98,
      reactionCount: 167,
      averageEngagementScore: 0.75,
      engagementScores: {
        "u013": 0.78,
        "u014": 0.73,
        "u015": 0.77,
        "u016": 0.72,
      },
      questionsAsked: 18,
      resourceDownloads: 52,
      // Comments
      comments: [
        LiveClassComment(
          id: "c009",
          userId: "u013",
          userName: "Carlos Martinez",
          userAvatarUrl: "https://i.pravatar.cc/150?img=9",
          text: "The pandas examples were very practical!",
          timestamp: DateTime.now().subtract(const Duration(hours: 4)),
          likes: 16,
          sentiment: Sentiment.positive,
        ),
        LiveClassComment(
          id: "c010",
          userId: "u014",
          userName: "Nina Patel",
          userAvatarUrl: "https://i.pravatar.cc/150?img=11",
          text: "Could you explain data cleaning in more detail?",
          timestamp: DateTime.now().subtract(const Duration(hours: 3, minutes: 30)),
          likes: 9,
          sentiment: Sentiment.confused,
        ),
      ],
    ),

    LiveClass(
      id: "lc005",
      slug: "web-development-fundamentals",
      title: "Web Development Fundamentals",
      description: "Learn HTML, CSS, and JavaScript basics to build modern web applications from scratch. Build responsive websites and interactive user interfaces.",
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
      // Analytics
      viewCount: 1120,
      chatMessageCount: 156,
      reactionCount: 234,
      averageEngagementScore: 0.83,
      engagementScores: {
        "u017": 0.86,
        "u018": 0.81,
        "u019": 0.84,
        "u020": 0.80,
      },
      questionsAsked: 28,
      resourceDownloads: 78,
      // Comments
      comments: [
        LiveClassComment(
          id: "c011",
          userId: "u017",
          userName: "Tom Anderson",
          userAvatarUrl: "https://i.pravatar.cc/150?img=12",
          text: "Love the live coding approach! Very engaging.",
          timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
          likes: 22,
          sentiment: Sentiment.positive,
        ),
        LiveClassComment(
          id: "c012",
          userId: "u018",
          userName: "Rachel Green",
          userAvatarUrl: "https://i.pravatar.cc/150?img=13",
          text: "Can you slow down a bit? Hard to follow the typing.",
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
          likes: 11,
          sentiment: Sentiment.confused,
          replies: [
            LiveClassComment(
              id: "c012r1",
              userId: "instructor2",
              userName: "Mr. Chris Martinez",
              userAvatarUrl: "https://i.pravatar.cc/150?img=20",
              text: "Sure! I'll slow down and explain each step more clearly.",
              timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
              likes: 8,
              sentiment: Sentiment.positive,
            ),
          ],
        ),
        LiveClassComment(
          id: "c013",
          userId: "u019",
          userName: "Kevin Park",
          userAvatarUrl: "https://i.pravatar.cc/150?img=14",
          text: "Great for beginners! Clear explanations.",
          timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
          likes: 19,
          sentiment: Sentiment.positive,
        ),
      ],
    ),

    // Additional 3 live classes to make it 8 total
    LiveClass(
      id: "lc006",
      slug: "react-native-mobile-development",
      title: "React Native Mobile Development",
      description: "Build cross-platform mobile applications using React Native. Learn navigation, state management, and native device features integration.",
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
      tags: ["React Native", "Mobile Development", "JavaScript", "Cross-platform"],
      meetingLink: "https://meet.google.com/react-native-dev",
      status: "upcoming",
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 8)),
      rating: 4.4,
      totalRatings: 98,
      prerequisites: ["JavaScript knowledge", "React basics", "Mobile development interest"],
      language: "English",
      isRecordingAvailable: true,
      recordingUrl: "",
      metadata: {
        "level": "intermediate",
        "certification": true,
        "app_deployment": true,
      },
      // Analytics
      viewCount: 520,
      chatMessageCount: 76,
      reactionCount: 134,
      averageEngagementScore: 0.71,
      engagementScores: {
        "u021": 0.74,
        "u022": 0.69,
        "u023": 0.73,
        "u024": 0.68,
      },
      questionsAsked: 12,
      resourceDownloads: 38,
      // Comments
      comments: [
        LiveClassComment(
          id: "c014",
          userId: "u021",
          userName: "Sofia Rodriguez",
          userAvatarUrl: "https://i.pravatar.cc/150?img=15",
          text: "React Native is so powerful for cross-platform development!",
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          likes: 14,
          sentiment: Sentiment.positive,
        ),
      ],
    ),

    LiveClass(
      id: "lc007",
      slug: "flutter-app-development",
      title: "Flutter App Development Masterclass",
      description: "Create beautiful, natively compiled applications for mobile, web, and desktop from a single codebase using Flutter and Dart.",
      imageUrl: "https://picsum.photos/400/300?random=7",
      thumbnailUrl: "https://picsum.photos/200/200?random=7",
      startTime: DateTime.now().add(const Duration(days: 4, hours: 7)),
      endTime: DateTime.now().add(const Duration(days: 4, hours: 9, minutes: 30)),
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
      tags: ["Flutter", "Dart", "Mobile Development", "Cross-platform", "UI/UX"],
      meetingLink: "https://zoom.us/j/flutter-masterclass",
      status: "upcoming",
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 4)),
      rating: 4.8,
      totalRatings: 145,
      prerequisites: ["Programming experience", "Object-oriented concepts", "Mobile development basics"],
      language: "English",
      isRecordingAvailable: true,
      recordingUrl: "",
      metadata: {
        "level": "advanced",
        "certification": true,
        "portfolio_project": true,
        "mentorship": true,
      },
      // Analytics
      viewCount: 680,
      chatMessageCount: 112,
      reactionCount: 189,
      averageEngagementScore: 0.86,
      engagementScores: {
        "u025": 0.89,
        "u026": 0.84,
        "u027": 0.87,
        "u028": 0.83,
      },
      questionsAsked: 20,
      resourceDownloads: 65,
      // Comments
      comments: [
        LiveClassComment(
          id: "c015",
          userId: "u025",
          userName: "Ahmed Hassan",
          userAvatarUrl: "https://i.pravatar.cc/150?img=16",
          text: "Flutter's widget system is amazing! Great explanation.",
          timestamp: DateTime.now().subtract(const Duration(hours: 6)),
          likes: 21,
          sentiment: Sentiment.positive,
        ),
        LiveClassComment(
          id: "c016",
          userId: "u026",
          userName: "Maria Santos",
          userAvatarUrl: "https://i.pravatar.cc/150?img=17",
          text: "The state management section was particularly helpful.",
          timestamp: DateTime.now().subtract(const Duration(hours: 5, minutes: 30)),
          likes: 17,
          sentiment: Sentiment.positive,
        ),
      ],
    ),

    LiveClass(
      id: "lc008",
      slug: "blockchain-cryptocurrency-fundamentals",
      title: "Blockchain & Cryptocurrency Fundamentals",
      description: "Understand blockchain technology, cryptocurrencies, smart contracts, and decentralized applications (DApps). Learn about Bitcoin, Ethereum, and DeFi.",
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
      // Analytics
      viewCount: 1340,
      chatMessageCount: 203,
      reactionCount: 298,
      averageEngagementScore: 0.69,
      engagementScores: {
        "u029": 0.72,
        "u030": 0.67,
        "u031": 0.71,
        "u032": 0.66,
      },
      questionsAsked: 31,
      resourceDownloads: 89,
      // Comments
      comments: [
        LiveClassComment(
          id: "c017",
          userId: "u029",
          userName: "John Crypto",
          userAvatarUrl: "https://i.pravatar.cc/150?img=18",
          text: "Finally understand how blockchain actually works!",
          timestamp: DateTime.now().subtract(const Duration(hours: 7)),
          likes: 26,
          sentiment: Sentiment.positive,
        ),
        LiveClassComment(
          id: "c018",
          userId: "u030",
          userName: "Lisa Blockchain",
          userAvatarUrl: "https://i.pravatar.cc/150?img=19",
          text: "Is this suitable for complete beginners?",
          timestamp: DateTime.now().subtract(const Duration(hours: 6, minutes: 45)),
          likes: 8,
          sentiment: Sentiment.confused,
          replies: [
            LiveClassComment(
              id: "c018r1",
              userId: "instructor3",
              userName: "Mr. Alex Bitcoin",
              userAvatarUrl: "https://i.pravatar.cc/150?img=21",
              text: "Absolutely! We start from the very basics.",
              timestamp: DateTime.now().subtract(const Duration(hours: 6, minutes: 30)),
              likes: 12,
              sentiment: Sentiment.positive,
            ),
          ],
        ),
        LiveClassComment(
          id: "c019",
          userId: "u031",
          userName: "Robert DeFi",
          userAvatarUrl: "https://i.pravatar.cc/150?img=22",
          text: "The DeFi section was mind-blowing!",
          timestamp: DateTime.now().subtract(const Duration(hours: 6)),
          likes: 19,
          sentiment: Sentiment.positive,
        ),
      ],
    ),
  ];

  // All existing helper methods remain the same...
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
    return liveClasses.where((lc) => lc.category.toLowerCase() == category.toLowerCase()).toList();
  }

  static List<LiveClass> getClassesBySubject(String subject) {
    return liveClasses.where((lc) => lc.subject.toLowerCase() == subject.toLowerCase()).toList();
  }

  static List<LiveClass> getFreeClasses() {
    return liveClasses.where((lc) => lc.isFree).toList();
  }

  static List<LiveClass> getPaidClasses() {
    return liveClasses.where((lc) => !lc.isFree).toList();
  }

  static List<LiveClass> getClassesByDifficulty(String difficulty) {
    return liveClasses.where((lc) => lc.difficulty.toLowerCase() == difficulty.toLowerCase()).toList();
  }

  static List<LiveClass> getClassesByInstructor(String instructor) {
    return liveClasses.where((lc) => lc.instructor.toLowerCase().contains(instructor.toLowerCase())).toList();
  }

  static List<LiveClass> getClassesByAcademy(String academy) {
    return liveClasses.where((lc) => lc.academy.toLowerCase() == academy.toLowerCase()).toList();
  }

  static List<LiveClass> getRecordedClasses() {
    return liveClasses.where((lc) => lc.isRecorded && lc.isRecordingAvailable).toList();
  }

  static List<LiveClass> getClassesStartingSoon() {
    return liveClasses.where((lc) => lc.isStartingSoon).toList();
  }

  static List<LiveClass> getAvailableClasses() {
    return liveClasses.where((lc) => lc.canJoin).toList();
  }

  static List<LiveClass> getClassesByLanguage(String language) {
    return liveClasses.where((lc) => lc.language.toLowerCase() == language.toLowerCase()).toList();
  }

  static List<LiveClass> getHighRatedClasses({double minRating = 4.5}) {
    return liveClasses.where((lc) => lc.rating >= minRating).toList();
  }

  static List<LiveClass> getPopularClasses({int minRatings = 200}) {
    return liveClasses.where((lc) => lc.totalRatings >= minRatings).toList();
  }

  static List<LiveClass> searchClasses(String query) {
    final lowercaseQuery = query.toLowerCase();
    return liveClasses.where((lc) =>
        lc.title.toLowerCase().contains(lowercaseQuery) ||
        lc.description.toLowerCase().contains(lowercaseQuery) ||
        lc.instructor.toLowerCase().contains(lowercaseQuery) ||
        lc.academy.toLowerCase().contains(lowercaseQuery) ||
        lc.subject.toLowerCase().contains(lowercaseQuery) ||
        lc.category.toLowerCase().contains(lowercaseQuery) ||
        lc.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery))).toList();
  }

  // New analytics helper methods
  static List<LiveClass> getHighEngagementClasses({double minEngagement = 0.8}) {
    return liveClasses.where((lc) => lc.averageEngagementScore >= minEngagement).toList();
  }

  static List<LiveClass> getClassesWithComments() {
    return liveClasses.where((lc) => lc.comments.isNotEmpty).toList();
  }

  static double getAverageEngagementScore() {
    if (liveClasses.isEmpty) return 0.0;
    return liveClasses.map((lc) => lc.averageEngagementScore).reduce((a, b) => a + b) / liveClasses.length;
  }

  static int getTotalComments() {
    return liveClasses.map((lc) => lc.comments.length).reduce((a, b) => a + b);
  }

  static int getTotalViewCount() {
    return liveClasses.map((lc) => lc.viewCount).reduce((a, b) => a + b);
  }

  // Get unique values for filters (existing methods remain the same)
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

  // Statistics (existing methods remain the same)
  static int getTotalClasses() => liveClasses.length;

  static int getTotalUpcomingClasses() => getUpcomingClasses().length;

  static int getTotalLiveClasses() => getLiveClasses().length;

  static double getAverageRating() {
    if (liveClasses.isEmpty) return 0.0;
    return liveClasses.map((lc) => lc.rating).reduce((a, b) => a + b) / liveClasses.length;
  }

  static int getTotalParticipants() {
    return liveClasses.map((lc) => lc.currentParticipants).reduce((a, b) => a + b);
  }
}
