// File: lib/services/mpesa_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class MpesaService {
  // Daraja API Credentials (Sandbox)
  static const String consumerKey = "YOUR_CONSUMER_KEY";
  static const String consumerSecret = "YOUR_CONSUMER_SECRET";
  static const String passkey = "YOUR_PASSKEY";
  static const String shortCode = "174379";
  static const String baseUrl = "https://sandbox.safaricom.co.ke";

  // Get OAuth Token
  static Future<String> getAccessToken() async {
    try {
      final credentials = base64Encode(
        utf8.encode('$consumerKey:$consumerSecret'),
      );

      final response = await http.get(
        Uri.parse('$baseUrl/oauth/v1/generate?grant_type=client_credentials'),
        headers: {
          'Authorization': 'Basic $credentials',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['access_token'];
      }
      throw Exception('Failed to get access token');
    } catch (e) {
      print('Error getting token: $e');
      // Return simulated token for development
      return 'simulated_token_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  // STK Push Simulation
  static Future<Map<String, dynamic>> simulateSTKPush({
    required String phoneNumber,
    required double amount,
    required String accountReference,
    required String transactionDesc,
  }) async {
    // Simulate M-Pesa STK Push
    await Future.delayed(const Duration(seconds: 2));

    final isSuccess = Random().nextBool();
    final checkoutRequestID = 'ws_CO_${DateTime.now().millisecondsSinceEpoch}';

    if (isSuccess) {
      return {
        'success': true,
        'CheckoutRequestID': checkoutRequestID,
        'ResponseCode': '0',
        'ResponseDescription': 'Success. Request accepted for processing',
        'CustomerMessage': 'Success. Request accepted for processing',
        'MerchantRequestID': '92602-${DateTime.now().millisecondsSinceEpoch}',
      };
    } else {
      return {
        'success': false,
        'CheckoutRequestID': checkoutRequestID,
        'ResponseCode': '1',
        'ResponseDescription': 'Failed. Transaction declined',
        'CustomerMessage': 'Transaction declined. Please try again',
      };
    }
  }

  // Simulate M-Pesa Payment Confirmation
  static Future<Map<String, dynamic>> simulatePaymentConfirmation({
    required String checkoutRequestID,
  }) async {
    await Future.delayed(const Duration(seconds: 3));

    final mpesaCode =
        'SIM${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    return {
      'success': true,
      'ResultCode': '0',
      'ResultDesc': 'The service request is processed successfully',
      'MpesaReceiptNumber': mpesaCode,
      'TransactionDate': DateFormat('yyyyMMddHHmmss').format(DateTime.now()),
      'PhoneNumber': '254712345678',
      'Amount': 1000,
    };
  }

  // Simulate B2C Payment
  static Future<Map<String, dynamic>> simulateB2CPayment({
    required String phoneNumber,
    required double amount,
    required String occasion,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    return {
      'success': true,
      'ConversationID': 'AG_${DateTime.now().millisecondsSinceEpoch}',
      'OriginatorConversationID':
          'OC_${DateTime.now().millisecondsSinceEpoch}',
      'ResponseCode': '0',
      'ResponseDescription': 'Accept the service request successfully.',
    };
  }
}