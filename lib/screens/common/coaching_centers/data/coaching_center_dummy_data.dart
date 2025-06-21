// data/coaching_center_dummy_data.dart
import '../models/coaching_center_model.dart';

class CoachingCenterDummyData {
  static final List<CoachingCenter> coachingCenters = [
    CoachingCenter(
      id: 'cc001',
      slug: 'the-leaders-academy-trichy',
      name: 'The Leaders Academy',
      rating: 4.8,
      reviews: 50865,
      description: 'One of the top coaching institutes in South India, specializing in competitive exam preparation and professional skill development. With over 15 years of excellence, we have trained thousands of successful candidates.',
      location: 'Trichy, Tamil Nadu',
      coursesOffered: 25,
      studentsEnrolled: 50865,
      imageUrl: 'https://picsum.photos/400/300?random=301',
      imageGallery: [
        'https://picsum.photos/600/400?random=301',
        'https://picsum.photos/600/400?random=302',
        'https://picsum.photos/600/400?random=303',
      ],
      specializations: ['JEE Preparation', 'NEET Coaching', 'Engineering Mathematics', 'Physics'],
      experienceYears: 15,
      isVerified: true,
      establishedDate: DateTime(2009),
      contactEmail: 'info@leadersacademy.com',
      contactPhone: '+91 9876543210',
      facilities: ['Online Classes', 'Offline Classes', 'Lab Facility', 'Placement Support'],
      fees: 15000,
      address: 'No. 123, Main Street, Trichy - 620001',
      createdAt: DateTime(2009, 3, 15),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      // Enhanced fields
      website: 'https://www.leadersacademy.com',
      socialMediaLinks: [
        'https://facebook.com/leadersacademy',
        'https://instagram.com/leadersacademy',
        'https://youtube.com/leadersacademy',
      ],
      licenseNumber: 'TN/EDU/2009/001',
      certifications: ['ISO 9001:2015', 'AICTE Approved', 'Tamil Nadu Education Board'],
      awards: ['Best Coaching Institute 2023', 'Excellence in Education Award'],
      foundersName: 'Dr. Rajesh Kumar',
      languages: ['Tamil', 'English'],
      teachingMethods: ['Interactive Learning', 'Problem Solving', 'Mock Tests', 'Doubt Clearing'],
      category: 'Engineering Entrance',
      examsPrepared: ['JEE Main', 'JEE Advanced', 'TNEA', 'BITSAT'],
      batchTimings: ['6:00 AM - 8:00 AM', '4:00 PM - 6:00 PM', '6:00 PM - 8:00 PM'],
      hasOnlineClasses: true,
      hasOfflineClasses: true,
      hasHybridClasses: true,
      successRate: 92.5,
      toppersList: ['Arjun Krishnan - JEE AIR 45', 'Priya Sharma - JEE AIR 78', 'Karthik Raja - JEE AIR 156'],
      facultyCount: 25,
      averageClassSize: 30.0,
      hasLibrary: true,
      hasLabFacility: true,
      hasHostelFacility: true,
      hasCafeteria: true,
      hasTransportFacility: true,
      admissionProcess: 'Entrance test followed by counseling session',
      feeStructure: {
        'JEE Foundation': 12000,
        'JEE Main': 15000,
        'JEE Advanced': 18000,
        'NEET': 14000,
      },
      scholarshipOptions: ['Merit Scholarship', 'Need-based Aid', 'Topper Rewards'],
      refundPolicy: '100% refund within 15 days of enrollment',
      // Analytics
      analytics: CoachingCenterAnalytics(
        totalEnquiries: 2500,
        admissionsThisMonth: 180,
        activeStudents: 1200,
        averageAttendance: 94.5,
        successfulPlacements: 850,
        studentSatisfactionScore: 4.7,
        monthlyEnrollments: {
          'Jan': 150,
          'Feb': 180,
          'Mar': 220,
          'Apr': 200,
          'May': 160,
          'Jun': 140,
        },
        subjectWisePerformance: {
          'Mathematics': 88.5,
          'Physics': 85.2,
          'Chemistry': 89.1,
        },
        websiteVisits: 15000,
        brochureDownloads: 2800,
      ),
      // Student Reviews
      studentReviews: [
        CoachingCenterReview(
          id: 'r001',
          studentName: 'Arjun Krishnan',
          studentAvatarUrl: 'https://i.pravatar.cc/150?img=1',
          rating: 5.0,
          comment: 'Excellent coaching with dedicated faculty. Got JEE AIR 45!',
          reviewDate: DateTime.now().subtract(const Duration(days: 30)),
          course: 'JEE Advanced',
          isVerified: true,
        ),
        CoachingCenterReview(
          id: 'r002',
          studentName: 'Priya Sharma',
          studentAvatarUrl: 'https://i.pravatar.cc/150?img=2',
          rating: 4.8,
          comment: 'Great study material and mock tests. Highly recommended!',
          reviewDate: DateTime.now().subtract(const Duration(days: 15)),
          course: 'JEE Main',
          isVerified: true,
        ),
      ],
      // Batches
      batches: [
        CoachingCenterBatch(
          id: 'b001',
          name: 'JEE 2026 Foundation',
          course: 'JEE Foundation',
          timing: '6:00 AM - 8:00 AM',
          maxCapacity: 40,
          currentStudents: 35,
          startDate: DateTime(2025, 4, 1),
          endDate: DateTime(2026, 3, 31),
          instructor: 'Dr. Rajesh Kumar',
          fees: 12000,
          mode: 'Hybrid',
        ),
        CoachingCenterBatch(
          id: 'b002',
          name: 'JEE 2025 Main',
          course: 'JEE Main',
          timing: '4:00 PM - 6:00 PM',
          maxCapacity: 35,
          currentStudents: 32,
          startDate: DateTime(2024, 6, 1),
          endDate: DateTime(2025, 5, 31),
          instructor: 'Prof. Meera Nair',
          fees: 15000,
          mode: 'Offline',
        ),
      ],
      // Faculty
      faculty: [
        CoachingCenterFaculty(
          id: 'f001',
          name: 'Dr. Rajesh Kumar',
          designation: 'Director & Senior Faculty',
          qualification: 'Ph.D in Mathematics, IIT Madras',
          experienceYears: 15,
          subjects: ['Mathematics', 'Physics'],
          imageUrl: 'https://i.pravatar.cc/150?img=10',
          bio: 'Former IIT professor with 15+ years of teaching experience.',
          rating: 4.9,
        ),
        CoachingCenterFaculty(
          id: 'f002',
          name: 'Prof. Meera Nair',
          designation: 'Senior Physics Faculty',
          qualification: 'M.Sc Physics, IISc Bangalore',
          experienceYears: 12,
          subjects: ['Physics'],
          imageUrl: 'https://i.pravatar.cc/150?img=11',
          bio: 'Expert in JEE Physics with innovative teaching methods.',
          rating: 4.8,
        ),
      ],
      metadata: {
        'featured': true,
        'premium_partner': true,
        'last_inspection': '2024-12-01',
      },
    ),

    CoachingCenter(
      id: 'cc002',
      slug: 'expert-academy-chennai',
      name: 'Expert Academy',
      rating: 4.6,
      reviews: 105653,
      description: 'Premier medical entrance coaching institute with state-of-the-art facilities and experienced faculty. We specialize in NEET preparation with a proven track record of success.',
      location: 'Chennai, Tamil Nadu',
      coursesOffered: 30,
      studentsEnrolled: 105653,
      imageUrl: 'https://picsum.photos/400/300?random=302',
      imageGallery: [
        'https://picsum.photos/600/400?random=304',
        'https://picsum.photos/600/400?random=305',
        'https://picsum.photos/600/400?random=306',
      ],
      specializations: ['NEET Preparation', 'Biology', 'Chemistry', 'Medical Foundation'],
      experienceYears: 12,
      isVerified: true,
      establishedDate: DateTime(2012),
      contactEmail: 'contact@expertacademy.com',
      contactPhone: '+91 9876543211',
      facilities: ['24/7 Lab Access', 'Industry Mentors', 'Live Projects', 'Job Guarantee'],
      fees: 18000,
      address: 'Tower A, Tech Park, Chennai - 600001',
      createdAt: DateTime(2012, 6, 20),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      // Enhanced fields
      website: 'https://www.expertacademy.com',
      socialMediaLinks: [
        'https://facebook.com/expertacademy',
        'https://instagram.com/expertacademy',
      ],
      licenseNumber: 'TN/EDU/2012/002',
      certifications: ['CBSE Affiliated', 'Medical Council Approved'],
      awards: ['Best NEET Coaching 2023', 'Student Choice Award'],
      foundersName: 'Dr. Sunitha Reddy',
      languages: ['Tamil', 'English', 'Telugu'],
      teachingMethods: ['Visual Learning', 'Practical Demonstrations', 'Regular Assessments'],
      category: 'Medical Entrance',
      examsPrepared: ['NEET', 'AIIMS', 'JIPMER', 'State Medical Exams'],
      batchTimings: ['7:00 AM - 9:00 AM', '2:00 PM - 4:00 PM', '5:00 PM - 7:00 PM'],
      hasOnlineClasses: true,
      hasOfflineClasses: true,
      hasHybridClasses: false,
      successRate: 89.2,
      toppersList: ['Kavya Menon - NEET AIR 23', 'Rohit Agarwal - NEET AIR 67'],
      facultyCount: 20,
      averageClassSize: 25.0,
      hasLibrary: true,
      hasLabFacility: true,
      hasHostelFacility: false,
      hasCafeteria: true,
      hasTransportFacility: true,
      admissionProcess: 'Online application with document verification',
      feeStructure: {
        'NEET Foundation': 15000,
        'NEET Dropper': 18000,
        'NEET Crash Course': 12000,
      },
      scholarshipOptions: ['Top 10% Fee Waiver', 'Girl Child Scholarship'],
      refundPolicy: '80% refund within 10 days of enrollment',
      // Analytics
      analytics: CoachingCenterAnalytics(
        totalEnquiries: 3200,
        admissionsThisMonth: 220,
        activeStudents: 1500,
        averageAttendance: 91.8,
        successfulPlacements: 1200,
        studentSatisfactionScore: 4.5,
        monthlyEnrollments: {
          'Jan': 200,
          'Feb': 250,
          'Mar': 280,
          'Apr': 220,
          'May': 180,
          'Jun': 160,
        },
        subjectWisePerformance: {
          'Biology': 92.1,
          'Chemistry': 87.5,
          'Physics': 84.8,
        },
        websiteVisits: 22000,
        brochureDownloads: 4200,
      ),
      studentReviews: [
        CoachingCenterReview(
          id: 'r003',
          studentName: 'Kavya Menon',
          studentAvatarUrl: 'https://i.pravatar.cc/150?img=3',
          rating: 5.0,
          comment: 'Amazing biology faculty and excellent study material!',
          reviewDate: DateTime.now().subtract(const Duration(days: 20)),
          course: 'NEET',
          isVerified: true,
        ),
      ],
      batches: [
        CoachingCenterBatch(
          id: 'b003',
          name: 'NEET 2025 Batch',
          course: 'NEET',
          timing: '7:00 AM - 9:00 AM',
          maxCapacity: 30,
          currentStudents: 28,
          startDate: DateTime(2024, 4, 1),
          endDate: DateTime(2025, 4, 30),
          instructor: 'Dr. Sunitha Reddy',
          fees: 18000,
          mode: 'Offline',
        ),
      ],
      faculty: [
        CoachingCenterFaculty(
          id: 'f003',
          name: 'Dr. Sunitha Reddy',
          designation: 'Director & Biology Faculty',
          qualification: 'MBBS, MD Anatomy',
          experienceYears: 12,
          subjects: ['Biology', 'Anatomy'],
          imageUrl: 'https://i.pravatar.cc/150?img=12',
          bio: 'Medical doctor turned educator with passion for teaching.',
          rating: 4.7,
        ),
      ],
      metadata: {
        'featured': false,
        'premium_partner': true,
      },
    ),

    CoachingCenter(
      id: 'cc003',
      slug: 'skilldev-training-bangalore',
      name: 'SkillDev Training',
      rating: 3.2,
      reviews: 50546,
      description: 'Affordable skill development center focusing on practical training and industry-relevant courses. We provide flexible learning options for working professionals.',
      location: 'Bangalore, Karnataka',
      coursesOffered: 20,
      studentsEnrolled: 50546,
      imageUrl: 'https://picsum.photos/400/300?random=303',
      imageGallery: [
        'https://picsum.photos/600/400?random=307',
        'https://picsum.photos/600/400?random=308',
      ],
      specializations: ['Python Programming', 'Data Analysis', 'Software Testing', 'Digital Marketing'],
      experienceYears: 8,
      isVerified: false,
      establishedDate: DateTime(2016),
      contactEmail: 'info@skilldev.com',
      contactPhone: '+91 9876543212',
      facilities: ['Weekend Classes', 'Flexible Timings', 'Online Support', 'Certification'],
      fees: 12000,
      address: 'Skill Hub, Electronic City, Bangalore - 560100',
      createdAt: DateTime(2016, 8, 10),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      // Enhanced fields
      website: 'https://www.skilldev.com',
      socialMediaLinks: [
        'https://linkedin.com/company/skilldev',
      ],
      licenseNumber: 'KA/SKILL/2016/003',
      certifications: ['NSDC Approved', 'Skill India Partner'],
      awards: [],
      foundersName: 'Ravi Shankar',
      languages: ['English', 'Kannada', 'Hindi'],
      teachingMethods: ['Hands-on Training', 'Project Based Learning', 'Industry Exposure'],
      category: 'Professional Skills',
      examsPrepared: ['Industry Certifications', 'Skill Assessments'],
      batchTimings: ['10:00 AM - 12:00 PM', '2:00 PM - 4:00 PM', '6:00 PM - 8:00 PM'],
      hasOnlineClasses: true,
      hasOfflineClasses: true,
      hasHybridClasses: false,
      successRate: 75.5,
      toppersList: ['Suresh Kumar - Placed at TCS', 'Anita Rao - Promoted to Team Lead'],
      facultyCount: 12,
      averageClassSize: 20.0,
      hasLibrary: false,
      hasLabFacility: true,
      hasHostelFacility: false,
      hasCafeteria: false,
      hasTransportFacility: false,
      admissionProcess: 'Direct admission with basic eligibility check',
      feeStructure: {
        'Python Programming': 8000,
        'Data Analysis': 12000,
        'Software Testing': 10000,
        'Digital Marketing': 9000,
      },
      scholarshipOptions: ['Early Bird Discount', 'Referral Bonus'],
      refundPolicy: '50% refund within 7 days of enrollment',
      // Analytics
      analytics: CoachingCenterAnalytics(
        totalEnquiries: 1800,
        admissionsThisMonth: 120,
        activeStudents: 800,
        averageAttendance: 78.5,
        successfulPlacements: 400,
        studentSatisfactionScore: 3.8,
        monthlyEnrollments: {
          'Jan': 100,
          'Feb': 120,
          'Mar': 140,
          'Apr': 110,
          'May': 90,
          'Jun': 80,
        },
        subjectWisePerformance: {
          'Python': 78.5,
          'Testing': 82.1,
          'Analytics': 75.8,
        },
        websiteVisits: 8000,
        brochureDownloads: 1200,
      ),
      studentReviews: [
        CoachingCenterReview(
          id: 'r004',
          studentName: 'Suresh Kumar',
          studentAvatarUrl: 'https://i.pravatar.cc/150?img=4',
          rating: 4.0,
          comment: 'Good practical training, helped me get a job.',
          reviewDate: DateTime.now().subtract(const Duration(days: 45)),
          course: 'Python Programming',
          isVerified: false,
        ),
      ],
      batches: [
        CoachingCenterBatch(
          id: 'b004',
          name: 'Python Weekend Batch',
          course: 'Python Programming',
          timing: '10:00 AM - 12:00 PM',
          maxCapacity: 25,
          currentStudents: 18,
          startDate: DateTime(2025, 1, 15),
          endDate: DateTime(2025, 4, 15),
          instructor: 'Ravi Shankar',
          fees: 8000,
          mode: 'Offline',
        ),
      ],
      faculty: [
        CoachingCenterFaculty(
          id: 'f004',
          name: 'Ravi Shankar',
          designation: 'Senior Trainer',
          qualification: 'B.Tech Computer Science',
          experienceYears: 8,
          subjects: ['Python', 'Data Analysis'],
          imageUrl: 'https://i.pravatar.cc/150?img=13',
          bio: 'Industry professional with hands-on experience.',
          rating: 3.8,
        ),
      ],
      metadata: {
        'featured': false,
        'premium_partner': false,
      },
    ),

    CoachingCenter(
      id: 'cc004',
      slug: 'gocorp-solutions-chennai',
      name: 'GoCorp Solutions',
      rating: 4.6,
      reviews: 126568,
      description: 'Leading corporate training institute with 20 years of excellence in professional development. We specialize in advanced technology training and leadership development.',
      location: 'Chennai, Tamil Nadu',
      coursesOffered: 35,
      studentsEnrolled: 126568,
      imageUrl: 'https://picsum.photos/400/300?random=304',
      imageGallery: [
        'https://picsum.photos/600/400?random=309',
        'https://picsum.photos/600/400?random=310',
        'https://picsum.photos/600/400?random=311',
      ],
      specializations: ['Enterprise Solutions', 'Cloud Computing', 'DevOps', 'Leadership Training'],
      experienceYears: 20,
      isVerified: true,
      establishedDate: DateTime(2004),
      contactEmail: 'admissions@gocorp.com',
      contactPhone: '+91 9876543213',
      facilities: ['Corporate Training', 'Executive Programs', 'Consulting', 'Mentorship'],
      fees: 25000,
      address: 'Corporate Tower, Anna Salai, Chennai - 600002',
      createdAt: DateTime(2004, 1, 15),
      updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
      // Enhanced fields
      website: 'https://www.gocorp.com',
      socialMediaLinks: [
        'https://linkedin.com/company/gocorp',
        'https://twitter.com/gocorp',
        'https://youtube.com/gocorp',
      ],
      licenseNumber: 'TN/CORP/2004/001',
      certifications: ['ISO 27001', 'AWS Training Partner', 'Microsoft Gold Partner'],
      awards: ['Best Corporate Training 2023', 'Excellence in Technology Education'],
      foundersName: 'Vikram Patel',
      languages: ['English', 'Tamil'],
      teachingMethods: ['Case Studies', 'Real Projects', 'Mentoring', 'Industry Immersion'],
      category: 'Corporate Training',
      examsPrepared: ['AWS Certifications', 'Microsoft Certifications', 'Google Cloud'],
      batchTimings: ['9:00 AM - 12:00 PM', '2:00 PM - 5:00 PM', '6:00 PM - 9:00 PM'],
      hasOnlineClasses: true,
      hasOfflineClasses: true,
      hasHybridClasses: true,
      successRate: 95.8,
      toppersList: ['Amit Sharma - AWS Solutions Architect', 'Neha Gupta - Microsoft Azure Expert'],
      facultyCount: 35,
      averageClassSize: 15.0,
      hasLibrary: true,
      hasLabFacility: true,
      hasHostelFacility: false,
      hasCafeteria: true,
      hasTransportFacility: false,
      admissionProcess: 'Professional assessment and interview',
      feeStructure: {
        'AWS Cloud': 30000,
        'DevOps Mastery': 25000,
        'Leadership Program': 40000,
        'Enterprise Architecture': 35000,
      },
      scholarshipOptions: ['Corporate Sponsorship', 'Alumni Referral'],
      refundPolicy: '90% refund within 5 days of enrollment',
      // Analytics
      analytics: CoachingCenterAnalytics(
        totalEnquiries: 5000,
        admissionsThisMonth: 300,
        activeStudents: 2000,
        averageAttendance: 96.2,
        successfulPlacements: 1800,
        studentSatisfactionScore: 4.8,
        monthlyEnrollments: {
          'Jan': 280,
          'Feb': 320,
          'Mar': 350,
          'Apr': 300,
          'May': 250,
          'Jun': 220,
        },
        subjectWisePerformance: {
          'Cloud Computing': 94.5,
          'DevOps': 92.8,
          'Leadership': 96.1,
        },
        websiteVisits: 45000,
        brochureDownloads: 8500,
      ),
      studentReviews: [
        CoachingCenterReview(
          id: 'r005',
          studentName: 'Amit Sharma',
          studentAvatarUrl: 'https://i.pravatar.cc/150?img=5',
          rating: 5.0,
          comment: 'Excellent corporate training with real-world projects!',
          reviewDate: DateTime.now().subtract(const Duration(days: 10)),
          course: 'AWS Cloud',
          isVerified: true,
        ),
      ],
      batches: [
        CoachingCenterBatch(
          id: 'b005',
          name: 'AWS Professional Batch',
          course: 'AWS Cloud',
          timing: '9:00 AM - 12:00 PM',
          maxCapacity: 20,
          currentStudents: 18,
          startDate: DateTime(2025, 2, 1),
          endDate: DateTime(2025, 5, 31),
          instructor: 'Vikram Patel',
          fees: 30000,
          mode: 'Hybrid',
        ),
      ],
      faculty: [
        CoachingCenterFaculty(
          id: 'f005',
          name: 'Vikram Patel',
          designation: 'CEO & Chief Architect',
          qualification: 'M.Tech IIT Delhi, AWS Certified',
          experienceYears: 20,
          subjects: ['Cloud Computing', 'Enterprise Architecture'],
          imageUrl: 'https://i.pravatar.cc/150?img=14',
          bio: 'Industry veteran with 20+ years in enterprise solutions.',
          rating: 4.9,
        ),
      ],
      metadata: {
        'featured': true,
        'premium_partner': true,
        'corporate_partner': true,
      },
    ),

    CoachingCenter(
      id: 'cc005',
      slug: 'tech-innovators-hyderabad',
      name: 'Tech Innovators Academy',
      rating: 4.4,
      reviews: 75432,
      description: 'Modern technology training institute focusing on emerging technologies like AI, Machine Learning, and Blockchain. We prepare students for the future of technology.',
      location: 'Hyderabad, Telangana',
      coursesOffered: 28,
      studentsEnrolled: 75432,
      imageUrl: 'https://picsum.photos/400/300?random=305',
      imageGallery: [
        'https://picsum.photos/600/400?random=312',
        'https://picsum.photos/600/400?random=313',
      ],
      specializations: ['Artificial Intelligence', 'Machine Learning', 'Blockchain', 'IoT'],
      experienceYears: 10,
      isVerified: true,
      establishedDate: DateTime(2014),
      contactEmail: 'info@techinnovators.com',
      contactPhone: '+91 9876543216',
      facilities: ['AI Lab', 'Research Center', 'Innovation Hub', 'Industry Partnerships'],
      fees: 22000,
      address: 'Tech Park, HITEC City, Hyderabad - 500081',
      createdAt: DateTime(2014, 9, 1),
      updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
      // Enhanced fields
      website: 'https://www.techinnovators.com',
      socialMediaLinks: [
        'https://linkedin.com/company/techinnovators',
        'https://github.com/techinnovators',
        'https://medium.com/@techinnovators',
      ],
      licenseNumber: 'TS/TECH/2014/005',
      certifications: ['NVIDIA DLI Partner', 'Google AI Partner', 'IBM Watson Partner'],
      awards: ['Innovation in Education 2023', 'Best AI Training Institute'],
      foundersName: 'Dr. Priya Krishnan',
      languages: ['English', 'Telugu', 'Hindi'],
      teachingMethods: ['Research Projects', 'Industry Collaboration', 'Hackathons', 'Peer Learning'],
      category: 'Emerging Technologies',
      examsPrepared: ['Google AI Certification', 'AWS ML Specialty', 'IBM Data Science'],
      batchTimings: ['8:00 AM - 11:00 AM', '1:00 PM - 4:00 PM', '5:00 PM - 8:00 PM'],
      hasOnlineClasses: true,
      hasOfflineClasses: true,
      hasHybridClasses: true,
      successRate: 87.3,
      toppersList: ['Rahul Reddy - Google AI Researcher', 'Sneha Patel - ML Engineer at Microsoft'],
      facultyCount: 22,
      averageClassSize: 18.0,
      hasLibrary: true,
      hasLabFacility: true,
      hasHostelFacility: true,
      hasCafeteria: true,
      hasTransportFacility: true,
      admissionProcess: 'Technical aptitude test and portfolio review',
      feeStructure: {
        'AI Foundation': 18000,
        'ML Advanced': 22000,
        'Blockchain Development': 20000,
        'IoT Solutions': 19000,
      },
      scholarshipOptions: ['Women in Tech Scholarship', 'Research Excellence Grant'],
      refundPolicy: '75% refund within 14 days of enrollment',
      // Analytics
      analytics: CoachingCenterAnalytics(
        totalEnquiries: 4200,
        admissionsThisMonth: 280,
        activeStudents: 1800,
        averageAttendance: 89.7,
        successfulPlacements: 1400,
        studentSatisfactionScore: 4.6,
        monthlyEnrollments: {
          'Jan': 250,
          'Feb': 280,
          'Mar': 320,
          'Apr': 290,
          'May': 240,
          'Jun': 200,
        },
        subjectWisePerformance: {
          'AI/ML': 88.9,
          'Blockchain': 85.4,
          'IoT': 87.2,
        },
        websiteVisits: 35000,
        brochureDownloads: 6200,
      ),
      studentReviews: [
        CoachingCenterReview(
          id: 'r006',
          studentName: 'Rahul Reddy',
          studentAvatarUrl: 'https://i.pravatar.cc/150?img=6',
          rating: 4.8,
          comment: 'Cutting-edge curriculum and excellent research opportunities!',
          reviewDate: DateTime.now().subtract(const Duration(days: 25)),
          course: 'AI Foundation',
          isVerified: true,
        ),
      ],
      batches: [
        CoachingCenterBatch(
          id: 'b006',
          name: 'AI/ML Batch 2025',
          course: 'AI Foundation',
          timing: '1:00 PM - 4:00 PM',
          maxCapacity: 25,
          currentStudents: 22,
          startDate: DateTime(2025, 3, 1),
          endDate: DateTime(2025, 8, 31),
          instructor: 'Dr. Priya Krishnan',
          fees: 18000,
          mode: 'Hybrid',
        ),
      ],
      faculty: [
        CoachingCenterFaculty(
          id: 'f006',
          name: 'Dr. Priya Krishnan',
          designation: 'Director & AI Research Head',
          qualification: 'Ph.D in AI, Stanford University',
          experienceYears: 10,
          subjects: ['Artificial Intelligence', 'Machine Learning'],
          imageUrl: 'https://i.pravatar.cc/150?img=15',
          bio: 'Former Google AI researcher with expertise in deep learning.',
          rating: 4.8,
        ),
      ],
      metadata: {
        'featured': true,
        'premium_partner': true,
        'research_partner': true,
      },
    ),
  ];

  // Enhanced helper methods
  static List<CoachingCenter> getCoachingCenters() {
    return List.from(coachingCenters);
  }

  static List<CoachingCenter> getTopRatedCenters({double minRating = 4.5}) {
    return coachingCenters.where((center) => center.rating >= minRating).toList();
  }

  static List<CoachingCenter> getCentersByLocation(String location) {
    return coachingCenters.where((center) => 
      center.location.toLowerCase().contains(location.toLowerCase())).toList();
  }

  static List<CoachingCenter> getVerifiedCenters() {
    return coachingCenters.where((center) => center.isVerified).toList();
  }

  static List<CoachingCenter> getCentersByCategory(String category) {
    return coachingCenters.where((center) => 
      center.category.toLowerCase().contains(category.toLowerCase())).toList();
  }

  static List<CoachingCenter> getCentersWithFacilities(String facility) {
    return coachingCenters.where((center) => 
      center.allFacilities.any((f) => f.toLowerCase().contains(facility.toLowerCase()))).toList();
  }

  static List<CoachingCenter> getCentersByFeeRange(double minFee, double maxFee) {
    return coachingCenters.where((center) => 
      center.fees >= minFee && center.fees <= maxFee).toList();
  }

  static List<CoachingCenter> getCentersWithAvailableSeats() {
    return coachingCenters.where((center) => center.hasAvailableSeats).toList();
  }

  static List<CoachingCenter> getFeaturedCenters() {
    return coachingCenters.where((center) => 
      center.metadata['featured'] == true).toList();
  }

  static List<CoachingCenter> searchCenters(String query) {
    final lowercaseQuery = query.toLowerCase();
    return coachingCenters.where((center) =>
      center.name.toLowerCase().contains(lowercaseQuery) ||
      center.description.toLowerCase().contains(lowercaseQuery) ||
      center.specializations.any((s) => s.toLowerCase().contains(lowercaseQuery)) ||
      center.location.toLowerCase().contains(lowercaseQuery) ||
      center.category.toLowerCase().contains(lowercaseQuery)).toList();
  }

  // Analytics methods
  static double getAverageRating() {
    if (coachingCenters.isEmpty) return 0.0;
    return coachingCenters.map((c) => c.rating).reduce((a, b) => a + b) / coachingCenters.length;
  }

  static int getTotalStudents() {
    return coachingCenters.map((c) => c.studentsEnrolled).reduce((a, b) => a + b);
  }

  static int getTotalCourses() {
    return coachingCenters.map((c) => c.coursesOffered).reduce((a, b) => a + b);
  }

  static List<String> getUniqueLocations() {
    return coachingCenters.map((c) => c.location).toSet().toList()..sort();
  }

  static List<String> getUniqueCategories() {
    return coachingCenters.map((c) => c.category).where((c) => c.isNotEmpty).toSet().toList()..sort();
  }

  static List<String> getAllSpecializations() {
    return coachingCenters
        .expand((c) => c.specializations)
        .toSet()
        .toList()..sort();
  }
}
