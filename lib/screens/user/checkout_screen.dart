import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../utils/theme.dart';
import '../../utils/constants.dart';
import '../../widgets/widgets.dart';
import '../../models/models.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override State<CheckoutScreen> createState() => _CheckoutState();
}

class _CheckoutState extends State<CheckoutScreen> {
  final _addrC  = TextEditingController();
  final _notesC = TextEditingController();
  String _payMethod = AppConf.paymentMethods.first;
  bool   _placing   = false;

  @override void initState() {
    super.initState();
    final st = context.read<AppState>();
    _addrC.text = st.user?.address ?? '';
  }

  @override void dispose() { _addrC.dispose(); _notesC.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(title: const Text('Checkout',
        style: TextStyle(fontWeight: FontWeight.w800))),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // Order summary
        const Text('Order Summary', style: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w700, color: C.text)),
        const SizedBox(height: 10),
        ...st.cart.map((c) => _orderRow(c)),
        const SizedBox(height: 8),
        // Total
        DCard(child: Row(children: [
          const Text('Total', style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w800, color: C.text)),
          const Spacer(),
          PriceText(st.cartTotal, fontSize: 18),
        ])),

        const SizedBox(height: 20),
        const Text('Delivery Address', style: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w700, color: C.text)),
        const SizedBox(height: 10),
        TextFormField(
          controller: _addrC,
          maxLines: 2,
          style: const TextStyle(color: C.text),
          decoration: const InputDecoration(
            labelText: 'Full delivery address',
            prefixIcon: Icon(Icons.location_on_outlined, color: C.text2))),

        const SizedBox(height: 16),
        const Text('Payment Method', style: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w700, color: C.text)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8,
          children: AppConf.paymentMethods.map((m) {
            final sel = _payMethod == m;
            return GestureDetector(
              onTap: () => setState(() => _payMethod = m),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  gradient: sel ? C.brandGrad : null,
                  color:    sel ? null : C.card2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: sel ? C.orange : C.border,
                    width: sel ? 1.5 : 1)),
                child: Text(m, style: TextStyle(
                  fontSize: 12, fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                  color: sel ? Colors.white : C.text2))));
          }).toList()),

        const SizedBox(height: 16),
        TextFormField(
          controller: _notesC,
          maxLines: 2,
          style: const TextStyle(color: C.text),
          decoration: const InputDecoration(
            labelText: 'Order notes (optional)',
            prefixIcon: Icon(Icons.note_outlined, color: C.text2))),

        const SizedBox(height: 28),
        GradBtnFull(
          label: 'Place Order',
          icon: Icons.check_circle_outline,
          busy: _placing,
          onTap: () => _placeOrder(context, st)),
        const SizedBox(height: 40),
      ]),
    );
  }

  Widget _orderRow(CartItem c) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: C.card,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: C.border)),
    child: Row(children: [
      ClipRRect(borderRadius: BorderRadius.circular(8),
        child: PImage(c.product.imageUrl, width: 50, height: 50)),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(c.product.name, style: const TextStyle(
          color: C.text, fontSize: 12, fontWeight: FontWeight.w600),
          maxLines: 1, overflow: TextOverflow.ellipsis),
        Text('x${c.qty}', style: const TextStyle(color: C.text2, fontSize: 11)),
      ])),
      PriceText(c.subtotal, fontSize: 13),
    ]));

  Future<void> _placeOrder(BuildContext ctx, AppState st) async {
    if (_addrC.text.trim().isEmpty) {
      toast(ctx, 'Please enter delivery address', color: C.red); return;
    }
    setState(() => _placing = true);
    try {
      final order = await st.placeOrder(
        deliveryAddress: _addrC.text.trim(),
        paymentMethod:   _payMethod,
        notes:           _notesC.text.trim());
      if (ctx.mounted) {
        _showSuccess(ctx, order);
      }
    } catch (e) {
      if (ctx.mounted) toast(ctx, 'Error: $e', color: C.red);
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  void _showSuccess(BuildContext ctx, AppOrder order) =>
    showDialog(context: ctx, barrierDismissible: false, builder: (_) => AlertDialog(
      backgroundColor: C.card,
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('🎉', style: TextStyle(fontSize: 60)),
        const SizedBox(height: 12),
        const Text('Order Placed!', style: TextStyle(
          fontSize: 22, fontWeight: FontWeight.w800, color: C.text)),
        const SizedBox(height: 8),
        Text('Order #${order.id.substring(0,8).toUpperCase()}',
          style: const TextStyle(color: C.orange, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text('Total: ${PriceText.fmtPrice(order.total)}',
          style: const TextStyle(color: C.text2, fontSize: 14)),
        const SizedBox(height: 6),
        const Text('A WhatsApp confirmation will be sent shortly.',
          style: TextStyle(color: C.text2, fontSize: 12),
          textAlign: TextAlign.center),
        const SizedBox(height: 20),
        GradBtnFull(label: 'Done', onTap: () {
          Navigator.popUntil(ctx, (r) => r.isFirst);
        }),
      ]),
    ));
}
