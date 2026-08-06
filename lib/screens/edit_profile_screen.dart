import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/constants.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  File? _profileImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AppProvider>(context, listen: false).currentUser;
    if (user != null) {
      _nameController.text = user.name;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _profileImage = File(picked.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('الاسم مطلوب')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      String? imageUrl;
      if (_profileImage != null) {
        final ref = FirebaseStorage.instance.ref().child(
          'profile_images/${user.uid}.jpg',
        );
        await ref.putFile(_profileImage!);
        imageUrl = await ref.getDownloadURL();
      }

      Map<String, dynamic> updateData = {'name': _nameController.text.trim()};
      if (imageUrl != null) {
        updateData['profileImage'] = imageUrl;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update(updateData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ تم تحديث الملف الشخصي بنجاح'),
          backgroundColor: AppColors.secondary,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ فشل التحديث: $e')));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تعديل الملف الشخصي'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // صورة الملف الشخصي
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : null,
                child: _profileImage == null
                    ? Icon(Icons.camera_alt, size: 40, color: AppColors.primary)
                    : null,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'اضغط لتغيير الصورة',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 20),
            // حقل الاسم
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'الاسم الكامل',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.background,
              ),
            ),
            SizedBox(height: 30),
            // زر الحفظ
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: _isLoading ? null : _saveProfile,
              child: _isLoading
                  ? CircularProgressIndicator(color: AppColors.white)
                  : Text(
                      'حفظ التغييرات',
                      style: TextStyle(color: AppColors.white, fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
