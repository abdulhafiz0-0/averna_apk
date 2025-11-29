import '../core/api_client.dart';
import '../models/payment.dart';

class PaymentService {
  final ApiClient _apiClient;

  PaymentService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<Payment>> getPayments({
    int? skip,
    int? limit,
    int? studentId,
  }) async {
    final queryParams = <String, dynamic>{};
    if (skip != null) queryParams['skip'] = skip;
    if (limit != null) queryParams['limit'] = limit;
    if (studentId != null) queryParams['student_id'] = studentId;

    final response = await _apiClient.get('/payments/', queryParameters: queryParams);

    if (response.data is List) {
      return (response.data as List)
          .map((json) => Payment.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<Payment> createPayment(Payment payment) async {
    final response = await _apiClient.post('/payments/', data: payment.toJson());
    return Payment.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Payment> updatePayment(int id, Payment payment) async {
    final response = await _apiClient.put('/payments/$id', data: payment.toJson());
    return Payment.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deletePayment(int id) async {
    await _apiClient.delete('/payments/$id');
  }
}
