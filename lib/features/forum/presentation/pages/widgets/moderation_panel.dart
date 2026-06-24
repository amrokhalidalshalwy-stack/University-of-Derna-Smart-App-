import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ModerationPanel extends StatelessWidget {
  const ModerationPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('لوحة الإشراف')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('moderation_queue')
                .where('status', isEqualTo: 'pending')
                .orderBy('createdAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error}'));
          }
          final items = snapshot.data?.docs ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('لا توجد طلبات إشراف معلقة.'));
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final data = item.data() as Map<String, dynamic>;
              return _buildModerationCard(context, item.id, data);
            },
          );
        },
      ),
    );
  }

  Widget _buildModerationCard(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) {
    final type = data['type'] == 'post' ? 'منشور' : 'تعليق';
    final createdAt = (data['createdAt'] as Timestamp).toDate();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(type),
                  backgroundColor:
                      data['type'] == 'post'
                          ? Colors.blue[100]
                          : Colors.green[100],
                ),
                Text(
                  DateFormat('yyyy/MM/dd HH:mm').format(createdAt),
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'سبب الإبلاغ: ${data['reason']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _handleAction(docId, 'rejected'),
                  child: const Text(
                    'رفض (حذف)',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _handleAction(docId, 'approved'),
                  child: const Text('موافقة (إبقاء)'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAction(String docId, String action) async {
    final db = FirebaseFirestore.instance;
    final modDoc = await db.collection('moderation_queue').doc(docId).get();
    final modData = modDoc.data()!;
    final entityId = modData['entityId'];
    final type = modData['type'];

    WriteBatch batch = db.batch();

    // تحديث حالة طلب الإشراف
    batch.update(db.collection('moderation_queue').doc(docId), {
      'status': 'completed',
      'actionTaken': action,
      'moderatedAt': FieldValue.serverTimestamp(),
      // 'moderatedByUid': current_user_uid,
    });

    // إذا تم الرفض، نقوم بحذف أو إخفاء المنشور/التعليق الأصلي
    if (action == 'rejected') {
      if (type == 'post') {
        batch.update(db.collection('forum_posts').doc(entityId), {
          'status': 'rejected',
        });
      } else {
        final postId = modData['postId'];
        batch.update(
          db
              .collection('forum_posts')
              .doc(postId)
              .collection('comments')
              .doc(entityId),
          {'status': 'rejected'},
        );
      }
    } else {
      // إذا تمت الموافقة، نضمن أن الحالة 'approved'
      if (type == 'post') {
        batch.update(db.collection('forum_posts').doc(entityId), {
          'status': 'approved',
        });
      } else {
        final postId = modData['postId'];
        batch.update(
          db
              .collection('forum_posts')
              .doc(postId)
              .collection('comments')
              .doc(entityId),
          {'status': 'approved'},
        );
      }
    }

    await batch.commit();
  }
}
