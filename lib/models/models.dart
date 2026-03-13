// ══════════════════════════════════════════════════════
//  All data models for SJ Tracking Solution
// ══════════════════════════════════════════════════════

// ── AppUser ────────────────────────────────────────────
class AppUser {
  final String id;
  String phone;
  String name;
  String address;
  String email;
  bool   isAdmin;
  bool   isBlocked;
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.phone,
    this.name      = '',
    this.address   = '',
    this.email     = '',
    this.isAdmin   = false,
    this.isBlocked = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id, 'phone': phone, 'name': name,
    'address': address, 'email': email,
    'isAdmin': isAdmin, 'isBlocked': isBlocked,
    'createdAt': createdAt.toIso8601String(),
  };

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
    id:        j['id'],
    phone:     j['phone'],
    name:      j['name']    ?? '',
    address:   j['address'] ?? '',
    email:     j['email']   ?? '',
    isAdmin:   j['isAdmin'] ?? false,
    isBlocked: j['isBlocked'] ?? false,
    createdAt: j['createdAt'] != null ? DateTime.tryParse(j['createdAt']) : null,
  );

  AppUser copyWith({
    String? name, String? address, String? email,
    bool? isAdmin, bool? isBlocked,
  }) => AppUser(
    id: id, phone: phone, createdAt: createdAt,
    name:      name      ?? this.name,
    address:   address   ?? this.address,
    email:     email     ?? this.email,
    isAdmin:   isAdmin   ?? this.isAdmin,
    isBlocked: isBlocked ?? this.isBlocked,
  );
}

// ── Product ────────────────────────────────────────────
class Product {
  final String id;
  String name;
  String description;
  String category;
  double price;
  double? comparePrice;   // strike-through "was" price
  int    stock;
  String imageUrl;        // primary image (Unsplash URL or local)
  List<String> images;    // additional images
  String partNumber;
  String brand;
  String compatibility;   // e.g. "Toyota, Nissan, Mitsubishi"
  bool   featured;
  bool   active;
  double rating;
  int    reviewCount;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    this.description   = '',
    required this.category,
    required this.price,
    this.comparePrice,
    this.stock         = 0,
    required this.imageUrl,
    List<String>? images,
    this.partNumber    = '',
    this.brand         = '',
    this.compatibility = '',
    this.featured      = false,
    this.active        = true,
    this.rating        = 0.0,
    this.reviewCount   = 0,
    DateTime? createdAt,
  })  : images    = images ?? [imageUrl],
        createdAt = createdAt ?? DateTime.now();

  bool get inStock  => stock > 0;
  bool get onSale   => comparePrice != null && comparePrice! > price;
  int? get discount => onSale
      ? (((comparePrice! - price) / comparePrice!) * 100).round() : null;

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'description': description,
    'category': category, 'price': price,
    'comparePrice': comparePrice, 'stock': stock,
    'imageUrl': imageUrl, 'images': images,
    'partNumber': partNumber, 'brand': brand,
    'compatibility': compatibility, 'featured': featured,
    'active': active, 'rating': rating, 'reviewCount': reviewCount,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Product.fromJson(Map<String, dynamic> j) => Product(
    id:           j['id'],
    name:         j['name'],
    description:  j['description'] ?? '',
    category:     j['category'],
    price:        (j['price'] as num).toDouble(),
    comparePrice: j['comparePrice'] != null
        ? (j['comparePrice'] as num).toDouble() : null,
    stock:        j['stock'] ?? 0,
    imageUrl:     j['imageUrl'],
    images:       List<String>.from(j['images'] ?? [j['imageUrl']]),
    partNumber:   j['partNumber']   ?? '',
    brand:        j['brand']        ?? '',
    compatibility:j['compatibility']?? '',
    featured:     j['featured']     ?? false,
    active:       j['active']       ?? true,
    rating:       (j['rating'] as num?)?.toDouble() ?? 0.0,
    reviewCount:  j['reviewCount']  ?? 0,
    createdAt: j['createdAt'] != null ? DateTime.tryParse(j['createdAt']) : null,
  );

  Product copyWith({
    String? name, String? description, String? category,
    double? price, double? comparePrice, int? stock,
    String? imageUrl, List<String>? images,
    String? partNumber, String? brand, String? compatibility,
    bool? featured, bool? active, double? rating, int? reviewCount,
    bool clearCompare = false,
  }) => Product(
    id: id, createdAt: createdAt,
    name:         name          ?? this.name,
    description:  description   ?? this.description,
    category:     category      ?? this.category,
    price:        price         ?? this.price,
    comparePrice: clearCompare  ? null : (comparePrice ?? this.comparePrice),
    stock:        stock         ?? this.stock,
    imageUrl:     imageUrl      ?? this.imageUrl,
    images:       images        ?? List.from(this.images),
    partNumber:   partNumber    ?? this.partNumber,
    brand:        brand         ?? this.brand,
    compatibility:compatibility ?? this.compatibility,
    featured:     featured      ?? this.featured,
    active:       active        ?? this.active,
    rating:       rating        ?? this.rating,
    reviewCount:  reviewCount   ?? this.reviewCount,
  );
}

// ── CartItem ───────────────────────────────────────────
class CartItem {
  final Product product;
  int qty;
  CartItem({required this.product, this.qty = 1});
  double get subtotal => product.price * qty;
}

// ── OrderItem ──────────────────────────────────────────
class OrderItem {
  final String productId;
  final String productName;
  final String imageUrl;
  final double price;
  final int    qty;
  final String partNumber;
  final String category;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.price,
    required this.qty,
    this.partNumber = '',
    this.category   = '',
  });

  double get subtotal => price * qty;

  Map<String, dynamic> toJson() => {
    'productId': productId, 'productName': productName,
    'imageUrl': imageUrl, 'price': price, 'qty': qty,
    'partNumber': partNumber, 'category': category,
  };

  factory OrderItem.fromJson(Map<String, dynamic> j) => OrderItem(
    productId:   j['productId'],
    productName: j['productName'],
    imageUrl:    j['imageUrl'],
    price:       (j['price'] as num).toDouble(),
    qty:         j['qty'],
    partNumber:  j['partNumber'] ?? '',
    category:    j['category']   ?? '',
  );
}

// ── Order ──────────────────────────────────────────────
class AppOrder {
  final String id;
  final String userId;
  final String userPhone;
  String userName;
  String deliveryAddress;
  String notes;
  final List<OrderItem> items;
  String status;
  String paymentMethod;
  bool   paymentConfirmed;
  String waSent;   // 'pending' | 'sent' | 'failed'
  String trackingNumber;
  final DateTime createdAt;
  DateTime updatedAt;

  AppOrder({
    required this.id,
    required this.userId,
    required this.userPhone,
    this.userName          = '',
    this.deliveryAddress   = '',
    this.notes             = '',
    required this.items,
    this.status            = 'Pending',
    this.paymentMethod     = 'Cash on Delivery',
    this.paymentConfirmed  = false,
    this.waSent            = 'pending',
    this.trackingNumber    = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  double get total     => items.fold(0, (s, i) => s + i.subtotal);
  int    get itemCount => items.fold(0, (s, i) => s + i.qty);

  Map<String, dynamic> toJson() => {
    'id': id, 'userId': userId, 'userPhone': userPhone,
    'userName': userName, 'deliveryAddress': deliveryAddress,
    'notes': notes, 'status': status,
    'paymentMethod': paymentMethod,
    'paymentConfirmed': paymentConfirmed,
    'waSent': waSent, 'trackingNumber': trackingNumber,
    'items': items.map((i) => i.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory AppOrder.fromJson(Map<String, dynamic> j) => AppOrder(
    id:              j['id'],
    userId:          j['userId'],
    userPhone:       j['userPhone'],
    userName:        j['userName']        ?? '',
    deliveryAddress: j['deliveryAddress'] ?? '',
    notes:           j['notes']           ?? '',
    status:          j['status']          ?? 'Pending',
    paymentMethod:   j['paymentMethod']   ?? 'Cash on Delivery',
    paymentConfirmed:j['paymentConfirmed']?? false,
    waSent:          j['waSent']          ?? 'pending',
    trackingNumber:  j['trackingNumber']  ?? '',
    items: (j['items'] as List)
        .map((i) => OrderItem.fromJson(i as Map<String, dynamic>))
        .toList(),
    createdAt: j['createdAt'] != null ? DateTime.tryParse(j['createdAt']) : null,
    updatedAt: j['updatedAt'] != null ? DateTime.tryParse(j['updatedAt']) : null,
  );
}

// ── Notification ───────────────────────────────────────
class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type;   // 'order' | 'promo' | 'info'
  bool   read;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.type = 'info',
    this.read = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'body': body,
    'type': type, 'read': read,
    'createdAt': createdAt.toIso8601String(),
  };

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
    id:        j['id'],
    title:     j['title'],
    body:      j['body'],
    type:      j['type'] ?? 'info',
    read:      j['read'] ?? false,
    createdAt: j['createdAt'] != null ? DateTime.tryParse(j['createdAt']) : null,
  );
}
