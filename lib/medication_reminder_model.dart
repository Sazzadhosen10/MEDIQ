class MedicationReminder {
  final String id;
  final String name;
  final String dosage;
  final int hour;
  final int minute;
  final bool isActive;

  MedicationReminder({
    required this.id,
    required this.name,
    required this.dosage,
    required this.hour,
    required this.minute,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'hour': hour,
      'minute': minute,
      'isActive': isActive ? 1 : 0,
    };
  }

  factory MedicationReminder.fromMap(Map<String, dynamic> map) {
    return MedicationReminder(
      id: map['id'],
      name: map['name'],
      dosage: map['dosage'],
      hour: map['hour'],
      minute: map['minute'],
      isActive: map['isActive'] == 1,
    );
  }
}