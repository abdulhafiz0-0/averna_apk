// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Payment _$PaymentFromJson(Map<String, dynamic> json) => Payment(
      id: (json['id'] as num?)?.toInt(),
      studentId: _intFromJson(json['student_id']),
      courseId: _intFromJson(json['course_id']),
  amount: _doubleFromJson(json['money']),
      date: json['date'] as String,
      description: json['description'] as String?,
      paymentMethod: json['payment_method'] as String?,
    );

Map<String, dynamic> _$PaymentToJson(Payment instance) => <String, dynamic>{
      'id': instance.id,
      'student_id': _intToJson(instance.studentId),
      'course_id': _intToJson(instance.courseId),
  'money': _doubleToJson(instance.amount),
      'date': instance.date,
      'description': instance.description,
      'payment_method': instance.paymentMethod,
    };
