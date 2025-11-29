import 'package:json_annotation/json_annotation.dart';

part 'attendance_record.g.dart';

@JsonSerializable()
class AttendanceRecord {
  final String date;
  @JsonKey(name: 'course_id')
  final int courseId;
  final bool isAbsent;
  final String? reason;
  @JsonKey(name: 'charge_money')
  final bool? chargeMoney;

  AttendanceRecord({
    required this.date,
    required this.courseId,
    required this.isAbsent,
    this.reason,
    this.chargeMoney,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) =>
      _$AttendanceRecordFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceRecordToJson(this);
}
