import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../verification_successful_screen.dart';

class OTPScreen extends StatefulWidget {
  final String phoneNumber;
  final String email;
  final String fullName;
  final String password;
  final String department;

  const OTPScreen({
    super.key,
    required this.phoneNumber,
    required this.email,
    required this.fullName,
    required this.password,
    required this.department,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  late List<TextEditingController> controllers;
  String? _errorMessage;
  String? _verificationId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(6, (_) => TextEditingController());
    _sendOTP();
  }

  @override
  void dispose() {
    for (var c in controllers) c.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _onOTPVerified(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() => _errorMessage = e.message);
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() => _verificationId = verificationId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("OTP sent to ${widget.phoneNumber}")),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() => _verificationId = verificationId);
      },
    );
  }

  Future<void> _validateAndProceed() async {
    String otp = controllers.map((c) => c.text).join();
    if (otp.length < 6 || otp.contains(RegExp(r'\D'))) {
      setState(() => _errorMessage = 'Enter valid 6-digit OTP.');
      return;
    }
    if (_verificationId == null) {
      setState(() => _errorMessage = 'No verification ID. Try again.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      await _onOTPVerified(credential);
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = e.message ?? 'OTP verification failed.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _onOTPVerified(PhoneAuthCredential credential) async {
    setState(() => _isLoading = true);
    try {
      // Sign in with phone
      UserCredential phoneUser = await FirebaseAuth.instance.signInWithCredential(credential);

      // Create email/password account
      try {
        UserCredential emailUser = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: widget.email,
          password: widget.password,
        );

        // Update display name (non-blocking)
        emailUser.user?.updateDisplayName(widget.fullName);

        // Firestore write (non-blocking)
        FirebaseFirestore.instance
            .collection('users')
            .doc(emailUser.user?.uid)
            .set({
          'fullName': widget.fullName,
          'email': widget.email,
          'phoneNumber': widget.phoneNumber,
          'department': widget.department,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } on FirebaseAuthException catch (e) {
        // If email already exists, link phone to existing email account
        if (e.code == 'email-already-in-use') {
          await FirebaseAuth.instance.currentUser?.linkWithCredential(
            EmailAuthProvider.credential(
              email: widget.email,
              password: widget.password,
            ),
          );
        } else {
          throw e;
        }
      }

      // Navigate immediately after OTP verification
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => VerificationSuccessfulScreen(
              fullName: widget.fullName,
              email: widget.email,
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'OTP verification failed')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color.fromRGBO(194, 227, 207, 1),
                Color.fromRGBO(140, 238, 173, 0.9),
              ],
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Opacity(
                  opacity: 0.2,
                  child: Image.asset(
                    'assets/lu.png',
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: 280,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 50),
                    Center(child: Image.asset('assets/lu.png', height: 90, width: 95)),
                    const SizedBox(height: 30),
                    const Center(
                      child: Text(
                        "Enter OTP",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(86, 82, 82, 0.7),
                          fontFamily: 'inter',
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (index) {
                        return SizedBox(
                          width: 45,
                          height: 55,
                          child: TextField(
                            controller: controllers[index],
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'instrumentsans',
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: const Color.fromRGBO(173, 238, 217, 0.58),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty && index < 5) {
                                FocusScope.of(context).nextFocus();
                              } else if (value.isEmpty && index > 0) {
                                FocusScope.of(context).previousFocus();
                              }
                            },
                          ),
                        );
                      }),
                    ),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    const SizedBox(height: 20),
                    Center(
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              width: 130,
                              child: ElevatedButton(
                                onPressed: _validateAndProceed,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromRGBO(173, 238, 217, 0.95),
                                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
                                ),
                                child: const Text(
                                  'Verify OTP',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color.fromRGBO(86, 82, 82, 0.7),
                                    fontFamily: 'instrumentsans',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 50),
                    Center(
                      child: Text(
                        "“It's never too late to be what you might\nhave been.”",
                        style: TextStyle(
                          fontSize: 13,
                          color: Color.fromRGBO(0, 0, 0, 0.5),
                          fontWeight: FontWeight.bold,
                          fontFamily: 'instrumentsans',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
