// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Course _$CourseFromJson(Map<String, dynamic> json) => Course(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      weekDays:
          (json['week_days'] as List<dynamic>).map((e) => e as String).toList(),
      lessonPerMonth: (json['lesson_per_month'] as num).toInt(),
      cost: (json['cost'] as num).toDouble(),
    );

Map<String, dynamic> _$CourseToJson(Course instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'week_days': instance.weekDays,
      'lesson_per_month': instance.lessonPerMonth,
      'cost': instance.cost,
    };
