import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'env_config.dart';
import 'student_auth_service.dart';
import 'subscription_service.dart';

/// Razorpay Payment Service for Zerno Pro/Ultra subscriptions
///
/// --- Supabase SQL (run in SQL Editor) ---
/// CREATE TABLE IF NOT EXISTS razorpay_payments (
///   id bigserial PRIMARY KEY,
///   student_id text NOT NULL,
///   student_name text,
///   order_id text,
///   payment_id text,
///   signature text,
///   amount int NOT NULL,
///   plan text NOT NULL,
///   billing_period text DEFAULT 'monthly',
///   status text DEFAULT 'created',
///   created_at timestamp DEFAULT now(),
///   verified_at timestamp
/// );
///
/// ALTER TABLE razorpay_payments ENABLE ROW LEVEL SECURITY;
/// CREATE POLICY "Public all" ON razorpay_payments FOR ALL USING (true) WITH CHECK (true);
/// ---
class RazorpayService {
  static final _supabase = Supabase.instance.client;

  /// Get Razorpay key ID from .env
  static String get keyId => EnvConfig.razorpayKeyId;

  /// Check if Razorpay is configured
  static bool get isConfigured => EnvConfig.hasRazorpayKeys;

  /// Create a payment order for a given plan
  /// Returns checkout options map for razorpay_flutter
  static Map<String, dynamic> createCheckoutOptions({
    required SubscriptionTier plan,
    bool yearly = false,
  }) {
    final student = StudentAuthService.currentStudent;
    final amount = yearly ? plan.yearlyAmount : plan.monthlyAmount;
    final period = yearly ? 'yearly' : 'monthly';

    return {
      'key': keyId,
      'amount': amount * 100, // Razorpay uses paise (₹199 = 19900 paise)
      'name': 'Zerno',
      'description': '${plan.displayName} Plan ($period)',
      'prefill': {
        'contact': '',
        'email': '',
        'name': student?.name ?? '',
      },
      'theme': {
        'color': '#6C63FF',
      },
      'notes': {
        'student_id': student?.id?.toString() ?? '',
        'plan': plan.displayName.toLowerCase(),
        'billing_period': period,
      },
    };
  }

  /// Record successful payment in Supabase
  static Future<bool> recordPayment({
    required String paymentId,
    required String orderId,
    required String signature,
    required SubscriptionTier plan,
    bool yearly = false,
  }) async {
    try {
      final student = StudentAuthService.currentStudent;
      if (student == null) return false;

      final amount = yearly ? plan.yearlyAmount : plan.monthlyAmount;

      // 1. Record the payment
      await _supabase.from('razorpay_payments').insert({
        'student_id': student.id.toString(),
        'student_name': student.name,
        'order_id': orderId,
        'payment_id': paymentId,
        'signature': signature,
        'amount': amount,
        'plan': plan.displayName.toLowerCase(),
        'billing_period': yearly ? 'yearly' : 'monthly',
        'status': 'paid',
        'verified_at': DateTime.now().toIso8601String(),
      });

      // 2. Upgrade student's subscription tier
      await _supabase
          .from('students')
          .update({
            'subscription_tier': plan.displayName.toLowerCase(),
            'subscription_active': true,
          })
          .eq('id', student.id!);

      // 3. Refresh the local student data
      await StudentAuthService.refreshCurrentStudent();

      debugPrint('✅ Razorpay payment recorded: $paymentId → ${plan.displayName}');
      return true;
    } catch (e) {
      debugPrint('⚠️ Record payment error: $e');
      return false;
    }
  }

  /// Record failed payment
  static Future<void> recordFailedPayment({
    required String errorCode,
    required String errorDescription,
    required SubscriptionTier plan,
  }) async {
    try {
      final student = StudentAuthService.currentStudent;
      if (student == null) return;

      await _supabase.from('razorpay_payments').insert({
        'student_id': student.id.toString(),
        'student_name': student.name,
        'amount': plan.monthlyAmount,
        'plan': plan.displayName.toLowerCase(),
        'status': 'failed',
      });

      debugPrint('⚠️ Razorpay payment failed: $errorCode - $errorDescription');
    } catch (e) {
      debugPrint('⚠️ Record failed payment error: $e');
    }
  }

  /// Get payment history for current student
  static Future<List<Map<String, dynamic>>> getPaymentHistory() async {
    try {
      final student = StudentAuthService.currentStudent;
      if (student == null) return [];

      final data = await _supabase
          .from('razorpay_payments')
          .select()
          .eq('student_id', student.id.toString())
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('⚠️ Get payment history error: $e');
      return [];
    }
  }
}
