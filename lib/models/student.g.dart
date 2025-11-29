// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Student _$StudentFromJson(Map<String, dynamic> json) => Student(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      surname: json['surname'] as String,
      secondName: json['second_name'] as String?,
      startingDate: json['starting_date'] as String,
      numLesson: (json['num_lesson'] as num?)?.toInt(),
      totalMoney: (json['total_money'] as num?)?.toDouble(),
      courses: (json['courses'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      attendance: (json['attendance'] as List<dynamic>?)
          ?.map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$StudentToJson(Student instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'surname': instance.surname,
      'second_name': instance.secondName,
      'starting_date': instance.startingDate,
      'num_lesson': instance.numLesson,
      'total_money': instance.totalMoney,
      'courses': instance.courses,
      'attendance': instance.attendance,
    };
