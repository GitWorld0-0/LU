import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';  // ✅ add this
import '../pass/confirm_password.dart';

class OTPScreen extends StatefulWidget {
  final String phoneNumber;
  final String? email;     // ✅ extra fields to save
  final String? username;

  const OTPScreen({
    super.key,
    required this.phoneNumber,
    required String verificationId,
    this.email,
    this.username,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  late List<TextEditingController> controllers;
  late List<FocusNode> focusNodes;
  String? _errorMessage;
  bool _isLoading = false;
  String? _verificationId;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(6, (_) => TextEditingController());
    focusNodes = List.generate(6, (_) => FocusNode());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNodes[0].requestFocus();
    });

    _sendOTP(); 
  }

  @override
  void dispose() {
    for (var c in controllers) c.dispose();
    for (var f in focusNodes) f.dispose();
    super.dispose();
  }

  bool get _isOTPComplete => controllers.every((c) => c.text.isNotEmpty);

  Future<void> _sendOTP() async {
    setState(() => _isLoading = false);

    FirebaseAuth auth = FirebaseAuth.instance;

    try {
      await auth.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Optional: auto sign-in
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _isLoading = false;
            _errorMessage = e.message ?? 'OTP sending failed';
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _isLoading = false;
            _verificationId = verificationId;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'OTP sending failed: $e';
      });
    }
  }

  Future<void> _verifyOTP() async {
    if (_verificationId == null) return;

    String otp = controllers.map((c) => c.text).join();
    if (otp.length != 6) {
      setState(() => _errorMessage = 'Please enter 6-digit OTP.');
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

      UserCredential userCred =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // ✅ Save to Firestore
      if (userCred.user != null) {
        await FirebaseFirestore.instance.collection("users").add({
          "uid": userCred.user!.uid,
          "username": widget.username ?? "",
          "email": widget.email ?? "",
          "phone": widget.phoneNumber,
          "createdAt": FieldValue.serverTimestamp(),
        });
      }

      setState(() => _isLoading = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ConfirmPasswordScreen(phoneNumber: widget.phoneNumber),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message ?? 'OTP verification failed';
      });
    }
  }

  // Build OTP input fields
  Widget _buildOTPFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 45,
          height: 55,
          child: TextField(
            controller: controllers[index],
            focusNode: focusNodes[index],
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
              if (value.isNotEmpty) {
                if (index < 5) {
                  focusNodes[index + 1].requestFocus();
                } else {
                  focusNodes[index].unfocus();
                }
              } else if (value.isEmpty && index > 0) {
                focusNodes[index - 1].requestFocus();
              }
            },
          ),
        );
      }),
    );
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
                    Center(
                      child: Image.asset('assets/lu.png', height: 90, width: 95),
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: Text(
                        "Enter OTP sent to ${widget.phoneNumber}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(86, 82, 82, 0.7),
                          fontFamily: 'inter',
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildOTPFields(),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    const SizedBox(height: 20),
                    Center(
                      child: SizedBox(
                        width: 130,
                        child: ElevatedButton(
                          onPressed:
                              (!_isOTPComplete || _isLoading) ? null : _verifyOTP,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromRGBO(173, 238, 217, 0.95),
                            padding: const EdgeInsets.symmetric(vertical: 15.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.0),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
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
                        textAlign: TextAlign.center,
                        style: const TextStyle(
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
