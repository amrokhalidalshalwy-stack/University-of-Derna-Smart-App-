// lib/core/services/notification_service.dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_project/core/services/error_tracking_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  late final FirebaseFirestore _firestore;
  late final FirebaseMessaging _firebaseMessaging;
  StreamSubscription? _messagingSub;

  NotificationService._internal()
      : _firestore = FirebaseFirestore.instance,
        _firebaseMessaging = FirebaseMessaging.instance;

  @visibleForTesting
  NotificationService.forTesting({required FirebaseFirestore firestore})
      : _firestore = firestore;

  factory NotificationService() {
    return _instance;
  }
  Future<void> sendEnrollmentStatusNotification({
    required String studentFcmToken,
    required String status,
    required String studentName,
    required String studentId,
    String? rejectionReason,
  }) async {
    try {
      String title;
      String body;

      if (status == 'approved') {
        title = 'تم قبول طلب تجديد القيد ✅';
        body = 'عزيزي $studentName، تم الموافقة على طلبك بنجاح';
      } else {
        title = 'طلب تجديد القيد مرفوض ❌';
        body =
            rejectionReason != null
                ? 'عزيزي $studentName، سبب الرفض: $rejectionReason'
                : 'عزيزي $studentName، تم رفض طلبك';
      }

      await _saveNotificationToFirestore(
        userId: studentId,
        title: title,
        body: body,
        type: 'enrollment_status',
      );

      await _sendPushNotification(
        token: studentFcmToken,
        title: title,
        body: body,
        data: {
          'type': 'enrollment_status',
          'status': status,
          'student_id': studentId,
        },
      );
    } catch (e, stackTrace) {
      ErrorTrackingService.recordError(
        e,
        stackTrace,
        context: 'Error sending enrollment notification',
      );
      rethrow;
    }
  }

  Future<void> sendAbsenceExcuseNotification({
    required String studentFcmToken,
    required String studentName,
    required String studentId,
    required String decision,
    required String courseName,
    String? rejectionReason,
  }) async {
    try {
      String title;
      String body;

      if (decision == 'approved') {
        title = 'تم قبول عذرك من الغياب ✅';
        body = 'عزيزي $studentName، تم قبول عذرك في مادة $courseName';
      } else {
        title = 'تم رفض طلب عذر الغياب ❌';
        body =
            rejectionReason != null
                ? 'عزيزي $studentName، سبب الرفض: $rejectionReason'
                : 'عزيزي $studentName، تم رفض طلبك في مادة $courseName';
      }

      await _saveNotificationToFirestore(
        userId: studentId,
        title: title,
        body: body,
        type: 'absence_excuse',
      );

      await _sendPushNotification(
        token: studentFcmToken,
        title: title,
        body: body,
        data: {
          'type': 'absence_excuse',
          'decision': decision,
          'student_id': studentId,
          'course_name': courseName,
        },
      );
    } catch (e, stackTrace) {
      ErrorTrackingService.recordError(
        e,
        stackTrace,
        context: 'Error sending absence excuse notification',
      );
      rethrow;
    }
  }

  Future<void> _saveNotificationToFirestore({
    required String userId,
    required String title,
    required String body,
    required String type,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .add({
            'userId': userId,
            'title': title,
            'body': body,
            'type': type,
            'category': type,
            'isRead': false,
            'is_read': false,
            'read': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
    } catch (e, stackTrace) {
      ErrorTrackingService.recordError(
        e,
        stackTrace,
        context: 'Error saving notification to Firestore',
      );
      rethrow;
    }
  }

  Future<void> _sendPushNotification({
    required String token,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    try {
      debugPrint('Push notification queued for token: $token');
      debugPrint('Title: $title');
      debugPrint('Body: $body');
    } catch (e, stackTrace) {
      ErrorTrackingService.recordError(
        e,
        stackTrace,
        context: 'Error sending push notification',
      );
      rethrow;
    }
  }

  Future<void> markAsRead(String userId, String notificationId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true, 'is_read': true, 'read': true});
    } catch (e, stackTrace) {
      ErrorTrackingService.recordError(
        e,
        stackTrace,
        context: 'Error marking notification as read',
      );
      rethrow;
    }
  }

  Stream<QuerySnapshot> getUnreadNotifications(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('is_read', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getAllNotifications(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> deleteNotification(String userId, String notificationId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .delete();
    } catch (e, stackTrace) {
      ErrorTrackingService.recordError(
        e,
        stackTrace,
        context: 'Error deleting notification',
      );
      rethrow;
    }
  }

  Future<void> initializeMessaging() async {
    try {
      await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      final token = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $token');

      _messagingSub = FirebaseMessaging.onMessage.listen((
        RemoteMessage message,
      ) async {
        final prefs = await SharedPreferences.getInstance();
        final isEnabled =
            prefs.getBool('settings_notifications_enabled') ?? true;

        if (!isEnabled) {
          debugPrint('Notifications disabled in settings. Ignoring.');
          return;
        }

        debugPrint('Foreground message received.');
        debugPrint('Message data: ${message.data}');

        if (message.notification != null) {
          debugPrint('Notification: ${message.notification}');
        }
      });

      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
    } catch (e, stackTrace) {
      ErrorTrackingService.recordError(
        e,
        stackTrace,
        context: 'Error initializing FCM',
      );
      rethrow;
    }
  }

  Future<String?> getFCMToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e, stackTrace) {
      ErrorTrackingService.recordError(
        e,
        stackTrace,
        context: 'Error getting FCM token',
      );
      return null;
    }
  }

  void dispose() {
    _messagingSub?.cancel();
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message: ${message.messageId}');
  debugPrint('Message data: ${message.data}');
}
