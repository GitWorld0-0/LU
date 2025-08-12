import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';  // Add firebase_auth package to pubspec.yaml
import '../user.dart'; // Ensure this file exists
// Adjust import to your actual user screen

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String? _selectedDepartment;
  final List<String> _departments = [
    'Computer Science & Engineering (CSE)',
    'Electrical & Electronic Engineering (EEE)',
    'Civil Engineering (CE)',
    'Architecture',
    'Business Administration (BBA)',
    'English',
    'Law',
    'Public Health',
    'Tourism & Hospitality Management',
    'Bangla',
    'Islamic Studies',
  ];

  // Add controllers to capture input
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  void dispose() {
    // Dispose controllers
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
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
                    height: 280,
                    width: MediaQuery.of(context).size.width * 0.8,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Form(
                    key: _formKey,  // Add Form key here
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 30),
                        Image.asset('assets/lu.png', height: 90, width: 95),
                        const SizedBox(height: 10),

                        // Full Name
                        _buildTextField(
                          controller: _fullNameController,
                          hintText: 'Enter Full Name',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Full Name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),

                        // Email
                        _buildTextField(
                          controller: _emailController,
                          hintText: 'Email Address',
                          inputType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email is required';
                            }
                            // Basic email validation
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),

                        // Department Dropdown
                        _buildDropdown(),

                        const SizedBox(height: 10),

                        // Phone Number
                        _buildTextField(
                          controller: _phoneController,
                          hintText: 'Phone Number',
                          inputType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Phone Number is required';
                            }
                            if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(value)) {
                              return 'Enter a valid phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),

                        // Password
                        _buildTextField(
                          controller: _passwordController,
                          hintText: 'Set Password',
                          obscure: true,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Password is required';
                            }
                            if (value.trim().length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),

                        // Confirm Password
                        _buildTextField(
                          controller: _confirmPasswordController,
                          hintText: 'Confirm Password',
                          obscure: true,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 40),

                        _isLoading
                            ? const CircularProgressIndicator()
                            : _buildRegisterButton(),

                        const SizedBox(height: 20),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? inputType,
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          fontSize: 13,
          color: Color.fromRGBO(86, 82, 82, 0.7),
          fontFamily: 'inter',
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: const Color.fromRGBO(173, 238, 217, 0.55),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(173, 238, 217, 0.58),
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: const Text(
            'Department',
            style: TextStyle(
              fontSize: 13,
              color: Color.fromRGBO(86, 82, 82, 0.7),
              fontFamily: 'inter',
              fontWeight: FontWeight.w600,
            ),
          ),
          value: _selectedDepartment,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
          onChanged: (String? newValue) {
            setState(() {
              _selectedDepartment = newValue;
            });
          },
          items: _departments.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          dropdownColor: const Color.fromRGBO(173, 238, 217, 1),
          style: const TextStyle(
            fontSize: 13,
            color: Color.fromRGBO(86, 82, 82, 0.7),
            fontFamily: 'inter',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: 130,
      child: ElevatedButton(
        onPressed: _register,
        style: ElevatedButton.styleFrom(
          elevation: 2,
          backgroundColor: const Color.fromRGBO(173, 238, 217, 0.95),
          foregroundColor: const Color.fromRGBO(86, 82, 82, 0.7),
          textStyle: const TextStyle(
            fontSize: 14,
            fontFamily: 'instrumentsans',
            fontWeight: FontWeight.w500,
          ),
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.0),
          ),
        ),
        child: const Text('Register'),
      ),
    );
  }

  Future<void> _register() async {
  if (!_formKey.currentState!.validate()) {
    return; // form is invalid
  }
  if (_selectedDepartment == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select a department')),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    // Create user with email and password
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    // Update user display name
    await userCredential.user?.updateDisplayName(_fullNameController.text.trim());

    // Optional: save extra user info like phone & department to Firestore
    // import 'package:cloud_firestore/cloud_firestore.dart';
    //
    // await FirebaseFirestore.instance
    //   .collection('users')
    //   .doc(userCredential.user!.uid)
    //   .set({
    //     'fullName': _fullNameController.text.trim(),
    //     'email': _emailController.text.trim(),
    //     'phone': _phoneController.text.trim(),
    //     'department': _selectedDepartment,
    //   });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registration successful!')),
    );

    // Navigate to your UserScreen or Home screen
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const UserScreen()));

  } on FirebaseAuthException catch (e) {
    String message = 'Registration failed';
    if (e.code == 'email-already-in-use') {
      message = 'Email is already registered.';
    } else if (e.code == 'weak-password') {
      message = 'Password is too weak.';
    } else if (e.code == 'invalid-email') {
      message = 'Invalid email address.';
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}

}
