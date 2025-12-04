import 'package:json_annotation/json_annotation.dart';

part 'payment.g.dart';

double _doubleFromJson(Object? value) {
  if (value == null) {
    return 0.0;
  }
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value) ?? 0.0;
  }
  return 0.0;
}

Object _doubleToJson(double value) => value;

int _intFromJson(Object? value) {
  if (value == null) {
    return 0;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value) ?? 0;
  }
  return 0;
}

Object _intToJson(int value) => value;

@JsonSerializable()
class Payment {
  final int? id;
  @JsonKey(name: 'student_id', fromJson: _intFromJson, toJson: _intToJson)
  final int studentId;
  @JsonKey(name: 'course_id', fromJson: _intFromJson, toJson: _intToJson)
  final int courseId;
  // Backend sends this field as `money`
  @JsonKey(name: 'money', fromJson: _doubleFromJson, toJson: _doubleToJson)
  final double amount;
  final String date;
  final String? description;
  @JsonKey(name: 'payment_method')
  final String? paymentMethod;

  Payment({
    this.id,
    required this.studentId,
    required this.courseId,
    required this.amount,
    required this.date,
    this.description,
    this.paymentMethod,
  });

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentToJson(this);
}
