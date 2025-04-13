// add_medication_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'database_helper.dart';
import 'medication_reminder_model.dart';
import 'notification_service.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({Key? key}) : super(key: key);

  @override
  _AddMedicationScreenState createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();

  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  late NotificationService notificationService;

  @override
  void initState() {
    super.initState();
    notificationService = NotificationService();
    notificationService.initialize();
  }

  Future<void> _selectTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  Future<void> _saveReminder() async {
    if (_formKey.currentState!.validate()) {
      // Get current user's UID.
      final String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user logged in.')),
        );
        return;
      }

      // Create a new medication reminder with the userId.
      final newReminder = MedicationReminder(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: uid, // Associate reminder with the current user.
        name: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        hour: _selectedTime.hour,
        minute: _selectedTime.minute,
        isActive: true, createdTime: DateTime.now(), // Set to current time.
        // If your MedicationReminder model now includes a createdTime field,
        // uncomment the following line. Otherwise, remove it.
        // createdTime: DateTime.now(),
      );

      print('Starting _saveReminder with reminder: ${newReminder.toMap()}');

      // Insert the reminder into the database.
      try {
        await dbHelper.insertMedication(newReminder);
        print('Database insert successful.');
      } catch (dbError, dbStack) {
        print('Error inserting medication: $dbError');
        print('Database stack trace: $dbStack');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving to DB: $dbError')),
        );
        return; // Stop further execution if DB insertion fails.
      }

      // Schedule a notification for the medication reminder.
      try {
        await notificationService.scheduleNotification(
          id: newReminder.id.hashCode,
          title: 'Time for Medication',
          body: 'Take ${newReminder.dosage} of ${newReminder.name}',
          time: TimeOfDay(hour: newReminder.hour, minute: newReminder.minute),
        );
        debugPrint('Notification scheduling successful.');
      } catch (notifError, notifStack) {
        print('Error scheduling notification: $notifError');
        print('Notification stack trace: $notifStack');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error scheduling notification: $notifError')),
        );
        // Depending on your flow, you may choose to continue or return.
        // return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medication added successfully')),
      );

      // Optionally clear the form fields.
      _nameController.clear();
      _dosageController.clear();
      setState(() {
        _selectedTime = TimeOfDay.now();
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Add New Medication',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade900,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Medication Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    prefixIcon: const Icon(Icons.medication),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter medication name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _dosageController,
                  decoration: InputDecoration(
                    labelText: 'Dosage (e.g., 1 tablet)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    prefixIcon: const Icon(Icons.battery_charging_full),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter dosage information';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                Card(
                  color: Colors.white,
                  elevation: 0,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 16.0,
                    ),
                    leading: const Icon(Icons.access_time, size: 28),
                    title: const Text('Select Time',
                        style: TextStyle(fontSize: 16)),
                    subtitle: Text(
                      _selectedTime.format(context),
                      style: const TextStyle(fontSize: 18),
                    ),
                    trailing: const Icon(Icons.edit),
                    onTap: _selectTime,
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade900,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onPressed: _saveReminder,
                  child: const Text(
                    'Save Reminder',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
