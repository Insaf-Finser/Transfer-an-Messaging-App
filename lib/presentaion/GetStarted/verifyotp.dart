// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:transfer/presentaion/menu/menu.dart';
import '../../../services/auth/auth.dart';

class VerifyOtpPage extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const VerifyOtpPage({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  String _otp = '';
  bool _isLoading = false;
  String? _errorText;

  void _verifyOtp() async {
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    if (_otp.length != 6) {
      setState(() {
        _errorText = "Please enter a 6-digit OTP.";
        _isLoading = false;
      });
      return;
    }

    try {
      AuthResult result = await AuthService().verifyOTP(
        verificationId: widget.verificationId,
        smsCode: _otp,
      );

      if (result.success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MenuPage()),
        );
      } else {
        setState(() {
          _errorText = "Invalid OTP. Please try again.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorText = "Verification failed. Please try again.";
        _isLoading = false;
      });
    }
  }

  void _resendOtp() async {
    // OPTIONAL: Implement actual resend logic via Firebase or your backend
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP resent to your phone number.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Enter the 6-digit OTP sent to ${widget.phoneNumber}',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PinCodeTextField(
              length: 6,
              appContext: context,
              keyboardType: TextInputType.number,
              animationType: AnimationType.fade,
              onChanged: (value) => _otp = value,
              onCompleted: (value) => _otp = value,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(8),
                fieldHeight: 50,
                fieldWidth: 40,
                activeFillColor: Colors.white,
                selectedFillColor: Colors.white,
                inactiveFillColor: Colors.grey[200],
                activeColor: Colors.blue,
                selectedColor: Colors.blue,
                inactiveColor: Colors.grey,
              ),
              cursorColor: Colors.black,
              enableActiveFill: true,
              errorTextSpace: 20,
            ),
            if (_errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _errorText!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyOtp,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Verify'),
              ),
            ),
            TextButton(
              onPressed: _isLoading ? null : _resendOtp,
              child: const Text('Resend OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
