// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_overview.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StatsOverview _$StatsOverviewFromJson(Map<String, dynamic> json) =>
    StatsOverview(
      totalMoney: (json['total_money'] as num).toDouble(),
      monthlyMoney: (json['monthly_money'] as num).toDouble(),
      unpaid: (json['unpaid'] as num).toDouble(),
      monthlyUnpaid: (json['monthly_unpaid'] as num).toDouble(),
      totalStudents: (json['total_students'] as num).toInt(),
    );

Map<String, dynamic> _$StatsOverviewToJson(StatsOverview instance) =>
    <String, dynamic>{
      'total_money': instance.totalMoney,
      'monthly_money': instance.monthlyMoney,
      'unpaid': instance.unpaid,
      'monthly_unpaid': instance.monthlyUnpaid,
      'total_students': instance.totalStudents,
    };
