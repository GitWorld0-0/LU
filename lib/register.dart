// register.dart
import 'package:flutter/material.dart';
import '/OTP/reg_otp.dart'; // OTPScreen import

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

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
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
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 30),
                        Image.asset('assets/lu.png', height: 90, width: 95),
                        const SizedBox(height: 10),
                        _buildTextField(controller: _fullNameController, hintText: 'Full Name', validator: (v) => (v == null || v.isEmpty) ? 'Full Name is required' : null),
                        const SizedBox(height: 10),
                        _buildTextField(controller: _emailController, hintText: 'Email', inputType: TextInputType.emailAddress, validator: (v) {
                          if (v == null || v.isEmpty) return 'Email required';
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) return 'Enter valid email';
                          return null;
                        }),
                        const SizedBox(height: 10),
                        _buildDropdown(),
                        const SizedBox(height: 10),
                        _buildTextField(controller: _phoneController, hintText: 'Phone Number', inputType: TextInputType.phone, validator: (v) {
                          if (v == null || v.isEmpty) return 'Phone required';
                          if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(v)) return 'Enter valid number';
                          return null;
                        }),
                        const SizedBox(height: 10),
                        _buildTextField(controller: _passwordController, hintText: 'Password', obscure: true, validator: (v) {
                          if (v == null || v.isEmpty) return 'Password required';
                          if (v.length < 6) return 'Password must be 6+ chars';
                          return null;
                        }),
                        const SizedBox(height: 10),
                        _buildTextField(controller: _confirmPasswordController, hintText: 'Confirm Password', obscure: true, validator: (v) {
                          if (v != _passwordController.text) return 'Passwords do not match';
                          return null;
                        }),
                        const SizedBox(height: 40),
                        _isLoading ? const CircularProgressIndicator() : _buildRegisterButton(),
                        const SizedBox(height: 20),
                        Center(child: Text("“It's never too late to be what you might\nhave been.”", style: TextStyle(fontSize: 13, color: Color.fromRGBO(0,0,0,0.5), fontFamily: 'instrumentsans', fontWeight: FontWeight.bold))),
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

  Widget _buildTextField({required TextEditingController controller, required String hintText, TextInputType? inputType, bool obscure = false, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(fontSize: 13, color: Color.fromRGBO(86, 82, 82, 0.7), fontFamily: 'inter', fontWeight: FontWeight.w600),
        filled: true,
        fillColor: const Color.fromRGBO(173, 238, 217, 0.55),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.0), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(color: const Color.fromRGBO(173, 238, 217, 0.58), borderRadius: BorderRadius.circular(14.0)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: const Text('Department', style: TextStyle(fontSize: 13, color: Color.fromRGBO(86, 82, 82, 0.7), fontFamily: 'inter', fontWeight: FontWeight.w600)),
          value: _selectedDepartment,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
          onChanged: (String? newValue) => setState(() => _selectedDepartment = newValue),
          items: _departments.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          dropdownColor: const Color.fromRGBO(173, 238, 217, 1),
          style: const TextStyle(fontSize: 13, color: Color.fromRGBO(86, 82, 82, 0.7), fontFamily: 'inter', fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: 130,
      child: ElevatedButton(
        onPressed: _proceedToOTP,
        style: ElevatedButton.styleFrom(
          elevation: 2,
          backgroundColor: const Color.fromRGBO(173, 238, 217, 0.95),
          foregroundColor: const Color.fromRGBO(86, 82, 82, 0.7),
          textStyle: const TextStyle(fontSize: 14, fontFamily: 'instrumentsans', fontWeight: FontWeight.w500),
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
        ),
        child: const Text('Register'),
      ),
    );
  }

  void _proceedToOTP() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDepartment == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a department')));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OTPScreen(
          phoneNumber: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          fullName: _fullNameController.text.trim(),
          password: _passwordController.text.trim(),
          department: _selectedDepartment!,
        ),
      ),
    );
  }
}
