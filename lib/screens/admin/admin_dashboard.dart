import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../utils/theme.dart';
import '../../widgets/widgets.dart';
import 'admin_products.dart';
import 'admin_orders.dart';
import 'admin_users.dart';
import 'admin_settings.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final orders  = st.allOrders;
    final pending = orders.where((o) => o.status == 'Pending').length;
    final today   = orders.where((o) {
      final now = DateTime.now();
      return o.createdAt.year == now.year &&
             o.createdAt.month == now.month &&
             o.createdAt.day == now.day;
    }).length;
    final revenue = orders
        .where((o) => o.status == 'Delivered')
        .fold(0.0, (s, o) => s + o.total);

    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Header ────────────────────────────────────────────
          Row(children: [
            Container(width: 44, height: 44,
              decoration: BoxDecoration(
                gradient: C.brandGrad,
                borderRadius: BorderRadius.circular(12)),
              child: const Center(child: Text('⚙️',
                style: TextStyle(fontSize: 22)))),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Admin Panel', style: TextStyle(
                fontSize: 11, color: C.text3, letterSpacing: 1)),
              const Text('SJ Tracking Solution', style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w900, color: C.orange)),
            ])),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber.withOpacity(.35))),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.shield_outlined, size: 13, color: Colors.amber),
                SizedBox(width: 5),
                Text('ADMIN', style: TextStyle(color: Colors.amber,
                  fontSize: 11, fontWeight: FontWeight.w800)),
              ])),
          ]),

          const SizedBox(height: 20),

          // ── KPI cards ─────────────────────────────────────────
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10, mainAxisSpacing: 10,
            childAspectRatio: 1.6,
            children: [
              _kpi('Total Orders', '${orders.length}', Icons.receipt_long_outlined, C.blue),
              _kpi('Pending', '$pending', Icons.hourglass_empty, C.amber),
              _kpi("Today's Orders", '$today', Icons.today_outlined, C.purple),
              _kpi('Revenue', _fmt(revenue), Icons.attach_money_outlined, C.green),
            ]),

          const SizedBox(height: 20),

          // ── Quick stats ───────────────────────────────────────
          DCard(child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _miniStat('Products', '${st.allProducts.length}', Icons.inventory_2_outlined),
              _vdiv(),
              _miniStat('Active', '${st.allProducts.where((p) => p.active).length}', Icons.check_circle_outline),
              _vdiv(),
              _miniStat('Customers', '${st.allUsers.length}', Icons.people_outline),
              _vdiv(),
              _miniStat('Low Stock', '${st.allProducts.where((p) => p.stock < 3 && p.active).length}',
                Icons.warning_amber_outlined),
            ])),

          const SizedBox(height: 20),

          // ── Navigation tiles ──────────────────────────────────
          const Text('Management', style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w700, color: C.text)),
          const SizedBox(height: 12),
          _navTile(context, '🛒  Products', 'Add, edit, delete products & stock',
            C.orange, const AdminProductsScreen()),
          _navTile(context, '📦  Orders', 'Manage & update order status',
            C.blue, const AdminOrdersScreen()),
          _navTile(context, '👥  Customers', 'View and manage users',
            C.purple, const AdminUsersScreen()),
          _navTile(context, '⚙️  Settings', 'WhatsApp API, admin config',
            C.teal, const AdminSettingsScreen()),

          const SizedBox(height: 20),

          // ── Recent orders ─────────────────────────────────────
          if (orders.isNotEmpty) ...[
            SectionHead('Recent Orders', action: 'View All',
              onAction: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AdminOrdersScreen()))),
            const SizedBox(height: 10),
            ...orders.take(4).map((o) => _recentOrder(context, o)),
          ],

          const SizedBox(height: 20),

          // ── Low-stock alert ───────────────────────────────────
          if (st.allProducts.any((p) => p.stock < 3 && p.active)) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: C.amber.withOpacity(.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: C.amber.withOpacity(.3))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Row(children: [
                  Icon(Icons.warning_amber_rounded, color: C.amber, size: 18),
                  SizedBox(width: 8),
                  Text('Low Stock Alert', style: TextStyle(
                    color: C.amber, fontWeight: FontWeight.w700, fontSize: 14)),
                ]),
                const SizedBox(height: 8),
                ...st.allProducts
                  .where((p) => p.stock < 3 && p.active)
                  .map((p) => Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Row(children: [
                      ClipRRect(borderRadius: BorderRadius.circular(6),
                        child: PImage(p.imageUrl, width: 36, height: 36)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(p.name, style: const TextStyle(
                        color: C.text, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      Text('${p.stock} left', style: const TextStyle(
                        color: C.amber, fontSize: 12, fontWeight: FontWeight.w700)),
                    ]))),
              ])),
          ],
          const SizedBox(height: 30),
        ],
      )),
    );
  }

  Widget _kpi(String label, String val, IconData icon, Color color) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: C.card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: C.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(.12),
            borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18)),
        const Spacer(),
      ]),
      const SizedBox(height: 8),
      Text(val, style: TextStyle(
        fontSize: 22, fontWeight: FontWeight.w900, color: color)),
      Text(label, style: const TextStyle(color: C.text2, fontSize: 12)),
    ]));

  Widget _miniStat(String label, String val, IconData icon) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Column(children: [
      Icon(icon, color: C.text2, size: 18),
      const SizedBox(height: 4),
      Text(val, style: const TextStyle(
        fontSize: 16, fontWeight: FontWeight.w800, color: C.text)),
      Text(label, style: const TextStyle(color: C.text3, fontSize: 10)),
    ]));

  Widget _vdiv() => Container(height: 40, width: 1, color: C.border);

  Widget _navTile(BuildContext ctx, String title, String sub, Color c, Widget dest) =>
    GestureDetector(
      onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => dest)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: C.card, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: C.border)),
        child: Row(children: [
          Container(width: 4, height: 36,
            decoration: BoxDecoration(color: c,
              borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w700, color: C.text)),
            Text(sub, style: const TextStyle(color: C.text3, fontSize: 11)),
          ])),
          Icon(Icons.chevron_right_rounded, color: C.text3),
        ])));

  Widget _recentOrder(BuildContext ctx, o) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: C.card,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: C.border)),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('#${o.id.substring(0,8).toUpperCase()}',
          style: const TextStyle(color: C.orange, fontWeight: FontWeight.w700, fontSize: 12)),
        Text(o.userPhone, style: const TextStyle(color: C.text2, fontSize: 11)),
      ])),
      StatusChip(o.status),
      const SizedBox(width: 10),
      Text(_fmt(o.total), style: const TextStyle(
        color: C.text, fontWeight: FontWeight.w700, fontSize: 12)),
    ]));

  static String _fmt(double v) =>
    'TSh ${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
}
