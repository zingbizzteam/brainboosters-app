// lib/services/live_class_service.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LiveClassService {
  static final JitsiMeet _jitsiMeet = JitsiMeet();
  static final SupabaseClient _supabase = Supabase.instance.client;
  static bool _isInitialized = false;
  


  // CRITICAL: Initialize with proper error handling
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final completer = Completer<void>();
      final options = JitsiMeetConferenceOptions(
        serverURL: "https://meet.jit.si",
        room: "test-initialization-${DateTime.now().millisecondsSinceEpoch}",
        configOverrides: {
          "startWithAudioMuted": true,
          "startWithVideoMuted": true,
        },
        featureFlags: {
          "welcomepage.enabled": false,
          "prejoinpage.enabled": false,
        },
        userInfo: JitsiMeetUserInfo(
          displayName: "System Test",
          email: "test@brainboosters.com",
        ),
      );

      // FIXED: Listener is passed directly into the join method.
      // It is used here to automatically leave the test meeting.
      final listener = JitsiMeetEventListener(
        conferenceJoined: (url) async {
          debugPrint("✅ Jitsi Meet initialization test joined, now leaving.");
          await _jitsiMeet.hangUp();
        },
        conferenceTerminated: (url, error) {
          if (!completer.isCompleted) {
            if (error != null) {
              completer.completeError(error);
            } else {
              completer.complete();
            }
          }
        },
      );

      await _jitsiMeet.join(options, listener);
      await completer.future; // Wait for the test call to terminate

      _isInitialized = true;
      debugPrint("✅ Jitsi Meet initialized successfully");
    } catch (e) {
      debugPrint("❌ Failed to initialize Jitsi Meet: $e");
      throw Exception("Video calling service unavailable: $e");
    }
  }

  static Future<bool> requestPermissions() async {
    try {
      final permissions = await [
        Permission.camera,
        Permission.microphone,
      ].request();

      final allGranted = permissions.values.every((status) => status.isGranted);

      if (!allGranted) {
        debugPrint("❌ Required permissions not granted");
      }
      return allGranted;
    } catch (e) {
      debugPrint("❌ Error requesting permissions: $e");
      return false;
    }
  }

  // CRITICAL: Secure live class access with payment verification
  static Future<Map<String, dynamic>> verifyLiveClassAccess(String liveClassId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return {
          'hasAccess': false,
          'reason': 'Authentication required',
          'requiresLogin': true,
        };
      }

      // Get live class details with payment verification
      final liveClassResponse = await _supabase
          .from('live_classes')
          .select('''
            id, title, price, is_free, status, scheduled_at, duration_minutes,
            max_participants, current_participants, course_id,
            coaching_centers(id, center_name),
            teachers(id, user_profiles(first_name, last_name))
          ''')
          .eq('id', liveClassId)
          .single();

      // Check if live class exists and is accessible
      if (liveClassResponse['status'] == 'cancelled') {
        return {
          'hasAccess': false,
          'reason': 'This live class has been cancelled',
          'liveClass': liveClassResponse,
        };
      }

      // Get student ID
      final studentResponse = await _supabase
          .from('students')
          .select('id')
          .eq('user_id', user.id)
          .single();

      final studentId = studentResponse['id'];

      // Check enrollment
      final enrollmentResponse = await _supabase
          .from('live_class_enrollments')
          .select('id, enrolled_at')
          .eq('student_id', studentId)
          .eq('live_class_id', liveClassId)
          .maybeSingle();

      if (enrollmentResponse == null) {
        // Not enrolled - check if enrollment is still possible
        if (liveClassResponse['current_participants'] >= liveClassResponse['max_participants']) {
          return {
            'hasAccess': false,
            'reason': 'Live class is full',
            'liveClass': liveClassResponse,
          };
        }

        return {
          'hasAccess': false,
          'reason': 'Enrollment required',
          'requiresEnrollment': true,
          'liveClass': liveClassResponse,
        };
      }

      // Verify payment if not free
      if (!liveClassResponse['is_free'] && liveClassResponse['price'] > 0) {
        final paymentResponse = await _supabase
            .from('payments')
            .select('id, status')
            .eq('student_id', studentId)
            .eq('live_class_id', liveClassId)
            .eq('status', 'completed')
            .maybeSingle();

        if (paymentResponse == null) {
          return {
            'hasAccess': false,
            'reason': 'Payment required',
            'requiresPayment': true,
            'liveClass': liveClassResponse,
          };
        }
      }

      return {
        'hasAccess': true,
        'liveClass': liveClassResponse,
        'enrollment': enrollmentResponse,
      };
    } catch (e) {
      debugPrint("❌ Error verifying live class access: $e");
      return {
        'hasAccess': false,
        'reason': 'Failed to verify access: $e',
      };
    }
  }

  // ENHANCED: Join live class with comprehensive security
  static Future<void> joinLiveClass({
    required String liveClassId,
    required Map<String, dynamic> liveClassData,
    String? serverUrl,
    JitsiMeetEventListener? listener,
  }) async {
    try {
      final hasPermissions = await requestPermissions();
      if (!hasPermissions) {
        throw Exception("Camera and microphone permissions are required");
      }

      if (!_isInitialized) {
        await initialize();
      }

      final user = _supabase.auth.currentUser!;
      final userProfile = await _supabase.from('user_profiles').select('first_name, last_name, avatar_url').eq('id', user.id).single();
      final displayName = '${userProfile['first_name']} ${userProfile['last_name']}'.trim();
      final roomName = "brainboosters-live-$liveClassId";

      final options = JitsiMeetConferenceOptions(
          serverURL: serverUrl ?? "https://meet.jit.si",
          room: roomName,
          configOverrides: {
            "startWithAudioMuted": true, "startWithVideoMuted": true, "subject": "Brain Boosters: ${liveClassData['title']}", "requireDisplayName": true, "enableWelcomePage": false, "enableClosePage": false,
            "toolbarButtons": ['microphone','camera','hangup','chat','raisehand','tileview','shortcuts','help',],
            "disableDeepLinking": true, "disableInviteFunctions": true,
          },
          featureFlags: {
            "unsaferoomwarning.enabled": false, "prejoinpage.enabled": true, "chat.enabled": liveClassData['chat_enabled'] ?? true, "recording.enabled": false, "livestreaming.enabled": false,
            "screen-sharing.enabled": false, "raise-hand.enabled": true, "reactions.enabled": true, "tile-view.enabled": true, "invite.enabled": false,
          },
          userInfo: JitsiMeetUserInfo(displayName: displayName, email: user.email ?? '', avatar: userProfile['avatar_url']));

      await _trackAttendanceStart(liveClassId);

      // FIXED: Pass the listener from the UI directly to the join method
      await _jitsiMeet.join(options, listener);
      
      debugPrint("✅ Successfully joined live class: $liveClassId");
    } catch (e) {
      debugPrint("❌ Failed to join live class: $e");
      throw Exception("Failed to join live class: ${e.toString()}");
    }
  }

  
  // ANALYTICS: Track attendance and engagement
  static Future<void> _trackAttendanceStart(String liveClassId) async {
    try {
      final user = _supabase.auth.currentUser!;
      final studentResponse = await _supabase
          .from('students')
          .select('id')
          .eq('user_id', user.id)
          .single();

      await _supabase.from('live_class_enrollments').update({
        'attended': true,
        'attendance_duration': 0, // Will be updated on leave
      }).eq('student_id', studentResponse['id']).eq('live_class_id', liveClassId);

      // Track analytics event
      await _supabase.from('analytics_events').insert({
        'user_id': user.id,
        'event_type': 'live_class_joined',
        'event_category': 'engagement',
        'event_action': 'join_live_class',
        'properties': {
          'live_class_id': liveClassId,
          'timestamp': DateTime.now().toIso8601String(),
        },
      });
    } catch (e) {
      debugPrint("⚠️ Failed to track attendance: $e");
    }
  }

  // BUSINESS LOGIC: Enroll in live class with payment verification
  static Future<Map<String, dynamic>> enrollInLiveClass(String liveClassId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'Authentication required',
          'requiresLogin': true,
        };
      }

      // Get live class details
      final liveClassResponse = await _supabase
          .from('live_classes')
          .select('id, title, price, is_free, max_participants, current_participants')
          .eq('id', liveClassId)
          .single();

      // Check capacity
      if (liveClassResponse['current_participants'] >= liveClassResponse['max_participants']) {
        return {
          'success': false,
          'message': 'Live class is full',
        };
      }

      final studentResponse = await _supabase
          .from('students')
          .select('id')
          .eq('user_id', user.id)
          .single();

      final studentId = studentResponse['id'];

      // Check if already enrolled
      final existingEnrollment = await _supabase
          .from('live_class_enrollments')
          .select('id')
          .eq('student_id', studentId)
          .eq('live_class_id', liveClassId)
          .maybeSingle();

      if (existingEnrollment != null) {
        return {
          'success': false,
          'message': 'Already enrolled in this live class',
        };
      }

      // Handle payment for paid classes
      if (!liveClassResponse['is_free'] && liveClassResponse['price'] > 0) {
        // Check if payment exists
        final paymentResponse = await _supabase
            .from('payments')
            .select('id, status')
            .eq('student_id', studentId)
            .eq('live_class_id', liveClassId)
            .eq('status', 'completed')
            .maybeSingle();

        if (paymentResponse == null) {
          return {
            'success': false,
            'message': 'Payment required',
            'requiresPayment': true,
            'amount': liveClassResponse['price'],
          };
        }
      }

      // Enroll student
      await _supabase.from('live_class_enrollments').insert({
        'student_id': studentId,
        'live_class_id': liveClassId,
        'enrolled_at': DateTime.now().toIso8601String(),
      });

      // Update participant count using a database function
      await _supabase.rpc('increment_live_class_participants', params: {
        'p_live_class_id': liveClassId, // Ensure param name matches your function
      });

      return {
        'success': true,
        'message': 'Successfully enrolled in live class',
      };
    } catch (e) {
      debugPrint("❌ Error enrolling in live class: $e");
      return {
        'success': false,
        'message': 'Failed to enroll: $e',
      };
    }
  }

   static Future<void> leaveMeeting() async {
    try {
      await _jitsiMeet.hangUp();
      debugPrint("✅ Left meeting successfully");
    } catch (e) {
      debugPrint("❌ Error leaving meeting: $e");
    }
  }

  
}