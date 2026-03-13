import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../utils/theme.dart';
import '../../utils/constants.dart';
import '../../widgets/widgets.dart';
import '../../models/models.dart';
import '../../services/whatsapp_service.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});
  @override State<AdminOrdersScreen> createState() => _AOState();
}

class _AOState extends State<AdminOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  static const _tabs_labels = ['All', 'Pending', 'Processing', 'Shipped', 'Delivered'];

  @override void initState() {
    super.initState();
    _tabs = TabController(length: _tabs_labels.length, vsync: this);
    _tabs.addListener(() => setState(() {}));
  }

  @override void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        title: Text('Orders (${st.allOrders.length})',
          style: const TextStyle(fontWeight: FontWeight.w800)),
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: C.orange,
          labelColor: C.orange,
          unselectedLabelColor: C.text2,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          tabs: _tabs_labels.map((t) => Tab(text: t)).toList()),
      ),
      body: TabBarView(
        controller: _tabs,
        children: _tabs_labels.map((filter) {
          var orders = st.allOrders
            ..sort((a,b) => b.createdAt.compareTo(a.createdAt));
          if (filter != 'All') {
            orders = orders.where((o) => o.status == filter).toList();
          }
          if (orders.isEmpty) return _empty(filter);
          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: orders.length,
            itemBuilder: (_, i) => _orderCard(context, st, orders[i]));
        }).toList()),
    );
  }

  Widget _empty(String filter) => Center(child: Column(
    mainAxisSize: MainAxisSize.min, children: [
    const Text('📦', style: TextStyle(fontSize: 60)),
    const SizedBox(height: 12),
    Text('No $filter orders', style: const TextStyle(
      color: C.text2, fontSize: 16, fontWeight: FontWeight.w600)),
  ]));

  Widget _orderCard(BuildContext ctx, AppState st, AppOrder o) =>
    GestureDetector(
      onTap: () => _showDetail(ctx, st, o),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: C.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: C.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('#${o.id.substring(0,8).toUpperCase()}',
                style: const TextStyle(color: C.orange,
                  fontWeight: FontWeight.w800, fontSize: 13)),
              const SizedBox(height: 2),
              Text(o.userName.isNotEmpty ? o.userName : o.userPhone,
                style: const TextStyle(color: C.text, fontSize: 13)),
              Text(o.userPhone, style: const TextStyle(color: C.text3, fontSize: 11)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              StatusChip(o.status),
              const SizedBox(height: 4),
              Text(PriceText.fmtPrice(o.total), style: const TextStyle(
                color: C.text, fontWeight: FontWeight.w800, fontSize: 13)),
            ]),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            // Item thumbnails
            ...o.items.take(4).map((i) => Container(
              margin: const EdgeInsets.only(right: 5),
              child: ClipRRect(borderRadius: BorderRadius.circular(6),
                child: PImage(i.imageUrl, width: 36, height: 36)))),
            if (o.items.length > 4)
              Container(width: 36, height: 36,
                decoration: BoxDecoration(color: C.card2,
                  borderRadius: BorderRadius.circular(6)),
                child: Center(child: Text('+${o.items.length-4}',
                  style: const TextStyle(color: C.text2, fontSize: 10)))),
            const Spacer(),
            // WA status
            Row(children: [
              const Text('💬 ', style: TextStyle(fontSize: 12)),
              Text(o.waSent, style: TextStyle(
                fontSize: 10,
                color: switch(o.waSent) {
                  'sent'    => C.green,
                  'failed'  => C.red,
                  _         => C.text3,
                }, fontWeight: FontWeight.w600)),
            ]),
          ]),
        ])));

  void _showDetail(BuildContext ctx, AppState st, AppOrder o) =>
    showModalBottomSheet(
      context: ctx, backgroundColor: C.card, isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _OrderDetailSheet(order: o, st: st));
}

// ── Order detail bottom sheet ──────────────────────────────────────
class _OrderDetailSheet extends StatefulWidget {
  final AppOrder order;
  final AppState st;
  const _OrderDetailSheet({required this.order, required this.st});
  @override State<_OrderDetailSheet> createState() => _ODSState();
}

class _ODSState extends State<_OrderDetailSheet> {
  late String _status;
  final _trackC = TextEditingController();
  bool _busy = false;

  @override void initState() {
    super.initState();
    _status = widget.order.status;
    _trackC.text = widget.order.trackingNumber;
  }

  @override void dispose() { _trackC.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext ctx) {
    final o = widget.order;
    return DraggableScrollableSheet(
      expand: false, initialChildSize: .85, maxChildSize: .95,
      builder: (_, ctrl) => ListView(
        controller: ctrl,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Center(child: Container(width: 40, height: 4,
            decoration: BoxDecoration(color: C.border,
              borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: Text(
              'Order #${o.id.substring(0,8).toUpperCase()}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                color: C.text))),
            StatusChip(o.status),
          ]),
          const SizedBox(height: 4),
          Text(_fmtDate(o.createdAt),
            style: const TextStyle(color: C.text3, fontSize: 11)),
          const SizedBox(height: 16),

          // Customer info
          DCard(child: Column(children: [
            _row(Icons.person_outline, 'Customer',
              o.userName.isNotEmpty ? o.userName : 'Unknown'),
            _divider(),
            _row(Icons.phone_outlined, 'Phone', o.userPhone),
            _divider(),
            _row(Icons.location_on_outlined, 'Deliver to',
              o.deliveryAddress.isNotEmpty ? o.deliveryAddress : '—'),
            _divider(),
            _row(Icons.payment_outlined, 'Payment', o.paymentMethod),
            if (o.notes.isNotEmpty) ...[
              _divider(),
              _row(Icons.note_outlined, 'Notes', o.notes),
            ],
          ])),
          const SizedBox(height: 12),

          // Items
          const Text('Items', style: TextStyle(
            fontWeight: FontWeight.w700, color: C.text, fontSize: 14)),
          const SizedBox(height: 8),
          ...o.items.map((i) => Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: C.card2,
              borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              ClipRRect(borderRadius: BorderRadius.circular(8),
                child: PImage(i.imageUrl, width: 50, height: 50)),
              const SizedBox(width: 10),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(i.productName, style: const TextStyle(
                  color: C.text, fontSize: 12, fontWeight: FontWeight.w600),
                  maxLines: 2),
                if (i.partNumber.isNotEmpty)
                  Text('#${i.partNumber}',
                    style: const TextStyle(color: C.text3, fontSize: 10)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('x${i.qty}', style: const TextStyle(color: C.text2)),
                Text(PriceText.fmtPrice(i.subtotal),
                  style: const TextStyle(color: C.orange,
                    fontWeight: FontWeight.w700, fontSize: 12)),
              ]),
            ]))),
          Container(padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: C.orange.withOpacity(.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: C.orange.withOpacity(.2))),
            child: Row(children: [
              const Text('Total', style: TextStyle(
                color: C.text, fontWeight: FontWeight.w800, fontSize: 15)),
              const Spacer(),
              PriceText(o.total, fontSize: 17),
            ])),

          const SizedBox(height: 16),

          // Update status
          const Text('Update Status', style: TextStyle(
            fontWeight: FontWeight.w700, color: C.text, fontSize: 14)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8,
            children: AppConf.orderStatuses.map((s) {
              final sel = _status == s;
              return GestureDetector(
                onTap: () => setState(() => _status = s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    gradient: sel ? C.brandGrad : null,
                    color:    sel ? null : C.card2,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: sel ? C.orange : C.border)),
                  child: Text(s, style: TextStyle(
                    fontSize: 12,
                    color: sel ? Colors.white : C.text2,
                    fontWeight: sel ? FontWeight.w700 : FontWeight.normal))));
            }).toList()),
          const SizedBox(height: 12),

          // Tracking number
          TextFormField(
            controller: _trackC,
            style: const TextStyle(color: C.text),
            decoration: const InputDecoration(
              labelText: 'Tracking Number (optional)',
              prefixIcon: Icon(Icons.local_shipping_outlined, color: C.text2))),
          const SizedBox(height: 14),

          // Payment toggle
          DCard(child: Row(children: [
            const Icon(Icons.payment_outlined, color: C.text2, size: 18),
            const SizedBox(width: 10),
            const Expanded(child: Text('Payment Received',
              style: TextStyle(color: C.text, fontSize: 14))),
            Switch(
              value: o.paymentConfirmed,
              onChanged: (_) => widget.st.confirmPayment(o.id),
              activeColor: C.green),
          ])),
          const SizedBox(height: 14),

          // Action buttons
          Row(children: [
            Expanded(child: GradBtn(
              label: 'Update & Notify',
              icon: Icons.send_outlined,
              busy: _busy,
              onTap: () => _update(ctx))),
            const SizedBox(width: 10),
            // WhatsApp direct button
            GestureDetector(
              onTap: () => _resendWa(ctx, o),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366).withOpacity(.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF25D366).withOpacity(.4))),
                child: const Text('💬', style: TextStyle(fontSize: 20)))),
          ]),
        ]));
  }

  Widget _row(IconData ic, String label, String val) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(children: [
      Icon(ic, size: 15, color: C.orange),
      const SizedBox(width: 10),
      Text(label, style: const TextStyle(color: C.text2, fontSize: 12)),
      const Spacer(),
      Flexible(child: Text(val, style: const TextStyle(
        color: C.text, fontSize: 12, fontWeight: FontWeight.w600),
        textAlign: TextAlign.end, maxLines: 2)),
    ]));

  Widget _divider() => const Divider(color: C.border, height: 1);

  Future<void> _update(BuildContext ctx) async {
    setState(() => _busy = true);
    await widget.st.updateOrderStatus(widget.order.id, _status);
    if (_trackC.text.trim().isNotEmpty) {
      await widget.st.updateOrderTracking(widget.order.id, _trackC.text.trim());
    }
    setState(() => _busy = false);
    if (ctx.mounted) { toast(ctx, 'Order updated & WhatsApp sent!'); Navigator.pop(ctx); }
  }

  Future<void> _resendWa(BuildContext ctx, AppOrder o) async {
    final ok = await WhatsAppService.sendStatusUpdate(o);
    if (ctx.mounted) toast(ctx, ok ? 'WhatsApp sent! 💬' : 'WA failed ❌',
      color: ok ? C.green : C.red);
  }

  String _fmtDate(DateTime d) =>
    '${d.day}/${d.month}/${d.year} ${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';
}
