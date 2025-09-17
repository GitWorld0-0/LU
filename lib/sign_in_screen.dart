import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lu_new/user.dart';
import 'register.dart';
import '/pass/forgetpassword.dart';

class SignInScreen extends StatefulWidget {//stateful widget used for dynamic purposes
  const SignInScreen({super.key});//key → tells Flutter "this widget is the same as before, just update it". super.key → passes the key to the parent (StatefulWidget) so Flutter can track it. It’s not mandatory, but highly recommended for good performance.

  @override
  State<SignInScreen> createState() => _SignInScreenState();//creating state object under signinscreen
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();//_formKey is a unique key for your Form widget.GlobalKey<FormState> lets you validate the form fields or access form state from anywhere in the widget.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signIn() async {//A Future is a way to handle values that will be available later
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Navigate to user screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserScreen()),
        );
      } on FirebaseAuthException catch (e) {
        String message = 'Login failed';
        if (e.code == 'user-not-found') {
          message = 'No user found for this email.';
        } else if (e.code == 'wrong-password') {
          message = 'Incorrect password.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {//defines the UI of the screen.
    return GestureDetector(//hides keyboard on tap outside.
      onTap: () => FocusScope.of(context).unfocus(),//dismiss the keyboard when tapping anywhere outside input fields.
      child: Scaffold(//main screen structure.
        resizeToAvoidBottomInset: false,//prevents screen from resizing when keyboard shows.
        body: Container(//holds  actual content.
          decoration: const BoxDecoration(//Property of a Container how the container should look
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
               Color.fromRGBO(194, 227, 207, 1),
               Color.fromRGBO(140, 238, 173, 0.9),
              ],
            ),
          ),
          child: Stack(//child and children property but stack is widget
            children: [
              Center(
                child: Opacity(
                  opacity: 0.2,
                  child: Image.asset(
                    'assets/lu.png',
                    width: MediaQuery.of(context).size.width * 0.8,//full screen width. multiply .8
                    height: 280,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SingleChildScrollView(//A widget that allows its child to scroll
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),//a constant padding object with 30px on the left and right.
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 50),//creating box
                        Image.asset('assets/lu.png', height: 90, width: 95),
                        const SizedBox(height: 10),

                        // Email / Student ID
                        TextFormField(
                          controller: _emailController,
                          decoration: _inputDecoration('Email'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            final emailRegEx = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                            if (!emailRegEx.hasMatch(value)) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),

                        // Password
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true, // Set to true to hide password input
                          decoration: _inputDecoration('Enter Password'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgetPasswordScreen()),
                            );
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color.fromRGBO(86, 82, 82, 0.7),
                              fontFamily: 'inter',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                        const SizedBox(height: 23),

                        // Sign In Button
                        SizedBox(
                          width: 180,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _signIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromRGBO(173, 238, 217, 0.68),
                              padding: const EdgeInsets.symmetric(vertical: 15.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    'Sign in',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color.fromRGBO(86, 82, 82, 0.7),
                                      fontFamily: 'instrumentsans',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 170),
                        const Text(
                          "Don't have an account?",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color.fromRGBO(86, 82, 82, 0.7),
                            fontFamily: 'inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 130,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const RegisterScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 2,
                              backgroundColor: const Color.fromRGBO(173, 238, 217, 0.95),
                              padding: const EdgeInsets.symmetric(vertical: 15.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                            ),
                            child: const Text(
                              'Register',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color.fromRGBO(86, 82, 82, 0.7),
                                fontFamily: 'instrumentsans',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 55),
                        const Text(
                          "“It's never too late to be what you might\nhave been.”",
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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
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
      contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
    );
  }
}
