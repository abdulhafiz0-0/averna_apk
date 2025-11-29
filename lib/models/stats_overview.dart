import 'package:json_annotation/json_annotation.dart';

part 'stats_overview.g.dart';

@JsonSerializable()
class StatsOverview {
  @JsonKey(name: 'total_money')
  final double totalMoney;
  @JsonKey(name: 'monthly_money')
  final double monthlyMoney;
  final double unpaid;
  @JsonKey(name: 'monthly_unpaid')
  final double monthlyUnpaid;
  @JsonKey(name: 'total_students')
  final int totalStudents;

  StatsOverview({
    required this.totalMoney,
    required this.monthlyMoney,
    required this.unpaid,
    required this.monthlyUnpaid,
    required this.totalStudents,
  });

  factory StatsOverview.fromJson(Map<String, dynamic> json) =>
      _$StatsOverviewFromJson(json);

  Map<String, dynamic> toJson() => _$StatsOverviewToJson(this);
}
