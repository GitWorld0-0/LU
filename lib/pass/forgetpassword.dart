import 'package:flutter/material.dart';
import '../OTP/OTP.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _storePhoneNumber() {
    if (!_formKey.currentState!.validate()) return;

    String phoneNumber = _phoneController.text.trim();

    // Navigate to OTP page and pass the phone number
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OTPScreen(
          phoneNumber: phoneNumber, verificationId: '',
        ),
      ),
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
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 50),
                        Center(
                          child: Image.asset(
                            'assets/lu.png',
                            height: 90,
                            width: 95,
                          ),
                        ),
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
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: 'Phone (+88...)',
                            filled: true,
                            fillColor: const Color.fromRGBO(173, 238, 217, 0.58),
                            hintStyle: const TextStyle(
                              fontSize: 13,
                              color: Color.fromRGBO(86, 82, 82, 0.7),
                              fontFamily: 'inter',
                              fontWeight: FontWeight.w600,
                            ),
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
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            if (!RegExp(r'^\+88\d{8,12}$').hasMatch(value)) {
                              return 'Phone number must start with +88 and be valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 25),
                        SizedBox(
                          width: 120,
                          child: ElevatedButton(
                            onPressed: _storePhoneNumber,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromRGBO(173, 238, 217, 0.95),
                              padding: const EdgeInsets.symmetric(vertical: 15.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                            ),
                            child: const Text(
                              'GO',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color.fromRGBO(86, 82, 82, 0.7),
                                fontFamily: 'instrumentsans',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 380),
                        const Text(
                          "“It's never too late to be what you might\nhave been.”",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Color.fromRGBO(0, 0, 0, 0.5),
                            fontWeight: FontWeight.bold,
                            fontFamily: 'instrumentsans',
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
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
