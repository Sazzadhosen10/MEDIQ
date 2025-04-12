class MedicationReminder {
  final String id;
  final String userId;
  final String name;
  final String dosage;
  final int hour;
  final int minute;
  final bool isActive;

  MedicationReminder({
    required this.id,
    required this.userId,
    required this.name,
    required this.dosage,
    required this.hour,
    required this.minute,
    required this.isActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
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
      userId: map['userId'] ?? '',
      name: map['name'],
      dosage: map['dosage'],
      hour: map['hour'],
      minute: map['minute'],
      isActive: map['isActive'] == 1,
    );
  }
}
