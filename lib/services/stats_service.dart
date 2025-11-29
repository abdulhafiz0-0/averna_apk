import '../core/api_client.dart';
import '../models/stats_overview.dart';

class StatsService {
  final ApiClient _apiClient;

  StatsService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<StatsOverview> getStats() async {
    final response = await _apiClient.get('/stats/');
    return StatsOverview.fromJson(response.data as Map<String, dynamic>);
  }
}
