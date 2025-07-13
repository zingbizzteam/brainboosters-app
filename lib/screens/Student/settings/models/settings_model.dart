class SettingsModel {
  final String version;
  final NotificationSettings notifications;
  final LearningSettings learning;
  final PrivacySettings privacy;
  final StorageSettings storage;
  final AccountSettings account;

  const SettingsModel({
    required this.version,
    required this.notifications,
    required this.learning,
    required this.privacy,
    required this.storage,
    required this.account,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      version: json['version']?.toString() ?? '4',
      notifications: NotificationSettings.fromJson(json['notifications'] ?? {}),
      learning: LearningSettings.fromJson(json['learning'] ?? {}),
      privacy: PrivacySettings.fromJson(json['privacy'] ?? {}),
      storage: StorageSettings.fromJson(json['storage'] ?? {}),
      account: AccountSettings.fromJson(json['account'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'notifications': notifications.toJson(),
      'learning': learning.toJson(),
      'privacy': privacy.toJson(),
      'storage': storage.toJson(),
      'account': account.toJson(),
    };
  }

  SettingsModel copyWith({
    String? version,
    NotificationSettings? notifications,
    LearningSettings? learning,
    PrivacySettings? privacy,
    StorageSettings? storage,
    AccountSettings? account,
  }) {
    return SettingsModel(
      version: version ?? this.version,
      notifications: notifications ?? this.notifications,
      learning: learning ?? this.learning,
      privacy: privacy ?? this.privacy,
      storage: storage ?? this.storage,
      account: account ?? this.account,
    );
  }
}

class NotificationSettings {
  final bool pushEnabled;
  final bool emailEnabled;
  final bool courseReminders;
  final bool liveClassReminders;
  final bool assignmentDeadlines;
  final bool achievementNotifications;
  final QuietHours quietHours;

  const NotificationSettings({
    required this.pushEnabled,
    required this.emailEnabled,
    required this.courseReminders,
    required this.liveClassReminders,
    required this.assignmentDeadlines,
    required this.achievementNotifications,
    required this.quietHours,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      pushEnabled: json['pushEnabled'] ?? true,
      emailEnabled: json['emailEnabled'] ?? true,
      courseReminders: json['courseReminders'] ?? true,
      liveClassReminders: json['liveClassReminders'] ?? true,
      assignmentDeadlines: json['assignmentDeadlines'] ?? true,
      achievementNotifications: json['achievementNotifications'] ?? true,
      quietHours: QuietHours.fromJson(json['quietHours'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pushEnabled': pushEnabled,
      'emailEnabled': emailEnabled,
      'courseReminders': courseReminders,
      'liveClassReminders': liveClassReminders,
      'assignmentDeadlines': assignmentDeadlines,
      'achievementNotifications': achievementNotifications,
      'quietHours': quietHours.toJson(),
    };
  }

  NotificationSettings copyWith({
    bool? pushEnabled,
    bool? emailEnabled,
    bool? courseReminders,
    bool? liveClassReminders,
    bool? assignmentDeadlines,
    bool? achievementNotifications,
    QuietHours? quietHours,
  }) {
    return NotificationSettings(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      courseReminders: courseReminders ?? this.courseReminders,
      liveClassReminders: liveClassReminders ?? this.liveClassReminders,
      assignmentDeadlines: assignmentDeadlines ?? this.assignmentDeadlines,
      achievementNotifications: achievementNotifications ?? this.achievementNotifications,
      quietHours: quietHours ?? this.quietHours,
    );
  }
}

class LearningSettings {
  final bool autoPlay;
  final double playbackSpeed;
  final bool subtitlesEnabled;
  final String downloadQuality;
  final StudyReminders studyReminders;
  final bool progressTracking;
  final bool analyticsSharing;

  const LearningSettings({
    required this.autoPlay,
    required this.playbackSpeed,
    required this.subtitlesEnabled,
    required this.downloadQuality,
    required this.studyReminders,
    required this.progressTracking,
    required this.analyticsSharing,
  });

  factory LearningSettings.fromJson(Map<String, dynamic> json) {
    return LearningSettings(
      autoPlay: json['autoPlay'] ?? true,
      playbackSpeed: (json['playbackSpeed'] ?? 1.0).toDouble(),
      subtitlesEnabled: json['subtitlesEnabled'] ?? true,
      downloadQuality: json['downloadQuality'] ?? 'medium',
      studyReminders: StudyReminders.fromJson(json['studyReminders'] ?? {}),
      progressTracking: json['progressTracking'] ?? true,
      analyticsSharing: json['analyticsSharing'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'autoPlay': autoPlay,
      'playbackSpeed': playbackSpeed,
      'subtitlesEnabled': subtitlesEnabled,
      'downloadQuality': downloadQuality,
      'studyReminders': studyReminders.toJson(),
      'progressTracking': progressTracking,
      'analyticsSharing': analyticsSharing,
    };
  }

  LearningSettings copyWith({
    bool? autoPlay,
    double? playbackSpeed,
    bool? subtitlesEnabled,
    String? downloadQuality,
    StudyReminders? studyReminders,
    bool? progressTracking,
    bool? analyticsSharing,
  }) {
    return LearningSettings(
      autoPlay: autoPlay ?? this.autoPlay,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      subtitlesEnabled: subtitlesEnabled ?? this.subtitlesEnabled,
      downloadQuality: downloadQuality ?? this.downloadQuality,
      studyReminders: studyReminders ?? this.studyReminders,
      progressTracking: progressTracking ?? this.progressTracking,
      analyticsSharing: analyticsSharing ?? this.analyticsSharing,
    );
  }
}

class PrivacySettings {
  final String profileVisibility;
  final bool showOnlineStatus;
  final bool shareProgress;
  final bool dataCollection;
  final bool crashReporting;

  const PrivacySettings({
    required this.profileVisibility,
    required this.showOnlineStatus,
    required this.shareProgress,
    required this.dataCollection,
    required this.crashReporting,
  });

  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    return PrivacySettings(
      profileVisibility: json['profileVisibility'] ?? 'private',
      showOnlineStatus: json['showOnlineStatus'] ?? false,
      shareProgress: json['shareProgress'] ?? false,
      dataCollection: json['dataCollection'] ?? true,
      crashReporting: json['crashReporting'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profileVisibility': profileVisibility,
      'showOnlineStatus': showOnlineStatus,
      'shareProgress': shareProgress,
      'dataCollection': dataCollection,
      'crashReporting': crashReporting,
    };
  }

  PrivacySettings copyWith({
    String? profileVisibility,
    bool? showOnlineStatus,
    bool? shareProgress,
    bool? dataCollection,
    bool? crashReporting,
  }) {
    return PrivacySettings(
      profileVisibility: profileVisibility ?? this.profileVisibility,
      showOnlineStatus: showOnlineStatus ?? this.showOnlineStatus,
      shareProgress: shareProgress ?? this.shareProgress,
      dataCollection: dataCollection ?? this.dataCollection,
      crashReporting: crashReporting ?? this.crashReporting,
    );
  }
}

class StorageSettings {
  final int maxCacheSize;
  final bool autoDeleteDownloads;
  final bool downloadOnWifiOnly;

  const StorageSettings({
    required this.maxCacheSize,
    required this.autoDeleteDownloads,
    required this.downloadOnWifiOnly,
  });

  factory StorageSettings.fromJson(Map<String, dynamic> json) {
    return StorageSettings(
      maxCacheSize: json['maxCacheSize'] ?? 500,
      autoDeleteDownloads: json['autoDeleteDownloads'] ?? false,
      downloadOnWifiOnly: json['downloadOnWifiOnly'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maxCacheSize': maxCacheSize,
      'autoDeleteDownloads': autoDeleteDownloads,
      'downloadOnWifiOnly': downloadOnWifiOnly,
    };
  }

  StorageSettings copyWith({
    int? maxCacheSize,
    bool? autoDeleteDownloads,
    bool? downloadOnWifiOnly,
  }) {
    return StorageSettings(
      maxCacheSize: maxCacheSize ?? this.maxCacheSize,
      autoDeleteDownloads: autoDeleteDownloads ?? this.autoDeleteDownloads,
      downloadOnWifiOnly: downloadOnWifiOnly ?? this.downloadOnWifiOnly,
    );
  }
}

class AccountSettings {
  final String language;
  final String timezone;
  final String currency;
  final bool twoFactorEnabled;

  const AccountSettings({
    required this.language,
    required this.timezone,
    required this.currency,
    required this.twoFactorEnabled,
  });

  factory AccountSettings.fromJson(Map<String, dynamic> json) {
    return AccountSettings(
      language: json['language'] ?? 'en',
      timezone: json['timezone'] ?? 'auto',
      currency: json['currency'] ?? 'USD',
      twoFactorEnabled: json['twoFactorEnabled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'timezone': timezone,
      'currency': currency,
      'twoFactorEnabled': twoFactorEnabled,
    };
  }

  AccountSettings copyWith({
    String? language,
    String? timezone,
    String? currency,
    bool? twoFactorEnabled,
  }) {
    return AccountSettings(
      language: language ?? this.language,
      timezone: timezone ?? this.timezone,
      currency: currency ?? this.currency,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
    );
  }
}

class QuietHours {
  final bool enabled;
  final String startTime;
  final String endTime;

  const QuietHours({
    required this.enabled,
    required this.startTime,
    required this.endTime,
  });

  factory QuietHours.fromJson(Map<String, dynamic> json) {
    return QuietHours(
      enabled: json['enabled'] ?? false,
      startTime: json['startTime'] ?? '22:00',
      endTime: json['endTime'] ?? '08:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  QuietHours copyWith({
    bool? enabled,
    String? startTime,
    String? endTime,
  }) {
    return QuietHours(
      enabled: enabled ?? this.enabled,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}

class StudyReminders {
  final bool enabled;
  final String frequency;
  final String time;

  const StudyReminders({
    required this.enabled,
    required this.frequency,
    required this.time,
  });

  factory StudyReminders.fromJson(Map<String, dynamic> json) {
    return StudyReminders(
      enabled: json['enabled'] ?? true,
      frequency: json['frequency'] ?? 'daily',
      time: json['time'] ?? '19:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'frequency': frequency,
      'time': time,
    };
  }

  StudyReminders copyWith({
    bool? enabled,
    String? frequency,
    String? time,
  }) {
    return StudyReminders(
      enabled: enabled ?? this.enabled,
      frequency: frequency ?? this.frequency,
      time: time ?? this.time,
    );
  }
}
