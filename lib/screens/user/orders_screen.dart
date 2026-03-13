import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../utils/theme.dart';
import '../../widgets/widgets.dart';
import '../../models/models.dart';

// ═══════════════════════════════════════════════
//  My Orders
// ═══════════════════════════════════════════════
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final orders = st.myOrders;
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(title: const Text('My Orders',
        style: TextStyle(fontWeight: FontWeight.w800))),
      body: orders.isEmpty
        ? _empty()
        : ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: orders.length,
            itemBuilder: (_, i) => _orderCard(context, orders[i])),
    );
  }

  Widget _empty() => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Icon(Icons.receipt_long_outlined, color: C.orange.withOpacity(.3), size: 72),
    const SizedBox(height: 16),
    const Text('No orders yet', style: TextStyle(
      color: C.text2, fontSize: 17, fontWeight: FontWeight.w600)),
  ]));

  Widget _orderCard(BuildContext ctx, AppOrder o) {
    return GestureDetector(
      onTap: () => _showDetail(ctx, o),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: C.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: C.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('#${o.id.substring(0,8).toUpperCase()}',
              style: const TextStyle(color: C.orange,
                fontWeight: FontWeight.w800, fontSize: 13)),
            const Spacer(),
            StatusChip(o.status),
          ]),
          const SizedBox(height: 6),
          Text('${o.itemCount} items  •  ${PriceText.fmtPrice(o.total)}',
            style: const TextStyle(color: C.text, fontSize: 14,
              fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(_fmtDate(o.createdAt),
            style: const TextStyle(color: C.text3, fontSize: 11)),
          const SizedBox(height: 8),
          // Image row
          SizedBox(height: 48, child: ListView(
            scrollDirection: Axis.horizontal,
            children: o.items.take(5).map((i) => Container(
              margin: const EdgeInsets.only(right: 6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: PImage(i.imageUrl, width: 48, height: 48)))).toList())),
        ])));
  }

  void _showDetail(BuildContext ctx, AppOrder o) =>
    showModalBottomSheet(
      context: ctx, backgroundColor: C.card, isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        expand: false, initialChildSize: .75, maxChildSize: .95,
        builder: (_, ctrl) => ListView(
          controller: ctrl,
          padding: const EdgeInsets.all(20),
          children: [
            Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: C.border,
                borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 14),
            Text('Order #${o.id.substring(0,8).toUpperCase()}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: C.text)),
            const SizedBox(height: 4),
            Row(children: [
              StatusChip(o.status),
              const SizedBox(width: 10),
              Text(_fmtDate(o.createdAt),
                style: const TextStyle(color: C.text3, fontSize: 11)),
            ]),
            const SizedBox(height: 16),
            ...o.items.map((i) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: C.card2,
                borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                ClipRRect(borderRadius: BorderRadius.circular(8),
                  child: PImage(i.imageUrl, width: 54, height: 54)),
                const SizedBox(width: 10),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(i.productName, style: const TextStyle(
                    color: C.text, fontSize: 13, fontWeight: FontWeight.w600),
                    maxLines: 2),
                  Text('x${i.qty}', style: const TextStyle(color: C.text2)),
                ])),
                PriceText(i.subtotal, fontSize: 13),
              ]))),
            const Divider(color: C.border),
            _infoRow('Payment', o.paymentMethod),
            if (o.deliveryAddress.isNotEmpty) _infoRow('Deliver to', o.deliveryAddress),
            if (o.trackingNumber.isNotEmpty) _infoRow('Tracking', o.trackingNumber),
            _infoRow('Total', PriceText.fmtPrice(o.total), bold: true),
          ])));

  Widget _infoRow(String label, String val, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      Text(label, style: const TextStyle(color: C.text2, fontSize: 13)),
      const Spacer(),
      Flexible(child: Text(val, style: TextStyle(
        color: bold ? C.orange : C.text,
        fontSize: 13, fontWeight: bold ? FontWeight.w800 : FontWeight.w600),
        textAlign: TextAlign.end)),
    ]));

  String _fmtDate(DateTime d) =>
    '${d.day}/${d.month}/${d.year}  ${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';
}

// ═══════════════════════════════════════════════
//  Profile
// ═══════════════════════════════════════════════
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override State<ProfileScreen> createState() => _ProfileState();
}

class _ProfileState extends State<ProfileScreen> {
  late final _nameC  = TextEditingController();
  late final _addrC  = TextEditingController();
  late final _emailC = TextEditingController();
  bool _saving = false;

  @override void initState() {
    super.initState();
    final u = context.read<AppState>().user!;
    _nameC.text  = u.name;
    _addrC.text  = u.address;
    _emailC.text = u.email;
  }

  @override void dispose() {
    _nameC.dispose(); _addrC.dispose(); _emailC.dispose(); super.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    final st = ctx.watch<AppState>();
    final u  = st.user!;
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(title: const Text('My Profile',
        style: TextStyle(fontWeight: FontWeight.w800))),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // Avatar
        Center(child: Column(children: [
          Container(width: 80, height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: C.brandGrad,
              boxShadow: C.glow(C.orange)),
            child: Center(child: Text(
              u.name.isNotEmpty ? u.name[0].toUpperCase() : u.phone[0],
              style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900,
                color: Colors.white)))),
          const SizedBox(height: 10),
          Text(u.phone, style: const TextStyle(color: C.text2, fontSize: 13)),
          if (u.isAdmin) Container(
            margin: const EdgeInsets.only(top: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.withOpacity(.4))),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.shield_outlined, size: 13, color: Colors.amber),
              SizedBox(width: 5),
              Text('Admin', style: TextStyle(color: Colors.amber,
                fontSize: 12, fontWeight: FontWeight.w700)),
            ])),
        ])),

        const SizedBox(height: 24),
        _field(_nameC,  'Full Name',    Icons.person_outline),
        const SizedBox(height: 12),
        _field(_addrC,  'Address',      Icons.location_on_outlined, lines: 2),
        const SizedBox(height: 12),
        _field(_emailC, 'Email',        Icons.email_outlined),
        const SizedBox(height: 20),
        GradBtnFull(
          label: 'Save Profile',
          icon: Icons.save_outlined,
          busy: _saving,
          onTap: () async {
            setState(() => _saving = true);
            await st.updateMyProfile(
              _nameC.text.trim(), _addrC.text.trim(), _emailC.text.trim());
            setState(() => _saving = false);
            if (ctx.mounted) toast(ctx, 'Profile saved!');
          }),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: C.red,
            side: const BorderSide(color: C.red),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          icon: const Icon(Icons.logout, size: 18),
          label: const Text('Logout'),
          onPressed: () => _logout(ctx, st)),
      ]),
    );
  }

  Widget _field(TextEditingController c, String label, IconData ic, {int lines = 1}) =>
    TextFormField(controller: c, maxLines: lines,
      style: const TextStyle(color: C.text),
      decoration: InputDecoration(labelText: label,
        prefixIcon: Icon(ic, color: C.text2)));

  Future<void> _logout(BuildContext ctx, AppState st) async {
    final ok = await showDialog<bool>(context: ctx, builder: (_) => AlertDialog(
      backgroundColor: C.card,
      title: const Text('Logout?', style: TextStyle(color: C.text)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Logout', style: TextStyle(color: C.red))),
      ]));
    if (ok == true) await st.logout();
  }
}
