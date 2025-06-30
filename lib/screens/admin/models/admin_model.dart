

import 'package:brainboosters_app/screens/authentication/models/enums.dart';

class Admin {
  final String id;
  final String adminId;
  final AdminRole role;
  final List<String> permissions;
  final String? department;
  final String? reportingTo;
  final int accessLevel;
  final bool canApproveCenters;
  final bool canManageUsers;
  final bool canManageContent;
  final bool canViewAnalytics;
  final bool canManagePayments;
  final DateTime? lastLoginAt;
  final int loginCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Admin({
    required this.id,
    required this.adminId,
    required this.role,
    this.permissions = const [],
    this.department,
    this.reportingTo,
    this.accessLevel = 1,
    this.canApproveCenters = false,
    this.canManageUsers = false,
    this.canManageContent = false,
    this.canViewAnalytics = false,
    this.canManagePayments = false,
    this.lastLoginAt,
    this.loginCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json['id'],
      adminId: json['admin_id'],
      role: AdminRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
      ),
      permissions: List<String>.from(json['permissions'] ?? []),
      department: json['department'],
      reportingTo: json['reporting_to'],
      accessLevel: json['access_level'] ?? 1,
      canApproveCenters: json['can_approve_centers'] ?? false,
      canManageUsers: json['can_manage_users'] ?? false,
      canManageContent: json['can_manage_content'] ?? false,
      canViewAnalytics: json['can_view_analytics'] ?? false,
      canManagePayments: json['can_manage_payments'] ?? false,
      lastLoginAt: json['last_login_at'] != null 
          ? DateTime.parse(json['last_login_at']) 
          : null,
      loginCount: json['login_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'admin_id': adminId,
      'role': role.toString().split('.').last,
      'permissions': permissions,
      'department': department,
      'reporting_to': reportingTo,
      'access_level': accessLevel,
      'can_approve_centers': canApproveCenters,
      'can_manage_users': canManageUsers,
      'can_manage_content': canManageContent,
      'can_view_analytics': canViewAnalytics,
      'can_manage_payments': canManagePayments,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'login_count': loginCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Admin copyWith({
    String? id,
    String? adminId,
    AdminRole? role,
    List<String>? permissions,
    String? department,
    String? reportingTo,
    int? accessLevel,
    bool? canApproveCenters,
    bool? canManageUsers,
    bool? canManageContent,
    bool? canViewAnalytics,
    bool? canManagePayments,
    DateTime? lastLoginAt,
    int? loginCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Admin(
      id: id ?? this.id,
      adminId: adminId ?? this.adminId,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      department: department ?? this.department,
      reportingTo: reportingTo ?? this.reportingTo,
      accessLevel: accessLevel ?? this.accessLevel,
      canApproveCenters: canApproveCenters ?? this.canApproveCenters,
      canManageUsers: canManageUsers ?? this.canManageUsers,
      canManageContent: canManageContent ?? this.canManageContent,
      canViewAnalytics: canViewAnalytics ?? this.canViewAnalytics,
      canManagePayments: canManagePayments ?? this.canManagePayments,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      loginCount: loginCount ?? this.loginCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
