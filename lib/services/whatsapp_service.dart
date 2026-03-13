import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import '../utils/constants.dart';

// ══════════════════════════════════════════════════════════════
//  WhatsApp Service — sends messages via UltraMsg / Callmebot
//  webhook-compatible HTTP POST
// ══════════════════════════════════════════════════════════════

class WaConfig {
  final String apiUrl;
  final String token;
  final String shopPhone; // business WA number recipient
  WaConfig({required this.apiUrl, required this.token, required this.shopPhone});
}

class WhatsAppService {
  static WaConfig? _config;

  static void configure(WaConfig cfg) => _config = cfg;

  /// Send any text to a phone number
  static Future<bool> send(String phone, String message) async {
    if (_config == null) {
      _log('WA not configured');
      return false;
    }
    try {
      final resp = await http.post(
        Uri.parse(_config!.apiUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer ${_config!.token}',
        },
        body: {
          'token': _config!.token,
          'to':    phone.replaceAll('+', ''),
          'body':  message,
        },
      ).timeout(const Duration(seconds: 12));

      final ok = resp.statusCode >= 200 && resp.statusCode < 300;
      _log(ok ? '✅ WA sent to $phone' : '❌ WA failed ${resp.statusCode}: ${resp.body}');
      return ok;
    } catch (e) {
      _log('❌ WA error: $e');
      return false;
    }
  }

  // ── Templated messages ──────────────────────────────────────

  /// Notify customer their order was received
  static Future<bool> sendOrderConfirmation(AppOrder order) {
    final lines = order.items.map((i) =>
      '  • ${i.productName} x${i.qty}  ${_fmt(i.subtotal)}').join('\n');
    final msg = '''
🛒 *Order Confirmed — SJ Tracking Solution*

Order #${order.id.substring(0, 8).toUpperCase()}
----------------------------
$lines
----------------------------
💰 *Total: ${_fmt(order.total)}*
📦 Payment: ${order.paymentMethod}
🏠 Deliver to: ${order.deliveryAddress.isNotEmpty ? order.deliveryAddress : 'TBD'}

We will contact you shortly.
📞 ${AppConf.phone}
'''.trim();
    return send(order.userPhone, msg);
  }

  /// Notify customer of a status change
  static Future<bool> sendStatusUpdate(AppOrder order) {
    final emoji = switch (order.status) {
      'Confirmed'  => '✅',
      'Processing' => '🔧',
      'Shipped'    => '🚚',
      'Delivered'  => '🎉',
      'Cancelled'  => '❌',
      _            => '📋',
    };
    final msg = '''
$emoji *Order Update — SJ Tracking*

Order #${order.id.substring(0, 8).toUpperCase()}
Status: *${order.status}*
${order.trackingNumber.isNotEmpty ? 'Tracking: ${order.trackingNumber}' : ''}

Total: ${_fmt(order.total)}

Need help? ${AppConf.phone}
'''.trim();
    return send(order.userPhone, msg);
  }

  /// Alert admin of a new order (sent to shop number)
  static Future<bool> alertAdmin(AppOrder order) {
    if (_config == null) return Future.value(false);
    final lines = order.items.map((i) =>
      '• ${i.productName} x${i.qty} = ${_fmt(i.subtotal)}').join('\n');
    final msg = '''
🔔 *NEW ORDER — SJ Tracking*

From: ${order.userName.isNotEmpty ? order.userName : order.userPhone}
Phone: ${order.userPhone}
Items:
$lines
Total: *${_fmt(order.total)}*
Payment: ${order.paymentMethod}
Address: ${order.deliveryAddress}
Notes: ${order.notes.isNotEmpty ? order.notes : 'None'}
'''.trim();
    return send('+${_config!.shopPhone}', msg);
  }

  /// Promotional broadcast message
  static Future<bool> sendPromo(String phone, String productName,
      double price, String imageNote) {
    final msg = '''
🚗 *SJ Tracking Solution — Special Offer!*

🔥 ${productName}
💰 Now only ${_fmt(price)}

📲 Order now or visit our shop:
${AppConf.address}
📞 ${AppConf.phone}

_Reply STOP to unsubscribe_
'''.trim();
    return send(phone, msg);
  }

  static String _fmt(double v) =>
      'TSh ${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  static void _log(String msg) {
    // ignore: avoid_print
    print('[WhatsApp] $msg');
  }
}
