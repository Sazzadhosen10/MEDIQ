import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main_screen.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  String fullName = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  String phoneNumber = '';
  int age = 0;
  String gender = 'Male';
  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (password != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Passwords do not match")),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'fullName': fullName,
          'email': email,
          'phoneNumber': phoneNumber,
          'age': age,
          'gender': gender,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration successful")),
        );

        await Future.delayed(const Duration(seconds: 1));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainScreen()),
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Registration error')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Text(
                'Sign Up',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              TextFormField(
                decoration: _inputDecoration('Full Name'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter your full name'
                    : null,
                onSaved: (value) => fullName = value!.trim(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: _inputDecoration('Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter your email'
                    : null,
                onSaved: (value) => email = value!.trim(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: _inputDecoration('Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please enter a password';
                  if (value.length < 6)
                    return 'Password must be at least 6 characters';
                  return null;
                },
                onSaved: (value) => password = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: _inputDecoration('Confirm Password'),
                obscureText: true,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please confirm your password'
                    : null,
                onSaved: (value) => confirmPassword = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: _inputDecoration('Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter your phone number'
                    : null,
                onSaved: (value) => phoneNumber = value!.trim(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: _inputDecoration('Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please enter your age';
                  if (int.tryParse(value) == null)
                    return 'Please enter a valid number';
                  return null;
                },
                onSaved: (value) => age = int.parse(value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: _inputDecoration('Gender'),
                value: gender,
                items: const ['Male', 'Female', 'Other']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (value) => setState(() => gender = value!),
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade900,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Register',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
