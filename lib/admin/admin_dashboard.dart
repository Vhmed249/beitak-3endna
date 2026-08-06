import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/property_model.dart';
import '../utils/constants.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
  }

  Future<void> _checkAdminAccess() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) {
          Navigator.pop(context);
        }
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists || doc.data()?['isAdmin'] != true) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ليس لديك صلاحيات المشرف')),
          );
        }
        return;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في التحقق من الصلاحيات: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          PendingPropertiesList(),
          UsersManagement(),
          StatisticsDashboard(),
          FeaturedManagement(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.pending_actions
            ),
            label: 'المعلقة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'المستخدمين',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'الإحصائيات',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'المميزة'),
        ],
      ),
    );
  }
}

class PendingPropertiesList extends StatelessWidget {
  const PendingPropertiesList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('properties')
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(child: Text('لا توجد إعلانات معلقة'));
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final property = Property.fromMap(docs[index].id, data);

            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text(property.title),
                subtitle: Text('${property.city} - ${property.price} ج.س'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('properties')
                            .doc(docs[index].id)
                            .update({'status': 'approved', 'isVerified': true});
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('properties')
                            .doc(docs[index].id)
                            .update({'status': 'rejected'});
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class UsersManagement extends StatelessWidget {
  const UsersManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text(data['name'] ?? 'مستخدم'),
                subtitle: Text(data['phone'] ?? ''),
                trailing: IconButton(
                  icon: Icon(
                    data['isBlocked'] == true ? Icons.block : Icons.person,
                    color: data['isBlocked'] == true
                        ? Colors.red
                        : Colors.green,
                  ),
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(docs[index].id)
                        .update({'isBlocked': !(data['isBlocked'] ?? false)});
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class StatisticsDashboard extends StatelessWidget {
  const StatisticsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        FirebaseFirestore.instance.collection('properties').count().get(),
        FirebaseFirestore.instance.collection('users').count().get(),
        FirebaseFirestore.instance
            .collection('properties')
            .where('status', isEqualTo: 'pending')
            .count()
            .get(),
        FirebaseFirestore.instance
            .collection('properties')
            .where('isFeatured', isEqualTo: true)
            .count()
            .get(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data as List<AggregateQuerySnapshot>;

        return GridView.count(
          padding: const EdgeInsets.all(16),
          crossAxisCount: 2,
          children: [
            _card('العقارات', data[0].count.toString()),
            _card('المستخدمين', data[1].count.toString()),
            _card('المعلقة', data[2].count.toString()),
            _card('المميزة', data[3].count.toString()),
          ],
        );
      },
    );
  }

  Widget _card(String title, String value) {
    return Card(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            Text(title),
          ],
        ),
      ),
    );
  }
}

class FeaturedManagement extends StatelessWidget {
  const FeaturedManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('properties')
          .where('status', isEqualTo: 'approved')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final property = Property.fromMap(
              docs[index].id,
              docs[index].data() as Map<String, dynamic>,
            );

            return Card(
              child: SwitchListTile(
                title: Text(property.title),
                subtitle: Text('${property.price} ج.س'),
                value: property.isFeatured,
                onChanged: (value) async {
                  await FirebaseFirestore.instance
                      .collection('properties')
                      .doc(docs[index].id)
                      .update({'isFeatured': value});
                },
              ),
            );
          },
        );
      },
    );
  }
}
