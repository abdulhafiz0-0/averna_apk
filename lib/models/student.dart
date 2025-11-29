import 'package:json_annotation/json_annotation.dart';
import 'attendance_record.dart';

part 'student.g.dart';

@JsonSerializable()
class Student {
  final int id;
  final String name;
  final String surname;
  @JsonKey(name: 'second_name')
  final String? secondName;
  @JsonKey(name: 'starting_date')
  final String startingDate;
  @JsonKey(name: 'num_lesson')
  final int? numLesson;
  @JsonKey(name: 'total_money')
  final double? totalMoney;
  final List<int> courses;
  final List<AttendanceRecord>? attendance;

  Student({
    required this.id,
    required this.name,
    required this.surname,
    this.secondName,
    required this.startingDate,
    this.numLesson,
    this.totalMoney,
    required this.courses,
    this.attendance,
  });

  factory Student.fromJson(Map<String, dynamic> json) =>
      _$StudentFromJson(json);

  Map<String, dynamic> toJson() => _$StudentToJson(this);

  String get fullName => '$name $surname${secondName != null ? ' $secondName' : ''}';
}
