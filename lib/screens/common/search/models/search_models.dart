// models/search_models.dart
import 'package:brainboosters_app/screens/common/live_class/models/live_class_model.dart';

import '../../courses/models/course_model.dart';

abstract class SearchResult {
  String get id;
  String get title;
  String get academy;
  String get imageUrl;
  double get rating;
  double get price;
  bool get isFree;
  String get type; // 'course' or 'live_class'
  String get difficulty;
  String get category;
  DateTime get createdAt;
}

class CourseSearchResult implements SearchResult {
  final Course course;
  
  CourseSearchResult(this.course);
  
  @override
  String get id => course.id;
  @override
  String get title => course.title;
  @override
  String get academy => course.academy;
  @override
  String get imageUrl => course.imageUrl;
  @override
  double get rating => course.rating;
  @override
  double get price => course.price;
  @override
  bool get isFree => course.isFree;
  @override
  String get type => 'course';
  @override
  String get difficulty => course.difficulty;
  @override
  String get category => course.category;
  @override
  DateTime get createdAt => course.createdAt;
}

class LiveClassSearchResult implements SearchResult {
  final LiveClass liveClass;
  
  LiveClassSearchResult(this.liveClass);
  
  @override
  String get id => liveClass.id;
  @override
  String get title => liveClass.title;
  @override
  String get academy => liveClass.academy;
  @override
  String get imageUrl => liveClass.imageUrl;
  @override
  double get rating => 4.5; // Default rating for live classes
  @override
  double get price => liveClass.price;
  @override
  bool get isFree => liveClass.price == 0.0;
  @override
  String get type => 'live_class';
  @override
  String get difficulty => liveClass.difficulty;
  @override
  String get category => liveClass.category;
  @override
  DateTime get createdAt => DateTime.now(); // Default for live classes
}
