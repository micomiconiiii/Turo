import 'package:flutter/material.dart';
import '../../services/otp_service.dart';
import '../../widgets/custom_button.dart';
import '../../core/app_export.dart';
import './id_verification.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final otpController = TextEditingController();
  late final otpService = OtpService();

 Future<void> _onVerifyPressed() async {
  final otp = otpController.text.trim();

  if (otp.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter your OTP')),
    );
    return;
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  // ✅ FIXED: Added 'await'
  final isValid = await otpService.verifyOtp(widget.email, otp);

  Navigator.pop(context);

  if (isValid) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP verified successfully!')),
    );
    Navigator.pushReplacement(
     context,
     MaterialPageRoute(
       builder: (context) => const IdUploadScreen(),
     ),
   );
    // TODO: Navigate to next registration step
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invalid or expired OTP')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('An OTP was sent to ${widget.email}'),
            const SizedBox(height: 16),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Enter OTP'),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Verify OTP',
              onPressed: _onVerifyPressed,
              backgroundColor: appTheme.blue_gray_700,
              textColor: Colors.white,),
          ],
        ),
      ),
    );
  }
}
