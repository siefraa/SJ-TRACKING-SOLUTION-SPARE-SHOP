import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../utils/theme.dart';
import '../../utils/constants.dart';
import '../../widgets/widgets.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        title: Text('Cart  (${st.cartCount} items)',
          style: const TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          if (st.cart.isNotEmpty)
            TextButton(
              onPressed: () => _confirmClear(context, st),
              child: const Text('Clear', style: TextStyle(color: C.red))),
        ],
      ),
      body: st.cart.isEmpty
        ? _emptyState(context)
        : Column(children: [
            Expanded(child: ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: st.cart.length,
              itemBuilder: (_, i) => _cartItem(context, st, i))),
            _summary(context, st),
          ]),
    );
  }

  Widget _emptyState(BuildContext ctx) => Center(child: Column(
    mainAxisSize: MainAxisSize.min, children: [
    Icon(Icons.shopping_cart_outlined,
      color: C.orange.withOpacity(.3), size: 80),
    const SizedBox(height: 16),
    const Text('Your cart is empty',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: C.text2)),
    const SizedBox(height: 8),
    GestureDetector(
      onTap: () => Navigator.pop(ctx),
      child: const Text('Browse parts →',
        style: TextStyle(color: C.orange, fontSize: 14))),
  ]));

  Widget _cartItem(BuildContext ctx, AppState st, int i) {
    final item = st.cart[i];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: C.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.border)),
      child: Row(children: [
        // Image
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: PImage(item.product.imageUrl, width: 70, height: 70)),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.product.name, style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w700, color: C.text),
            maxLines: 2),
          if (item.product.partNumber.isNotEmpty)
            Text('#${item.product.partNumber}',
              style: const TextStyle(color: C.text3, fontSize: 10.5)),
          const SizedBox(height: 6),
          Row(children: [
            PriceText(item.product.price, fontSize: 14),
            const Spacer(),
            // Qty row
            _qtyRow(ctx, st, item.product.id, item.qty),
          ]),
        ])),
      ]),
    );
  }

  Widget _qtyRow(BuildContext ctx, AppState st, String id, int qty) =>
    Row(children: [
      _qBtn(Icons.remove, () => st.updateQty(id, qty - 1)),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text('$qty', style: const TextStyle(
          fontSize: 15, fontWeight: FontWeight.w800, color: C.text))),
      _qBtn(Icons.add, () => st.updateQty(id, qty + 1)),
      const SizedBox(width: 8),
      GestureDetector(onTap: () => st.removeFromCart(id),
        child: Container(padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: C.red.withOpacity(.12),
            borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.delete_outline, size: 14, color: C.red))),
    ]);

  Widget _qBtn(IconData icon, VoidCallback fn) => GestureDetector(
    onTap: fn,
    child: Container(width: 28, height: 28,
      decoration: BoxDecoration(color: C.card2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: C.border)),
      child: Icon(icon, size: 14, color: C.text)));

  Widget _summary(BuildContext ctx, AppState st) => Container(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
    decoration: const BoxDecoration(
      color: C.bg2,
      border: Border(top: BorderSide(color: C.border))),
    child: Column(children: [
      _sumRow('Subtotal', st.cartTotal),
      _sumRow('Delivery', 0, note: 'Calculated at checkout'),
      const Divider(color: C.border),
      Row(children: [
        const Text('Total', style: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w800, color: C.text)),
        const Spacer(),
        PriceText(st.cartTotal, fontSize: 18),
      ]),
      const SizedBox(height: 14),
      GradBtnFull(
        label: 'Proceed to Checkout',
        icon: Icons.payment_outlined,
        onTap: () => Navigator.push(ctx,
          MaterialPageRoute(builder: (_) => const CheckoutScreen()))),
    ]));

  Widget _sumRow(String label, double val, {String? note}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(children: [
      Text(label, style: const TextStyle(color: C.text2, fontSize: 13)),
      if (note != null) ...[
        const SizedBox(width: 6),
        Text(note, style: const TextStyle(color: C.text3, fontSize: 11))],
      const Spacer(),
      Text(val > 0 ? PriceText.fmtPrice(val) : 'Free',
        style: TextStyle(
          color: val > 0 ? C.text : C.green,
          fontSize: 13, fontWeight: FontWeight.w600)),
    ]));

  Future<void> _confirmClear(BuildContext ctx, AppState st) async {
    final ok = await showDialog<bool>(context: ctx, builder: (_) => AlertDialog(
      backgroundColor: C.card,
      title: const Text('Clear Cart?', style: TextStyle(color: C.text)),
      content: const Text('All items will be removed.',
        style: TextStyle(color: C.text2)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Clear', style: TextStyle(color: C.red,
            fontWeight: FontWeight.w700))),
      ]));
    if (ok == true) st.clearCart();
  }
}
