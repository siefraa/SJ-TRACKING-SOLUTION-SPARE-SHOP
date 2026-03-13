import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/models.dart';
import '../models/seed_products.dart';
import '../utils/constants.dart';
import '../services/whatsapp_service.dart';

class AppState extends ChangeNotifier {
  // ── Auth ──────────────────────────────────────────────────────────
  AppUser?  _user;
  bool      _otpStep   = false;
  bool      _busy      = false;
  String?   _authErr;
  String    _pendPhone = '';

  AppUser?  get user      => _user;
  bool      get isAuth    => _user != null;
  bool      get isAdmin   => _user?.isAdmin ?? false;
  bool      get otpStep   => _otpStep;
  bool      get busy      => _busy;
  String?   get authErr   => _authErr;
  String    get pendPhone => _pendPhone;

  // ── Data ──────────────────────────────────────────────────────────
  List<Product>     _products     = [];
  List<AppOrder>    _orders       = [];
  List<AppUser>     _users        = [];
  List<AppNotification> _notifs   = [];

  // ── Cart ──────────────────────────────────────────────────────────
  final List<CartItem> _cart      = [];

  // ── Admin config ──────────────────────────────────────────────────
  List<String> _adminPhones = [...AppConf.defaultAdminPhones];
  String _waApiUrl  = AppConf.defaultWaApiUrl;
  String _waToken   = AppConf.defaultWaToken;
  String _waShop    = AppConf.waNumber;

  // ── Filters (shop) ────────────────────────────────────────────────
  String _catFilter = '';
  String _q         = '';
  String _sortBy    = 'newest';
  bool   _onlyInStock = false;

  // ─────────────────────────────────────────────────────────────────
  // Getters
  // ─────────────────────────────────────────────────────────────────
  List<Product> get allProducts => _products;
  List<Product> get featured    => _products.where((p) => p.featured && p.active).toList();

  List<Product> get filteredProducts {
    var list = _products.where((p) => p.active).toList();
    if (_catFilter.isNotEmpty) list = list.where((p) => p.category == _catFilter).toList();
    if (_onlyInStock)          list = list.where((p) => p.inStock).toList();
    if (_q.isNotEmpty) {
      final lq = _q.toLowerCase();
      list = list.where((p) =>
        p.name.toLowerCase().contains(lq) ||
        p.brand.toLowerCase().contains(lq) ||
        p.partNumber.toLowerCase().contains(lq) ||
        p.compatibility.toLowerCase().contains(lq)).toList();
    }
    switch (_sortBy) {
      case 'price_asc':  list.sort((a,b) => a.price.compareTo(b.price));
      case 'price_desc': list.sort((a,b) => b.price.compareTo(a.price));
      case 'rating':     list.sort((a,b) => b.rating.compareTo(a.rating));
      case 'newest':
      default:           list.sort((a,b) => b.createdAt.compareTo(a.createdAt));
    }
    return list;
  }

  List<AppOrder> get allOrders   => _orders;
  List<AppOrder> get myOrders    => _orders
      .where((o) => o.userId == _user?.id)
      .toList()..sort((a,b) => b.createdAt.compareTo(a.createdAt));

  List<AppUser> get allUsers     => _users;
  List<CartItem> get cart        => _cart;
  int get cartCount              => _cart.fold(0, (s, c) => s + c.qty);
  double get cartTotal           => _cart.fold(0, (s, c) => s + c.subtotal);

  List<AppNotification> get myNotifs =>
      _notifs.where((n) => !n.read).toList();
  int get unreadCount => myNotifs.length;

  String get catFilter     => _catFilter;
  String get searchQ       => _q;
  String get sortBy        => _sortBy;
  bool   get onlyInStock   => _onlyInStock;

  String get waApiUrl  => _waApiUrl;
  String get waToken   => _waToken;
  String get waShop    => _waShop;
  List<String> get adminPhones => _adminPhones;

  // ─────────────────────────────────────────────────────────────────
  // Init
  // ─────────────────────────────────────────────────────────────────
  Future<void> init() async {
    final p = await SharedPreferences.getInstance();

    // Load WA config
    _waApiUrl = p.getString('wa_url')   ?? AppConf.defaultWaApiUrl;
    _waToken  = p.getString('wa_token') ?? AppConf.defaultWaToken;
    _waShop   = p.getString('wa_shop')  ?? AppConf.waNumber;
    final adminStr = p.getString('admin_phones');
    if (adminStr != null) {
      _adminPhones = List<String>.from(jsonDecode(adminStr));
    }
    _configureWa();

    // Load user
    final userStr = p.getString('user');
    if (userStr != null) {
      try { _user = AppUser.fromJson(jsonDecode(userStr)); } catch (_) {}
    }

    // Load products
    final prodStr = p.getString('products');
    if (prodStr != null) {
      try {
        _products = (jsonDecode(prodStr) as List)
            .map((j) => Product.fromJson(j as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }
    if (_products.isEmpty) {
      _products = buildSeedProducts();
      await _saveProducts();
    }

    // Load orders
    final ordStr = p.getString('orders');
    if (ordStr != null) {
      try {
        _orders = (jsonDecode(ordStr) as List)
            .map((j) => AppOrder.fromJson(j as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    // Load users
    final usrStr = p.getString('users');
    if (usrStr != null) {
      try {
        _users = (jsonDecode(usrStr) as List)
            .map((j) => AppUser.fromJson(j as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────
  // Auth
  // ─────────────────────────────────────────────────────────────────
  Future<void> requestOtp(String phone) async {
    _busy = true; _authErr = null; notifyListeners();
    await Future.delayed(const Duration(milliseconds: 900));
    _pendPhone = phone;
    _otpStep   = true;
    _busy      = false;
    notifyListeners();
  }

  Future<bool> verifyOtp(String code) async {
    _busy = true; _authErr = null; notifyListeners();
    await Future.delayed(const Duration(milliseconds: 800));
    if (code.trim() != AppConf.demoOtp) {
      _authErr = 'Invalid OTP code — demo: use 123456';
      _busy = false; notifyListeners(); return false;
    }
    // Find or create user
    AppUser? existing = _users.where((u) => u.phone == _pendPhone).isNotEmpty
        ? _users.firstWhere((u) => u.phone == _pendPhone)
        : null;
    if (existing == null) {
      existing = AppUser(
        id:      const Uuid().v4(),
        phone:   _pendPhone,
        isAdmin: _adminPhones.contains(_pendPhone),
      );
      _users.add(existing);
      await _saveUsers();
    }
    if (existing.isBlocked) {
      _authErr = 'Your account has been blocked. Contact admin.';
      _busy = false; notifyListeners(); return false;
    }
    _user    = existing;
    _otpStep = false;
    _busy    = false;
    final p  = await SharedPreferences.getInstance();
    await p.setString('user', jsonEncode(_user!.toJson()));
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _user    = null;
    _otpStep = false;
    _cart.clear();
    final p  = await SharedPreferences.getInstance();
    await p.remove('user');
    notifyListeners();
  }

  void resetOtp() { _otpStep = false; notifyListeners(); }

  // ─────────────────────────────────────────────────────────────────
  // Filters
  // ─────────────────────────────────────────────────────────────────
  void setCategory(String c)  { _catFilter    = c;    notifyListeners(); }
  void setSearch(String q)    { _q            = q;    notifyListeners(); }
  void setSortBy(String s)    { _sortBy       = s;    notifyListeners(); }
  void setInStock(bool v)     { _onlyInStock  = v;    notifyListeners(); }
  void clearFilters()         { _catFilter=''; _q=''; _onlyInStock=false; notifyListeners(); }

  // ─────────────────────────────────────────────────────────────────
  // Cart
  // ─────────────────────────────────────────────────────────────────
  void addToCart(Product p, {int qty = 1}) {
    final idx = _cart.indexWhere((c) => c.product.id == p.id);
    if (idx >= 0) {
      _cart[idx].qty += qty;
    } else {
      _cart.add(CartItem(product: p, qty: qty));
    }
    _addNotif('Cart updated', '${p.name} added to cart', 'info');
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cart.removeWhere((c) => c.product.id == productId);
    notifyListeners();
  }

  void updateQty(String productId, int qty) {
    if (qty <= 0) { removeFromCart(productId); return; }
    final idx = _cart.indexWhere((c) => c.product.id == productId);
    if (idx >= 0) { _cart[idx].qty = qty; notifyListeners(); }
  }

  void clearCart() { _cart.clear(); notifyListeners(); }

  // ─────────────────────────────────────────────────────────────────
  // Orders
  // ─────────────────────────────────────────────────────────────────
  Future<AppOrder> placeOrder({
    required String deliveryAddress,
    required String paymentMethod,
    String notes = '',
  }) async {
    if (_user == null || _cart.isEmpty) throw Exception('No user or cart empty');
    final order = AppOrder(
      id:              const Uuid().v4(),
      userId:          _user!.id,
      userPhone:       _user!.phone,
      userName:        _user!.name,
      deliveryAddress: deliveryAddress,
      paymentMethod:   paymentMethod,
      notes:           notes,
      items: _cart.map((c) => OrderItem(
        productId:   c.product.id,
        productName: c.product.name,
        imageUrl:    c.product.imageUrl,
        price:       c.product.price,
        qty:         c.qty,
        partNumber:  c.product.partNumber,
        category:    c.product.category,
      )).toList(),
    );
    _orders.add(order);
    clearCart();
    await _saveOrders();

    // Reduce stock
    for (final item in order.items) {
      final idx = _products.indexWhere((p) => p.id == item.productId);
      if (idx >= 0) {
        _products[idx] = _products[idx].copyWith(
          stock: (_products[idx].stock - item.qty).clamp(0, 99999));
      }
    }
    await _saveProducts();

    _addNotif('Order Placed! 🎉',
      'Order #${order.id.substring(0,8).toUpperCase()} placed. Total: ${_fmt(order.total)}',
      'order');

    // WhatsApp notifications
    WhatsAppService.sendOrderConfirmation(order)
        .then((ok) => _updateWaSent(order.id, ok ? 'sent' : 'failed'));
    WhatsAppService.alertAdmin(order);

    notifyListeners();
    return order;
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx < 0) return;
    _orders[idx].status    = status;
    _orders[idx].updatedAt = DateTime.now();
    await _saveOrders();
    WhatsAppService.sendStatusUpdate(_orders[idx]);
    notifyListeners();
  }

  Future<void> updateOrderTracking(String orderId, String trackNum) async {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx < 0) return;
    _orders[idx].trackingNumber = trackNum;
    _orders[idx].updatedAt      = DateTime.now();
    await _saveOrders(); notifyListeners();
  }

  Future<void> confirmPayment(String orderId) async {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx < 0) return;
    _orders[idx].paymentConfirmed = true;
    _orders[idx].updatedAt        = DateTime.now();
    await _saveOrders(); notifyListeners();
  }

  void _updateWaSent(String orderId, String status) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) { _orders[idx].waSent = status; notifyListeners(); }
  }

  // ─────────────────────────────────────────────────────────────────
  // Products (admin)
  // ─────────────────────────────────────────────────────────────────
  Future<Product> addProduct(Product p) async {
    _products.insert(0, p);
    await _saveProducts(); notifyListeners(); return p;
  }

  Future<void> updateProduct(Product p) async {
    final idx = _products.indexWhere((x) => x.id == p.id);
    if (idx >= 0) { _products[idx] = p; await _saveProducts(); notifyListeners(); }
  }

  Future<void> deleteProduct(String id) async {
    _products.removeWhere((p) => p.id == id);
    await _saveProducts(); notifyListeners();
  }

  Future<void> toggleFeatured(String id) async {
    final idx = _products.indexWhere((p) => p.id == id);
    if (idx >= 0) {
      _products[idx] = _products[idx].copyWith(
          featured: !_products[idx].featured);
      await _saveProducts(); notifyListeners();
    }
  }

  Future<void> toggleActive(String id) async {
    final idx = _products.indexWhere((p) => p.id == id);
    if (idx >= 0) {
      _products[idx] = _products[idx].copyWith(active: !_products[idx].active);
      await _saveProducts(); notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // Users (admin)
  // ─────────────────────────────────────────────────────────────────
  Future<void> toggleBlock(String userId) async {
    final idx = _users.indexWhere((u) => u.id == userId);
    if (idx >= 0) {
      _users[idx] = _users[idx].copyWith(isBlocked: !_users[idx].isBlocked);
      await _saveUsers(); notifyListeners();
    }
  }

  Future<void> toggleAdmin(String userId) async {
    final idx = _users.indexWhere((u) => u.id == userId);
    if (idx >= 0) {
      _users[idx] = _users[idx].copyWith(isAdmin: !_users[idx].isAdmin);
      await _saveUsers(); notifyListeners();
    }
  }

  Future<void> updateMyProfile(String name, String address, String email) async {
    if (_user == null) return;
    _user = _user!.copyWith(name: name, address: address, email: email);
    final idx = _users.indexWhere((u) => u.id == _user!.id);
    if (idx >= 0) _users[idx] = _user!;
    final p = await SharedPreferences.getInstance();
    await p.setString('user', jsonEncode(_user!.toJson()));
    await _saveUsers(); notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────
  // Admin config
  // ─────────────────────────────────────────────────────────────────
  Future<void> saveWaConfig(String url, String token, String shop) async {
    _waApiUrl = url; _waToken = token; _waShop = shop;
    _configureWa();
    final p = await SharedPreferences.getInstance();
    await p.setString('wa_url',   url);
    await p.setString('wa_token', token);
    await p.setString('wa_shop',  shop);
    notifyListeners();
  }

  Future<void> addAdminPhone(String phone) async {
    if (!_adminPhones.contains(phone)) {
      _adminPhones.add(phone);
      final p = await SharedPreferences.getInstance();
      await p.setString('admin_phones', jsonEncode(_adminPhones));
      // Update user if already registered
      final idx = _users.indexWhere((u) => u.phone == phone);
      if (idx >= 0) { _users[idx] = _users[idx].copyWith(isAdmin: true); await _saveUsers(); }
      notifyListeners();
    }
  }

  Future<void> removeAdminPhone(String phone) async {
    _adminPhones.remove(phone);
    final p = await SharedPreferences.getInstance();
    await p.setString('admin_phones', jsonEncode(_adminPhones));
    final idx = _users.indexWhere((u) => u.phone == phone);
    if (idx >= 0) { _users[idx] = _users[idx].copyWith(isAdmin: false); await _saveUsers(); }
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────
  // Photo upload
  // ─────────────────────────────────────────────────────────────────
  Future<String?> pickAndSaveImage(ImageSource src) async {
    try {
      final xf = await ImagePicker().pickImage(source: src, imageQuality: 85, maxWidth: 1000);
      if (xf == null) return null;
      final dir  = await getApplicationDocumentsDirectory();
      final dest = '${dir.path}/products/${const Uuid().v4()}.jpg';
      await Directory('${dir.path}/products').create(recursive: true);
      await File(xf.path).copy(dest);
      return 'file://$dest';
    } catch (e) { return null; }
  }

  // ─────────────────────────────────────────────────────────────────
  // Notifications
  // ─────────────────────────────────────────────────────────────────
  void _addNotif(String title, String body, String type) =>
    _notifs.insert(0, AppNotification(
      id: const Uuid().v4(), title: title, body: body, type: type));

  void markNotifRead(String id) {
    final idx = _notifs.indexWhere((n) => n.id == id);
    if (idx >= 0) { _notifs[idx].read = true; notifyListeners(); }
  }

  void markAllRead() {
    for (final n in _notifs) n.read = true;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────
  // Persistence
  // ─────────────────────────────────────────────────────────────────
  Future<void> _saveProducts() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('products', jsonEncode(_products.map((x) => x.toJson()).toList()));
  }

  Future<void> _saveOrders() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('orders', jsonEncode(_orders.map((x) => x.toJson()).toList()));
  }

  Future<void> _saveUsers() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('users', jsonEncode(_users.map((x) => x.toJson()).toList()));
  }

  void _configureWa() => WhatsAppService.configure(
    WaConfig(apiUrl: _waApiUrl, token: _waToken, shopPhone: _waShop));

  static String _fmt(double v) =>
    'TSh ${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
}
