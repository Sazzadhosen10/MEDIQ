import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mediq/main_screen.dart'; 
import 'homepage.dart';
import 'registration_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  void _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        // Navigate to the Homepage if login is successful.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) =>   MainScreen()),
        );
      } on FirebaseAuthException catch (e) {
        // Display error message.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Login error')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
         padding: const EdgeInsets.all(16.0),
         child: Form(
           key: _formKey,
           child: Column(
             children: [
               TextFormField(
                 decoration: const InputDecoration(labelText: 'Email'),
                 keyboardType: TextInputType.emailAddress,
                 validator: (value) {
                   if (value == null || value.isEmpty) return 'Please enter your email';
                   return null;
                 },
                 onSaved: (value) => email = value!.trim(),
               ),
               TextFormField(
                 decoration: const InputDecoration(labelText: 'Password'),
                 obscureText: true,
                 validator: (value) {
                   if (value == null || value.isEmpty) return 'Please enter your password';
                   return null;
                 },
                 onSaved: (value) => password = value!,
               ),
               const SizedBox(height: 20),
               ElevatedButton(
                 onPressed: _login,
                 child: const Text('Login'),
               ),
               TextButton(
                 onPressed: () {
                   // Navigate to the Registration Page.
                   Navigator.push(
                     context,
                     MaterialPageRoute(builder: (_) => const RegistrationPage()),
                   );
                 },
                 child: const Text('Don\'t have an account? Register here'),
               ),
             ],
           ),
         ),
      ),
    );
  }
}
