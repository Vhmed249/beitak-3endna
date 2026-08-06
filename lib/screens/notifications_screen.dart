import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/constants.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: userId == null
          ? const Center(child: Text('يرجى تسجيل الدخول'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('notifications')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(child: Text('لا توجد إشعارات'));
                }
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (ctx, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: Icon(
                          data['type'] == 'message'
                              ? Icons.message
                              : Icons.notifications,
                          color: data['isRead'] == true
                              ? Colors.grey
                              : AppColors.primary,
                        ),
                        title: Text(data['title'] ?? 'إشعار جديد'),
                        subtitle: Text(data['body'] ?? ''),
                        trailing: data['isRead'] == true
                            ? null
                            : IconButton(
                                icon: const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                                onPressed: () =>
                                    _markAsRead(docs[index].id, userId),
                              ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Future<void> _markAsRead(String notificationId, String userId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }
}
