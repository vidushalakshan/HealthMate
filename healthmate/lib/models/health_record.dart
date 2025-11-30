class HealthRecord {
  final int? id;
  final String date;
  final int steps;
  final int calories;
  final int water;

  HealthRecord({
    this.id,
    required this.date,
    required this.steps,
    required this.calories,
    required this.water,
  });

  // Convert HealthRecord to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'steps': steps,
      'calories': calories,
      'water': water,
    };
  }

  // Create HealthRecord from Map
  factory HealthRecord.fromMap(Map<String, dynamic> map) {
    return HealthRecord(
      id: map['id'],
      date: map['date'],
      steps: map['steps'],
      calories: map['calories'],
      water: map['water'],
    );
  }

  // Create a copy with modified fields
  HealthRecord copyWith({
    int? id,
    String? date,
    int? steps,
    int? calories,
    int? water,
  }) {
    return HealthRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      steps: steps ?? this.steps,
      calories: calories ?? this.calories,
      water: water ?? this.water,
    );
  }

  @override
  String toString() {
    return 'HealthRecord{id: $id, date: $date, steps: $steps, calories: $calories, water: $water}';
  }
}