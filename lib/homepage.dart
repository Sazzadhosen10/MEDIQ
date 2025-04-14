// homepage.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mediq/add_medication_screen.dart';
import 'DateTimeline.dart';
import 'database_helper.dart';
import 'medication_reminder_model.dart';
import 'notification_service.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  late NotificationService notificationService;
  final User? user = FirebaseAuth.instance.currentUser;
  final ScrollController _scrollController = ScrollController();

  final DateTime _startDate = DateTime.now().subtract(const Duration(days: 15));
  final DateTime _endDate = DateTime.now().add(const Duration(days: 15));
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    notificationService = NotificationService();
    _initializeNotifications();
    _selectedDate = DateTime.now();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
    });
  }

  void _scrollToSelectedDate() {
    final index = _selectedDate.difference(_startDate).inDays;
    const double itemWidth = 80;
    final double offset = (index * itemWidth).toDouble();

    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  Future<void> _initializeNotifications() async {
    await notificationService.initialize();
    await _scheduleExistingNotifications();
  }

  Future<void> _scheduleExistingNotifications() async {
    await notificationService.cancelAllNotifications();
    if (user == null) return;

    final reminders = await dbHelper.getMedicationsByUser(user!.uid);
    for (var reminder in reminders) {
      if (reminder.isActive) {
        await notificationService.scheduleNotification(
          id: reminder.id.hashCode,
          title: 'Time for Medication',
          body: 'Take ${reminder.dosage} of ${reminder.name}',
          time: TimeOfDay(hour: reminder.hour, minute: reminder.minute),
        );
      }
    }
  }

  Future<void> _addMedication() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddMedicationScreen()),
    );

    if (result != null && user != null) {
      await dbHelper.insertMedication(result);
      await notificationService.scheduleNotification(
        id: result.id.hashCode,
        title: 'Time for Medication',
        body: 'Take ${result.dosage} of ${result.name}',
        time: TimeOfDay(hour: result.hour, minute: result.minute),
      );
      setState(() {});
    }
  }

  Future<void> _deleteMedication(String id) async {
    await dbHelper.deleteMedication(id);
    await notificationService.cancelNotification(id.hashCode);
    setState(() {});
  }

  Widget _buildMedicationsList() {
    if (user == null) {
      return const Center(child: Text('Please log in to view your reminders.'));
    }

    return FutureBuilder<List<MedicationReminder>>(
      future: dbHelper.getMedicationsByUser(user!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.notifications_off,
                    size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No medication reminders set',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final reminders = snapshot.data!;
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: reminders.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final reminder = reminders[index];
            return Dismissible(
              key: Key(reminder.id),
              background: Container(color: Colors.red),
              confirmDismiss: (direction) async {
                return await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm Delete'),
                    content: const Text(
                        'Are you sure you want to delete this reminder?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Delete',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
              onDismissed: (direction) => _deleteMedication(reminder.id),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(12),
                      child: const Icon(Icons.medication_outlined,
                          size: 30, color: Colors.blue),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reminder.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            reminder.dosage,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 4),
                          // Display the scheduled time.
                          Row(
                            children: [
                              const Icon(Icons.schedule,
                                  size: 16, color: Colors.blue),
                              const SizedBox(width: 4),
                              Text(
                                TimeOfDay(
                                        hour: reminder.hour,
                                        minute: reminder.minute)
                                    .format(context),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.blue.shade900,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Display the creation time.
                          Row(
                            children: [
                              const Icon(Icons.access_time,
                                  size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                'Saved: ${reminder.createdTime.toLocal().toString().substring(0, 16)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.redAccent),
                      onPressed: () => _deleteMedication(reminder.id),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'MEDIQ',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade900,
        iconTheme: const IconThemeData(color: Colors.transparent),
      ),
      body: Column(
        children: [
          DateTimeline(
            startDate: _startDate,
            endDate: _endDate,
            selectedDate: _selectedDate,
            onDateSelected: _onDateSelected,
            scrollController: _scrollController,
          ),
          const Divider(),
          Expanded(child: _buildMedicationsList()),
        ],
      ),
    );
  }
}
