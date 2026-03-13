import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import '../../providers/app_state.dart';
import '../../utils/theme.dart';
import '../user/shop_screen.dart';
import '../user/orders_screen.dart';
import '../admin/admin_dashboard.dart';

// ═══════════════════════════════════════════════
//  User Shell — Shop + Orders + Profile
// ═══════════════════════════════════════════════
class UserShell extends StatefulWidget {
  const UserShell({super.key});
  @override State<UserShell> createState() => _UserShellState();
}

class _UserShellState extends State<UserShell> {
  int _idx = 0;

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final tabs = [
      const ShopScreen(),
      const OrdersScreen(),
      const ProfileScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: _idx, children: tabs),
      bottomNavigationBar: NavigationBar(
        backgroundColor: C.card,
        surfaceTintColor: Colors.transparent,
        indicatorColor: C.orange.withOpacity(.18),
        selectedIndex: _idx,
        onDestinationSelected: (i) => setState(() => _idx = i),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.store_outlined, color: C.text2),
            selectedIcon: Icon(Icons.store_rounded, color: C.orange),
            label: 'Shop'),
          NavigationDestination(
            icon: badges.Badge(
              showBadge: st.myOrders.any((o) => o.status == 'Shipped' ||
                o.status == 'Delivered'),
              badgeStyle: const badges.BadgeStyle(badgeColor: C.orange),
              child: const Icon(Icons.receipt_long_outlined, color: C.text2)),
            selectedIcon: const Icon(Icons.receipt_long, color: C.orange),
            label: 'Orders'),
          const NavigationDestination(
            icon: Icon(Icons.person_outline, color: C.text2),
            selectedIcon: Icon(Icons.person_rounded, color: C.orange),
            label: 'Profile'),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  Admin Shell — Dashboard + Shop + Profile
// ═══════════════════════════════════════════════
class AdminShell extends StatefulWidget {
  const AdminShell({super.key});
  @override State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _idx = 0;

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final pending = st.allOrders.where((o) => o.status == 'Pending').length;
    final tabs = [
      const AdminDashboard(),
      const ShopScreen(),      // admin can browse shop too
      const OrdersScreen(),    // admin sees their own orders
      const ProfileScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: _idx, children: tabs),
      bottomNavigationBar: NavigationBar(
        backgroundColor: C.card,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Colors.amber.withOpacity(.18),
        selectedIndex: _idx,
        onDestinationSelected: (i) => setState(() => _idx = i),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: badges.Badge(
              showBadge: pending > 0,
              badgeContent: Text('$pending',
                style: const TextStyle(color: Colors.white, fontSize: 9)),
              badgeStyle: const badges.BadgeStyle(badgeColor: C.red),
              child: const Icon(Icons.admin_panel_settings_outlined, color: C.text2)),
            selectedIcon: const Icon(Icons.admin_panel_settings, color: Colors.amber),
            label: 'Admin'),
          const NavigationDestination(
            icon: Icon(Icons.store_outlined, color: C.text2),
            selectedIcon: Icon(Icons.store_rounded, color: Colors.amber),
            label: 'Shop'),
          const NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined, color: C.text2),
            selectedIcon: Icon(Icons.receipt_long, color: Colors.amber),
            label: 'Orders'),
          const NavigationDestination(
            icon: Icon(Icons.person_outline, color: C.text2),
            selectedIcon: Icon(Icons.person_rounded, color: Colors.amber),
            label: 'Profile'),
        ],
      ),
    );
  }
}
