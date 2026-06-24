import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_project/features/auth/data/auth_service.dart';
import 'package:flutter_project/core/models/user_profile.dart';

/// Offline-first user profile for UI layers that expect a `Map`.
/// Serves directly from Firestore cache since persistence is enabled.
final userDataProvider = StreamProvider.autoDispose
    .family<Map<String, dynamic>?, String>((ref, uid) {
  final firestore = ref.watch(firestoreProvider);
  return firestore.collection('users').doc(uid).snapshots().map((snapshot) {
    if (!snapshot.exists || snapshot.data() == null) return null;
    
    final rawData = snapshot.data()!;
    final profile = UserProfile.fromFirestore(snapshot);
    
    return {
      ...profile.toUserDataMap(),
      'profileImage': rawData['profileImage'] ?? rawData['profilePhotoUrl'] ?? rawData['avatarUrl'],
      'profilePhotoUrl': rawData['profilePhotoUrl'] ?? rawData['profileImage'] ?? rawData['avatarUrl'],
    };
  });
});