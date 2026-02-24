// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:js_util' as js_util;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:well_paw/core/config/app_config.dart';

class StripeWebController {
  dynamic _stripe;
  dynamic _elements;
  dynamic _card;
  bool _mounted = false;

  bool get isSupported => AppConfig.hasValidStripePublishableKey;

  Future<void> mount(String elementId) async {
    if (!isSupported || _mounted) {
      return;
    }

    await _ensureStripeLoaded();
    _stripe = js_util.callMethod(html.window, 'Stripe', [
      AppConfig.stripePublishableKey,
    ]);
    _elements = js_util.callMethod(_stripe, 'elements', []);
    _card = js_util.callMethod(_elements, 'create', ['card']);
    js_util.callMethod(_card, 'mount', ['#${elementId}']);
    _mounted = true;
  }

  Future<String?> createPaymentMethod() async {
    if (!isSupported || _stripe == null || _card == null) {
      return null;
    }
    final result = await js_util.promiseToFuture<dynamic>(
      js_util.callMethod(_stripe, 'createPaymentMethod', [
        js_util.jsify(<String, dynamic>{'type': 'card', 'card': _card}),
      ]),
    );
    final error = js_util.getProperty(result, 'error');
    if (error != null) {
      return null;
    }
    final paymentMethod = js_util.getProperty(result, 'paymentMethod');
    if (paymentMethod == null) {
      return null;
    }
    return js_util.getProperty(paymentMethod, 'id')?.toString();
  }

  Future<bool> confirmCardPayment({
    required String clientSecret,
    required String paymentMethodId,
  }) async {
    if (!isSupported || _stripe == null) {
      return false;
    }
    final result = await js_util.promiseToFuture<dynamic>(
      js_util.callMethod(_stripe, 'confirmCardPayment', [
        clientSecret,
        js_util.jsify(<String, dynamic>{'payment_method': paymentMethodId}),
      ]),
    );
    final error = js_util.getProperty(result, 'error');
    if (error != null) {
      return false;
    }
    final intent = js_util.getProperty(result, 'paymentIntent');
    final status = intent == null
        ? null
        : js_util.getProperty(intent, 'status');
    return status == 'succeeded';
  }

  Future<void> _ensureStripeLoaded() async {
    if (js_util.hasProperty(html.window, 'Stripe')) {
      return;
    }

    final completer = Completer<void>();
    final script = html.ScriptElement()
      ..src = 'https://js.stripe.com/v3/'
      ..async = true
      ..defer = true;

    script.onError.listen((_) {
      if (!completer.isCompleted) {
        completer.completeError(Exception('Stripe.js โหลดไม่สำเร็จ'));
      }
    });
    script.onLoad.listen((_) {
      if (!completer.isCompleted) {
        completer.complete();
      }
    });

    html.document.head?.append(script);
    await completer.future;
  }
}

class StripeCardField extends StatefulWidget {
  final StripeWebController controller;
  final double height;

  const StripeCardField({
    super.key,
    required this.controller,
    this.height = 48,
  });

  @override
  State<StripeCardField> createState() => _StripeCardFieldState();
}

class _StripeCardFieldState extends State<StripeCardField> {
  late final String _viewType;

  @override
  void initState() {
    super.initState();
    _viewType = 'stripe-card-${DateTime.now().microsecondsSinceEpoch}';
    ui.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final element = html.DivElement()
        ..id = _viewType
        ..style.height = '100%'
        ..style.width = '100%'
        ..style.padding = '12px'
        ..style.border = '1px solid #E0E0E0'
        ..style.borderRadius = '12px'
        ..style.backgroundColor = '#FFFFFF';
      widget.controller.mount(_viewType);
      return element;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: HtmlElementView(viewType: _viewType),
    );
  }
}
