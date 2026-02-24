import 'package:flutter/material.dart';

class StripeWebController {
  bool get isSupported => false;

  Future<void> mount(String elementId) async {}

  Future<String?> createPaymentMethod() async => null;

  Future<bool> confirmCardPayment({
    required String clientSecret,
    required String paymentMethodId,
  }) async {
    return false;
  }
}

class StripeCardField extends StatelessWidget {
  final StripeWebController controller;
  final double height;

  const StripeCardField({
    super.key,
    required this.controller,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: const Text('Stripe Elements รองรับเฉพาะ Web'),
    );
  }
}
