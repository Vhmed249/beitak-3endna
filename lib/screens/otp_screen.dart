import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/constants.dart';
import 'home_screen.dart';

class OTPScreen extends StatefulWidget {
  final String phone;
  final String verificationId;
  const OTPScreen({
    super.key,
    required this.phone,
    required this.verificationId,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'أدخل رمز التحقق',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'تم إرسال رمز إلى ${widget.phone}',
              style: const TextStyle(fontSize: 16, color: AppColors.textDark),
            ),
            const SizedBox(height: 30),
            TextFormField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              textDirection: TextDirection.ltr,
              maxLength: 6,
              decoration: InputDecoration(
                hintText: 'XXXXXX',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.background,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: _isLoading ? null : _verifyOTP,
              child: _isLoading
                  ? const CircularProgressIndicator(color: AppColors.white)
                  : const Text(
                      'تحقق',
                      style: TextStyle(fontSize: 18, color: AppColors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verifyOTP() async {
    final code = _otpController.text.trim();

    if (code.length != 6 || int.tryParse(code) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل رمز تحقق صحيح مكون من 6 أرقام')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final provider = Provider.of<AppProvider>(context, listen: false);

      await provider.authService.verifyOTP(widget.verificationId, code);

      await provider.loadUserData();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رمز التحقق غير صحيح، حاول مرة أخرى')),
      );
    }
  }
}
