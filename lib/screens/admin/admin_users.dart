import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../utils/theme.dart';
import '../../widgets/widgets.dart';
import '../../models/models.dart';
import '../../services/whatsapp_service.dart';

// ═══════════════════════════════════════════════
//  Admin — User Management
// ═══════════════════════════════════════════════
class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final users = List<AppUser>.from(st.allUsers)
      ..sort((a,b) => a.isAdmin != b.isAdmin
        ? (a.isAdmin ? -1 : 1) : a.phone.compareTo(b.phone));
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        title: Text('Customers (${users.length})',
          style: const TextStyle(fontWeight: FontWeight.w800))),
      body: users.isEmpty
        ? const Center(child: Text('No registered users',
            style: TextStyle(color: C.text2)))
        : ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: users.length,
            itemBuilder: (_, i) => _userCard(context, st, users[i])),
    );
  }

  Widget _userCard(BuildContext ctx, AppState st, AppUser u) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: u.isBlocked ? C.card.withOpacity(.5) : C.card,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: u.isAdmin ? Colors.amber.withOpacity(.35) : C.border)),
    child: Row(children: [
      // Avatar
      Container(width: 46, height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: u.isAdmin
            ? const LinearGradient(colors: [Colors.amber, Color(0xFFFF8C00)])
            : C.brandGrad),
        child: Center(child: Text(
          u.name.isNotEmpty ? u.name[0].toUpperCase()
                            : u.phone.length > 3 ? u.phone[u.phone.length-3] : '?',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
            color: Colors.white)))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(u.name.isNotEmpty ? u.name : 'User',
            style: const TextStyle(color: C.text, fontWeight: FontWeight.w700)),
          if (u.isAdmin) ...[
            const SizedBox(width: 6),
            Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.amber.withOpacity(.15),
                borderRadius: BorderRadius.circular(8)),
              child: const Text('ADMIN', style: TextStyle(
                color: Colors.amber, fontSize: 9, fontWeight: FontWeight.w800))),
          ],
          if (u.isBlocked) ...[
            const SizedBox(width: 6),
            Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: C.red.withOpacity(.15),
                borderRadius: BorderRadius.circular(8)),
              child: const Text('BLOCKED', style: TextStyle(
                color: C.red, fontSize: 9, fontWeight: FontWeight.w800))),
          ],
        ]),
        Text(u.phone, style: const TextStyle(color: C.text2, fontSize: 12)),
        if (u.email.isNotEmpty)
          Text(u.email, style: const TextStyle(color: C.text3, fontSize: 11)),
        // Order count
        Builder(builder: (context) {
          final orders = context.read<AppState>().allOrders
              .where((o) => o.userId == u.id).length;
          return Text('$orders orders',
            style: const TextStyle(color: C.orange, fontSize: 11,
              fontWeight: FontWeight.w600));
        }),
      ])),
      PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, color: C.text2),
        color: C.card2,
        onSelected: (v) => _onAction(ctx, st, u, v),
        itemBuilder: (_) => [
          _pmi('admin', u.isAdmin ? 'Remove Admin' : 'Make Admin',
            u.isAdmin ? Icons.shield_outlined : Icons.shield,
            u.isAdmin ? C.text2 : Colors.amber),
          _pmi('block', u.isBlocked ? 'Unblock' : 'Block User',
            u.isBlocked ? Icons.lock_open_outlined : Icons.block_outlined,
            u.isBlocked ? C.green : C.red),
          _pmi('wa', 'Send WhatsApp', Icons.chat_outlined, C.green),
        ]),
    ]));

  PopupMenuItem<String> _pmi(String v, String label, IconData ic, Color c) =>
    PopupMenuItem(value: v, child: Row(children: [
      Icon(ic, size: 17, color: c),
      const SizedBox(width: 10),
      Text(label, style: const TextStyle(color: C.text)),
    ]));

  Future<void> _onAction(BuildContext ctx, AppState st, AppUser u, String v) async {
    switch (v) {
      case 'admin': await st.toggleAdmin(u.id);
      case 'block': await st.toggleBlock(u.id);
      case 'wa':
        final msg = Uri.encodeComponent(
          'Hello ${u.name.isNotEmpty ? u.name : "there"}, this is SJ Tracking Solution.');
        final url = Uri.parse('https://wa.me/${u.phone.replaceAll('+', '')}?text=$msg');
        if (ctx.mounted) toast(ctx, 'Opening WhatsApp…');
    }
  }
}

// ═══════════════════════════════════════════════
//  Admin — Settings / Config
// ═══════════════════════════════════════════════
class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});
  @override State<AdminSettingsScreen> createState() => _ASState();
}

class _ASState extends State<AdminSettingsScreen> {
  late final _urlC    = TextEditingController();
  late final _tokenC  = TextEditingController();
  late final _shopC   = TextEditingController();
  late final _adminC  = TextEditingController();
  bool _saving = false;
  bool _testing = false;

  @override void initState() {
    super.initState();
    final st = context.read<AppState>();
    _urlC.text   = st.waApiUrl;
    _tokenC.text = st.waToken;
    _shopC.text  = st.waShop;
  }

  @override void dispose() {
    for (final c in [_urlC,_tokenC,_shopC,_adminC]) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    final st = ctx.watch<AppState>();
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(title: const Text('Admin Settings',
        style: TextStyle(fontWeight: FontWeight.w800))),
      body: ListView(padding: const EdgeInsets.all(16), children: [

        // ── WhatsApp Gateway ──────────────────────────────────
        _sectionTitle('💬  WhatsApp SMS Gateway'),
        const Text(
          'Configure your UltraMsg / Callmebot API. All order confirmations '
          'and status updates will be sent via this webhook.',
          style: TextStyle(color: C.text2, fontSize: 12, height: 1.6)),
        const SizedBox(height: 12),
        DCard(child: Column(children: [
          _field(_urlC, 'API Endpoint URL', Icons.link),
          const SizedBox(height: 10),
          _field(_tokenC, 'API Token / Secret', Icons.vpn_key_outlined, obscure: true),
          const SizedBox(height: 10),
          _field(_shopC, 'Shop WhatsApp Number (no +)', Icons.phone_outlined),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: GradBtn(
              label: 'Save Config',
              icon: Icons.save_outlined,
              busy: _saving,
              onTap: () => _saveWa(ctx, st))),
            const SizedBox(width: 10),
            GradBtn(
              label: 'Test',
              icon: Icons.send_outlined,
              busy: _testing,
              color: C.teal,
              onTap: () => _testWa(ctx, st)),
          ]),
        ])),
        const SizedBox(height: 8),
        Container(padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: C.card2,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: C.border)),
          child: const Column(children: [
            Row(children: [
              Icon(Icons.info_outline, color: C.blue, size: 15),
              SizedBox(width: 8),
              Text('How to get UltraMsg credentials:',
                style: TextStyle(color: C.blue, fontSize: 12, fontWeight: FontWeight.w700)),
            ]),
            SizedBox(height: 6),
            Text(
              '1. Sign up at ultramsg.com\n'
              '2. Create an instance & scan QR with WhatsApp\n'
              '3. Copy your Instance ID and Token\n'
              '4. API URL: https://api.ultramsg.com/{instance_id}/messages/chat',
              style: TextStyle(color: C.text3, fontSize: 11, height: 1.6)),
          ])),

        const SizedBox(height: 20),

        // ── Admin Phones ──────────────────────────────────────
        _sectionTitle('👑  Admin Phone Numbers'),
        const Text('These phones get admin access when they log in.',
          style: TextStyle(color: C.text2, fontSize: 12)),
        const SizedBox(height: 10),
        DCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ...st.adminPhones.map((ph) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              const Icon(Icons.admin_panel_settings_outlined,
                color: Colors.amber, size: 16),
              const SizedBox(width: 10),
              Expanded(child: Text(ph,
                style: const TextStyle(color: C.text, fontWeight: FontWeight.w600))),
              GestureDetector(
                onTap: () => st.removeAdminPhone(ph),
                child: const Icon(Icons.remove_circle_outline, color: C.red, size: 18)),
            ]))),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: TextFormField(
              controller: _adminC,
              style: const TextStyle(color: C.text, fontSize: 13),
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: '+255 7XX XXX XXX',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)))),
            const SizedBox(width: 8),
            GradBtn(label: 'Add', icon: Icons.add, small: true,
              onTap: () {
                final ph = _adminC.text.trim();
                if (ph.length >= 8) {
                  st.addAdminPhone(ph);
                  _adminC.clear();
                }
              }),
          ]),
        ])),

        const SizedBox(height: 20),

        // ── App Info ──────────────────────────────────────────
        _sectionTitle('ℹ️  App Info'),
        DCard(child: Column(children: [
          _infoRow('Version', '1.0.0'),
          _infoRow('Total Products', '${st.allProducts.length}'),
          _infoRow('Total Orders', '${st.allOrders.length}'),
          _infoRow('Customers', '${st.allUsers.length}'),
          _infoRow('Active Admins', '${st.allUsers.where((u) => u.isAdmin).length}'),
        ])),

        const SizedBox(height: 40),
      ]),
    );
  }

  Widget _sectionTitle(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(t, style: const TextStyle(
      fontSize: 15, fontWeight: FontWeight.w700, color: C.text)));

  Widget _field(TextEditingController c, String label, IconData icon,
      {bool obscure = false}) =>
    TextFormField(
      controller: c, obscureText: obscure,
      style: const TextStyle(color: C.text, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: C.text2, size: 18)));

  Widget _infoRow(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(children: [
      Text(k, style: const TextStyle(color: C.text2, fontSize: 13)),
      const Spacer(),
      Text(v, style: const TextStyle(color: C.text, fontWeight: FontWeight.w700)),
    ]));

  Future<void> _saveWa(BuildContext ctx, AppState st) async {
    setState(() => _saving = true);
    await st.saveWaConfig(_urlC.text.trim(), _tokenC.text.trim(), _shopC.text.trim());
    setState(() => _saving = false);
    if (ctx.mounted) toast(ctx, 'WhatsApp config saved!');
  }

  Future<void> _testWa(BuildContext ctx, AppState st) async {
    setState(() => _testing = true);
    final ok = await WhatsAppService.send(
      '+${st.waShop}',
      '✅ Test from SJ Tracking Solution app! WhatsApp gateway is working.');
    setState(() => _testing = false);
    if (ctx.mounted) toast(ctx,
      ok ? '✅ Test message sent!' : '❌ Failed — check config',
      color: ok ? C.green : C.red);
  }
}
