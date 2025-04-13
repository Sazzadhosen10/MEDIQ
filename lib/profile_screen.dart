import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _ageController;

  // Initialize controllers in initState
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _ageController = TextEditingController();
  }

  // Method to log out the user.
  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/');
  }

  // Method to save the profile updates.
  void _saveProfile(String fieldType) async {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && _formKey.currentState!.validate()) {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
      await userDoc.update({
        fieldType == 'Full Name'
            ? 'fullName'
            : fieldType == 'Phone Number'
                ? 'phoneNumber'
                : 'age': fieldType == 'Age'
            ? int.tryParse(_ageController.text) ?? 0
            : fieldType == 'Phone Number'
                ? _phoneController.text
                : _nameController.text,
      });
      Navigator.of(context).pop(); // Close dialog after saving
      setState(() {}); // Trigger a rebuild
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully!')));
    }
  }

  // Show a popup dialog to edit information
  void _showEditDialog(String fieldType) {
    // Set initial values in the controllers
    if (fieldType == 'Full Name') {
      _nameController.text =
          FirebaseAuth.instance.currentUser?.displayName ?? '';
    } else if (fieldType == 'Phone Number') {
      _phoneController.text =
          FirebaseAuth.instance.currentUser?.phoneNumber ?? '';
    } else if (fieldType == 'Age') {
      _ageController.text = '25'; // Set default value for age if needed
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $fieldType'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: fieldType == 'Full Name'
                      ? _nameController
                      : fieldType == 'Phone Number'
                          ? _phoneController
                          : _ageController,
                  decoration: InputDecoration(
                    labelText: 'Enter your $fieldType',
                  ),
                  keyboardType: fieldType == 'Phone Number'
                      ? TextInputType.phone
                      : fieldType == 'Age'
                          ? TextInputType.number
                          : TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a valid $fieldType';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog without saving
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _saveProfile(fieldType); // Save profile and close dialog
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('No user is logged in.')),
      );
    }

    final DocumentReference userDoc =
        FirebaseFirestore.instance.collection('users').doc(uid);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade900,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: userDoc.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Profile data not found.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          _nameController = TextEditingController(text: data['fullName'] ?? '');
          _phoneController =
              TextEditingController(text: data['phoneNumber'] ?? '');
          _ageController =
              TextEditingController(text: data['age']?.toString() ?? '');

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                // Display Full Name with edit icon
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Full Name'),
                  subtitle: Text(data['fullName'] ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showEditDialog('Full Name'),
                  ),
                ),
                const SizedBox(height: 16),

                // Display Email (Non-editable)
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Email'),
                  subtitle: Text(data['email'] ?? ''),
                ),
                const SizedBox(height: 16),

                // Display Age with edit icon
                ListTile(
                  leading: const Icon(Icons.cake),
                  title: const Text('Age'),
                  subtitle: Text('${data['age'] ?? ''}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showEditDialog('Age'),
                  ),
                ),
                const SizedBox(height: 16),

                // Display Phone Number with edit icon
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text('Phone Number'),
                  subtitle: Text(data['phoneNumber'] ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showEditDialog('Phone Number'),
                  ),
                ),
                const SizedBox(height: 16),

                // Log Out Button
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () => _logout(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text("Log Out",
                              style: TextStyle(color: Colors.white)),
                          SizedBox(width: 8),
                          Icon(Icons.logout, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
