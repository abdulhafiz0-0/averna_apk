// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendanceRecord _$AttendanceRecordFromJson(Map<String, dynamic> json) =>
    AttendanceRecord(
      date: json['date'] as String,
      courseId: (json['course_id'] as num).toInt(),
      isAbsent: json['isAbsent'] as bool,
      reason: json['reason'] as String?,
      chargeMoney: json['charge_money'] as bool?,
    );

Map<String, dynamic> _$AttendanceRecordToJson(AttendanceRecord instance) =>
    <String, dynamic>{
      'date': instance.date,
      'course_id': instance.courseId,
      'isAbsent': instance.isAbsent,
      'reason': instance.reason,
      'charge_money': instance.chargeMoney,
    };
