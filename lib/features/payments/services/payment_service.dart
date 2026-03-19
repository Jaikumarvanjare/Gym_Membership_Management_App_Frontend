import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';

class Payment {
  final int id;
  final int memberId;
  final String? memberName;
  final double amount;
  final String paymentMethod;
  final String paymentDate;

  const Payment({
    required this.id,
    required this.memberId,
    this.memberName,
    required this.amount,
    required this.paymentMethod,
    required this.paymentDate,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        id: json['id'] as int,
        memberId: json['member_id'] as int,
        memberName: json['member_name'] as String?,
        amount: double.parse(json['amount'].toString()),
        paymentMethod: json['payment_method'] as String,
        paymentDate: json['payment_date'] as String,
      );
}

class PaymentService {
  final Dio _dio = ApiClient.instance.dio;

  Future<Payment> createPayment({
    required int memberId,
    required double amount,
    required String paymentMethod,
  }) async {
    try {
      final res = await _dio.post('/payments', data: {
        'member_id': memberId,
        'amount': amount,
        'payment_method': paymentMethod,
      });
      return Payment.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error ?? ApiException('Failed to create payment');
    }
  }

  Future<List<Payment>> getAllPayments() async {
    try {
      final res = await _dio.get('/payments');
      final rawList = res.data['data'] as List<dynamic>;
      return rawList
          .map((e) => Payment.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error ?? ApiException('Failed to load payments');
    }
  }

  Future<List<Payment>> getPaymentsByMember(int memberId) async {
    try {
      final res = await _dio.get('/payments/$memberId');
      final rawList = res.data['data'] as List<dynamic>;
      return rawList
          .map((e) => Payment.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error ?? ApiException('Failed to load payment history');
    }
  }
}