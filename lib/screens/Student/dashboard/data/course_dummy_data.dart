// data/course_dummy_data.dart
import './models/course_model.dart';

class CourseDummyData {
  static final List<Course> courses = [
    Course(
      id: "c001",
      slug: "complete-python-course-zero-to-hero",
      title: "The Complete Python Course: From Zero to Hero in Python",
      description: "Master Python programming from basics to advanced concepts. Build real-world projects and become a Python developer.",
      imageUrl: "https://picsum.photos/200/200?random=10",
      academy: "Leader Academy",
      instructors: ["Dr. John Smith", "Ms. Sarah Wilson"],
      category: "Programming",
      subject: "Python",
      rating: 4.8,
      totalRatings: 2547,
      price: 2999.0,
      originalPrice: 4999.0,
      difficulty: "Beginner",
      duration: 40,
      totalLessons: 120,
      tags: ["Python", "Programming", "Backend", "Web Development", "Data Science"],
      isCertified: true,
      isEnrolled: true,
      progress: 0.65,
      createdAt: DateTime(2024, 1, 15),
      updatedAt: DateTime(2024, 12, 1),
      language: "English",
      requirements: [
        "No programming experience needed",
        "Computer with internet connection",
        "Willingness to learn"
      ],
      whatYouWillLearn: [
        "Python fundamentals and syntax",
        "Object-oriented programming",
        "Web development with Django/Flask",
        "Data analysis with Pandas",
        "Build real-world projects"
      ],
    ),
    Course(
      id: "c002",
      slug: "generative-ai-prompt-engineering-basics",
      title: "Generative AI: Prompt Engineering Basics",
      description: "Learn the art and science of prompt engineering for AI models like ChatGPT, Claude, and other LLMs.",
      imageUrl: "https://picsum.photos/200/200?random=11",
      academy: "Leader Academy",
      instructors: ["Prof. Emily Chen", "Dr. Michael Rodriguez"],
      category: "Technology",
      subject: "Artificial Intelligence",
      rating: 4.9,
      totalRatings: 1823,
      price: 0.0,
      originalPrice: 0.0,
      difficulty: "Beginner",
      duration: 15,
      totalLessons: 45,
      tags: ["AI", "Prompt Engineering", "ChatGPT", "LLM", "Machine Learning"],
      isCertified: true,
      isEnrolled: true,
      progress: 0.30,
      createdAt: DateTime(2024, 3, 10),
      updatedAt: DateTime(2024, 11, 20),
      language: "English",
      requirements: [
        "Basic computer literacy",
        "Interest in AI technology",
        "No prior AI experience needed"
      ],
      whatYouWillLearn: [
        "Fundamentals of prompt engineering",
        "Best practices for AI interactions",
        "Advanced prompting techniques",
        "Real-world applications",
        "Ethical AI usage"
      ],
    ),
    Course(
      id: "c003",
      slug: "full-stack-web-development-bootcamp",
      title: "Full Stack Web Development Bootcamp",
      description: "Complete web development course covering HTML, CSS, JavaScript, React, Node.js, and databases.",
      imageUrl: "https://picsum.photos/200/200?random=12",
      academy: "Tech Institute",
      instructors: ["Mr. David Kim", "Ms. Lisa Zhang"],
      category: "Programming",
      subject: "Web Development",
      rating: 4.7,
      totalRatings: 3421,
      price: 5999.0,
      originalPrice: 8999.0,
      difficulty: "Intermediate",
      duration: 80,
      totalLessons: 200,
      tags: ["HTML", "CSS", "JavaScript", "React", "Node.js", "MongoDB"],
      isCertified: true,
      isEnrolled: false,
      progress: 0.0,
      createdAt: DateTime(2023, 8, 5),
      updatedAt: DateTime(2024, 12, 5),
      language: "English",
      requirements: [
        "Basic HTML/CSS knowledge",
        "Understanding of programming concepts",
        "Computer with 8GB+ RAM"
      ],
      whatYouWillLearn: [
        "Frontend development with React",
        "Backend development with Node.js",
        "Database design and management",
        "API development and integration",
        "Deployment and DevOps basics"
      ],
    ),
    Course(
      id: "c004",
      slug: "data-science-machine-learning-python",
      title: "Data Science & Machine Learning with Python",
      description: "Comprehensive course on data science, statistics, and machine learning using Python libraries.",
      imageUrl: "https://picsum.photos/200/200?random=13",
      academy: "Data Academy",
      instructors: ["Dr. Anna Thompson", "Prof. Robert Brown"],
      category: "Data Science",
      subject: "Machine Learning",
      rating: 4.6,
      totalRatings: 1967,
      price: 4499.0,
      originalPrice: 6999.0,
      difficulty: "Advanced",
      duration: 60,
      totalLessons: 150,
      tags: ["Python", "Data Science", "Machine Learning", "Pandas", "Scikit-learn"],
      isCertified: true,
      isEnrolled: true,
      progress: 0.85,
      createdAt: DateTime(2023, 11, 20),
      updatedAt: DateTime(2024, 10, 15),
      language: "English",
      requirements: [
        "Python programming knowledge",
        "Basic statistics understanding",
        "Mathematics background helpful"
      ],
      whatYouWillLearn: [
        "Data analysis with Pandas",
        "Machine learning algorithms",
        "Statistical analysis",
        "Data visualization",
        "Model deployment"
      ],
    ),
    Course(
      id: "c005",
      slug: "mobile-app-development-flutter",
      title: "Mobile App Development with Flutter",
      description: "Build beautiful, native mobile apps for iOS and Android using Flutter and Dart programming language.",
      imageUrl: "https://picsum.photos/200/200?random=14",
      academy: "Mobile Dev Academy",
      instructors: ["Mr. James Wilson", "Ms. Jessica Lee"],
      category: "Mobile Development",
      subject: "Flutter",
      rating: 4.5,
      totalRatings: 1234,
      price: 3999.0,
      originalPrice: 5999.0,
      difficulty: "Intermediate",
      duration: 50,
      totalLessons: 130,
      tags: ["Flutter", "Dart", "Mobile Development", "iOS", "Android"],
      isCertified: true,
      isEnrolled: false,
      progress: 0.0,
      createdAt: DateTime(2024, 2, 1),
      updatedAt: DateTime(2024, 11, 30),
      language: "English",
      requirements: [
        "Basic programming knowledge",
        "Understanding of OOP concepts",
        "Android Studio or VS Code installed"
      ],
      whatYouWillLearn: [
        "Flutter framework fundamentals",
        "Dart programming language",
        "UI/UX design principles",
        "State management",
        "App store deployment"
      ],
    ),
  ];

  // Helper methods
  static List<Course> getEnrolledCourses() {
    return courses.where((course) => course.isEnrolled).toList();
  }

  static List<Course> getFreeCourses() {
    return courses.where((course) => course.isFree).toList();
  }

  static List<Course> getCoursesByCategory(String category) {
    return courses.where((course) => course.category == category).toList();
  }

  static List<Course> getCoursesByDifficulty(String difficulty) {
    return courses.where((course) => course.difficulty == difficulty).toList();
  }

  static List<Course> getPopularCourses() {
    return courses.where((course) => course.rating >= 4.5).toList();
  }
}
