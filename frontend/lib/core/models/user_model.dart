class UserModel {
  final String id;
  final String name;
  final String email;
  final bool premium;
  final DateTime trialStartDate;
  final DateTime trialEndDate;
  final String? selectedExamName;
  final int? selectedExamId;
  final DateTime? joinedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.premium,
    required this.trialStartDate,
    required this.trialEndDate,
    this.selectedExamName,
    this.selectedExamId,
    this.joinedAt,
  });

  factory UserModel.fromApiJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      premium: json['premium'] as bool? ?? false,
      trialStartDate: DateTime.parse(json['trial_start_date'] as String),
      trialEndDate: DateTime.parse(json['trial_end_date'] as String),
      selectedExamName: json['selected_exam_name'] as String?,
      selectedExamId: json['selected_exam_id'] as int?,
      joinedAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
    );
  }

  UserModel copyWith({String? selectedExamName, int? selectedExamId, bool? premium}) {
    return UserModel(
      id: id,
      name: name,
      email: email,
      premium: premium ?? this.premium,
      trialStartDate: trialStartDate,
      trialEndDate: trialEndDate,
      selectedExamName: selectedExamName ?? this.selectedExamName,
      selectedExamId: selectedExamId ?? this.selectedExamId,
      joinedAt: joinedAt,
    );
  }
}
