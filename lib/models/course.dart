import 'package:json_annotation/json_annotation.dart';

part 'course.g.dart';

@JsonSerializable()
class Course {
  final int id;
  final String name;
  @JsonKey(name: 'week_days')
  final List<String> weekDays;
  @JsonKey(name: 'lesson_per_month')
  final int lessonPerMonth;
  final double cost;

  Course({
    required this.id,
    required this.name,
    required this.weekDays,
    required this.lessonPerMonth,
    required this.cost,
  });

  factory Course.fromJson(Map<String, dynamic> json) =>
      _$CourseFromJson(json);

  Map<String, dynamic> toJson() => _$CourseToJson(this);
}
