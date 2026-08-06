import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/constants.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  File? _idImage;
  File? _propertyDocument;
  bool _isLoading = false;

  Future<void> _pickImage(String type) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        if (type == 'id')
          _idImage = File(picked.path);
        else
          _propertyDocument = File(picked.path);
      });
    }
  }

  Future<void> _submitVerification() async {
    if (_idImage == null || _propertyDocument == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى رفع جميع المستندات المطلوبة')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final storage = FirebaseStorage.instance;

      final idRef = storage.ref().child('verification/${user.uid}/id.jpg');
      await idRef.putFile(_idImage!);
      final idUrl = await idRef.getDownloadURL();

      final docRef = storage.ref().child(
        'verification/${user.uid}/property.jpg',
      );
      await docRef.putFile(_propertyDocument!);
      final docUrl = await docRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('verification')
          .add({
            'idImage': idUrl,
            'propertyDocument': docUrl,
            'status': 'pending',
            'createdAt': FieldValue.serverTimestamp(),
          });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ تم إرسال طلب التحقق بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ فشل الإرسال: $e')));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('التحقق من الهوية'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildImagePicker(
              'صورة البطاقة الشخصية',
              _idImage,
              () => _pickImage('id'),
            ),
            SizedBox(height: 20),
            _buildImagePicker(
              'وثيقة الملكية',
              _propertyDocument,
              () => _pickImage('property'),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: _isLoading ? null : _submitVerification,
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text('إرسال الطلب'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker(String label, File? image, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(image, fit: BoxFit.cover),
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload, size: 40, color: Colors.grey[400]),
                    SizedBox(height: 8),
                    Text(label, style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
      ),
    );
  }
}
