// data/coaching_center_dummy_data.dart
import '../models/coaching_center_model.dart';

class CoachingCenterDummyData {
  static final List<CoachingCenter> coachingCenters = [
    CoachingCenter(
      id: 'cc001',
      name: 'The Leaders Academy',
      rating: 4.8,
      reviews: 50865,
      description: 'One of the top coaching classes in the country, based on Trichy',
      location: 'Trichy, Tamil Nadu',
      coursesOffered: 25,
      studentsEnrolled: 50865,
      imageUrl: 'https://picsum.photos/200/200?random=301',
      specializations: ['Python', 'Data Science', 'Web Development', 'AI/ML'],
      experienceYears: 15,
      isVerified: true,
      establishedDate: DateTime(2009),
      contactEmail: 'info@leadersacademy.com',
      contactPhone: '+91 9876543210',
      facilities: ['Online Classes', 'Offline Classes', 'Lab Facility', 'Placement Support'],
      fees: 15000,
      address: 'No. 123, Main Street, Trichy - 620001',
    ),
    CoachingCenter(
      id: 'cc002',
      name: 'Expert Academy',
      rating: 4.6,
      reviews: 105653,
      description: 'Choose expert academy to become an expert quickly in Software Development',
      location: 'Chennai, Tamil Nadu',
      coursesOffered: 30,
      studentsEnrolled: 105653,
      imageUrl: 'https://picsum.photos/200/200?random=302',
      specializations: ['Full Stack Development', 'Mobile Development', 'DevOps', 'Cloud Computing'],
      experienceYears: 12,
      isVerified: true,
      establishedDate: DateTime(2012),
      contactEmail: 'contact@expertacademy.com',
      contactPhone: '+91 9876543211',
      facilities: ['24/7 Lab Access', 'Industry Mentors', 'Live Projects', 'Job Guarantee'],
      fees: 18000,
      address: 'Tower A, Tech Park, Chennai - 600001',
    ),
    CoachingCenter(
      id: 'cc003',
      name: 'SkillDev Training',
      rating: 3.2,
      reviews: 50546,
      description: 'We are committed to giving you the essential guidance and knowledge to gain much needed skills',
      location: 'Bangalore, Karnataka',
      coursesOffered: 20,
      studentsEnrolled: 50546,
      imageUrl: 'https://picsum.photos/200/200?random=303',
      specializations: ['Python Basics', 'Data Analysis', 'Automation', 'Testing'],
      experienceYears: 8,
      isVerified: false,
      establishedDate: DateTime(2016),
      contactEmail: 'info@skilldev.com',
      contactPhone: '+91 9876543212',
      facilities: ['Weekend Classes', 'Flexible Timings', 'Online Support', 'Certification'],
      fees: 12000,
      address: 'Skill Hub, Electronic City, Bangalore - 560100',
    ),
    CoachingCenter(
      id: 'cc004',
      name: 'GoCorp Solutions',
      rating: 4.6,
      reviews: 126568,
      description: 'We are the top coaching company in Chennai with an experience of 20 years',
      location: 'Chennai, Tamil Nadu',
      coursesOffered: 35,
      studentsEnrolled: 126568,
      imageUrl: 'https://picsum.photos/200/200?random=304',
      specializations: ['Enterprise Python', 'System Design', 'Architecture', 'Leadership'],
      experienceYears: 20,
      isVerified: true,
      establishedDate: DateTime(2004),
      contactEmail: 'admissions@gocorp.com',
      contactPhone: '+91 9876543213',
      facilities: ['Corporate Training', 'Executive Programs', 'Consulting', 'Mentorship'],
      fees: 25000,
      address: 'Corporate Tower, Anna Salai, Chennai - 600002',
    ),
    CoachingCenter(
      id: 'cc005',
      name: 'GoCorp Solutions',
      rating: 4.5,
      reviews: 126568,
      description: 'We are the top coaching company in Chennai with an experience of 20 years',
      location: 'Chennai, Tamil Nadu',
      coursesOffered: 35,
      studentsEnrolled: 126568,
      imageUrl: 'https://picsum.photos/200/200?random=305',
      specializations: ['Python for Beginners', 'Advanced Python', 'Django', 'Flask'],
      experienceYears: 20,
      isVerified: true,
      establishedDate: DateTime(2004),
      contactEmail: 'info@gocorp.com',
      contactPhone: '+91 9876543214',
      facilities: ['Beginner Friendly', 'Hands-on Training', 'Project Based', 'Career Guidance'],
      fees: 20000,
      address: 'Branch 2, OMR Road, Chennai - 600096',
    ),
    CoachingCenter(
      id: 'cc006',
      name: 'GoCorp Solutions',
      rating: 4.8,
      reviews: 126568,
      description: 'We are the top coaching company in Chennai with an experience of 20 years',
      location: 'Chennai, Tamil Nadu',
      coursesOffered: 35,
      studentsEnrolled: 126568,
      imageUrl: 'https://picsum.photos/200/200?random=306',
      specializations: ['Data Science with Python', 'Machine Learning', 'Deep Learning', 'AI'],
      experienceYears: 20,
      isVerified: true,
      establishedDate: DateTime(2004),
      contactEmail: 'datascience@gocorp.com',
      contactPhone: '+91 9876543215',
      facilities: ['GPU Lab', 'Research Projects', 'Industry Collaboration', 'PhD Guidance'],
      fees: 30000,
      address: 'Research Center, Velachery, Chennai - 600042',
    ),
  ];

  static List<CoachingCenter> getCoachingCenters() {
    return List.from(coachingCenters);
  }

  static List<CoachingCenter> getTopRatedCenters() {
    return coachingCenters.where((center) => center.rating >= 4.5).toList();
  }

  static List<CoachingCenter> getCentersByLocation(String location) {
    return coachingCenters.where((center) => 
      center.location.toLowerCase().contains(location.toLowerCase())).toList();
  }

  static List<CoachingCenter> getVerifiedCenters() {
    return coachingCenters.where((center) => center.isVerified).toList();
  }
}
