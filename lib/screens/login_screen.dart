import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/constants.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.home_work_outlined,
                  size: 70,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                AppConstants.appName,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontFamily: 'Tajawal',
                ),
              ),
              const Text(
                AppConstants.slogan,
                style: TextStyle(fontSize: 16, color: AppColors.textDark),
              ),
              const SizedBox(height: 50),
              const Text(
                'سجل الدخول برقم هاتفك',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                maxLength: 20,
                decoration: const InputDecoration(
                  hintText: 'مثال: 249123456789+',
                  prefixIcon: Icon(
                    Icons.phone_android,
                    color: AppColors.primary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: _isLoading ? null : _sendOTP,
                child: _isLoading
                    ? const CircularProgressIndicator(color: AppColors.white)
                    : const Text(
                        'إرسال رمز التحقق',
                        style: TextStyle(fontSize: 18, color: AppColors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _sendOTP() async {
    if (_phoneController.text.trim().replaceAll(' ', '').length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال رقم هاتف صحيح مع مفتاح الدولة')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final phone = _phoneController.text.trim().replaceAll(' ', '');
      await Provider.of<AppProvider>(
        context,
        listen: false,
      ).authService.sendOTP(phone, (verificationId) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPScreen(
              phone: _phoneController.text,
              verificationId: verificationId,
            ),
          ),
        );
      });
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e')),
        );
      }
    }
  }
}
