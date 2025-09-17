import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'password_changed.dart'; // Make sure this import exists

class ConfirmPasswordScreen extends StatefulWidget {
  const ConfirmPasswordScreen({super.key, required String phoneNumber});

  @override
  State<ConfirmPasswordScreen> createState() => _ConfirmPasswordScreenState();
}

class _ConfirmPasswordScreenState extends State<ConfirmPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _sendPasswordReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final email = emailController.text.trim();

      // Send password reset email directly
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      setState(() => _isLoading = false);

      // Navigate to PasswordChangedScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PasswordChangedScreen(phoneNumber: '',),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message ?? "Failed to send password reset email";
      });
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
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),
                      Center(child: Image.asset('assets/lu.png', height: 90, width: 95)),
                      const SizedBox(height: 30),
                      const Text(
                        "Reset your password",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(86, 82, 82, 0.7),
                          fontFamily: 'inter',
                        ),
                      ),
                      const SizedBox(height: 20),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                hintText: 'Email associated with account',
                                filled: true,
                                fillColor: const Color.fromRGBO(173, 238, 217, 0.58),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14.0),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 15.0,
                                  horizontal: 20.0,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Enter your email';
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value))
                                  return 'Enter a valid email';
                                return null;
                              },
                            ),
                            if (_errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: Colors.red, fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: SizedBox(
                          width: 160,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _sendPasswordReset,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromRGBO(173, 238, 217, 0.95),
                              padding: const EdgeInsets.symmetric(vertical: 15.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    'Send Reset Email',
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
                      SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
