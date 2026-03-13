import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import '../../providers/app_state.dart';
import '../../utils/theme.dart';
import '../../utils/constants.dart';
import '../../widgets/widgets.dart';
import '../../models/models.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});
  @override State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final _search = TextEditingController();
  bool _searchOpen = false;

  @override void dispose() { _search.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();

    return Scaffold(
      backgroundColor: C.bg,
      appBar: _buildAppBar(context, st),
      body: Column(children: [
        if (_searchOpen) _searchBar(st),
        _categoryBar(st),
        _filterRow(context, st),
        Expanded(child: _grid(context, st)),
      ]),
    );
  }

  AppBar _buildAppBar(BuildContext ctx, AppState st) => AppBar(
    leading: Padding(padding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          gradient: C.brandGrad,
          borderRadius: BorderRadius.circular(10)),
        child: const Center(child: Text('⚙️', style: TextStyle(fontSize: 20))))),
    title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(AppConf.appName,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
          color: C.orange, letterSpacing: .5)),
      Text(AppConf.tagline,
        style: TextStyle(fontSize: 10, color: C.text2)),
    ]),
    actions: [
      IconButton(
        icon: Icon(_searchOpen ? Icons.close : Icons.search,
          color: C.text2),
        onPressed: () => setState(() {
          _searchOpen = !_searchOpen;
          if (!_searchOpen) { _search.clear(); st.setSearch(''); }
        })),
      badges.Badge(
        showBadge: st.cartCount > 0,
        badgeContent: Text('${st.cartCount}',
          style: const TextStyle(color: Colors.white, fontSize: 10)),
        badgeStyle: const badges.BadgeStyle(badgeColor: C.orange),
        child: IconButton(
          icon: const Icon(Icons.shopping_cart_outlined, color: C.text2),
          onPressed: () => Navigator.push(ctx,
            MaterialPageRoute(builder: (_) => const CartScreen())))),
    ],
  );

  Widget _searchBar(AppState st) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
    child: TextField(
      controller: _search,
      autofocus: true,
      onChanged: st.setSearch,
      style: const TextStyle(color: C.text),
      decoration: InputDecoration(
        hintText: 'Search parts, brands, part numbers…',
        prefixIcon: const Icon(Icons.search, color: C.text2, size: 20),
        suffixIcon: _search.text.isNotEmpty
          ? IconButton(icon: const Icon(Icons.clear, size: 18, color: C.text2),
            onPressed: () { _search.clear(); st.setSearch(''); })
          : null),
    ));

  Widget _categoryBar(AppState st) => SizedBox(
    height: 44,
    child: ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      children: [
        _catChip(st, '', 'All'),
        ...AppConf.categories.map((c) => _catChip(st, c, c)),
      ]));

  Widget _catChip(AppState st, String val, String label) {
    final sel = st.catFilter == val;
    return GestureDetector(
      onTap: () => st.setCategory(val),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          gradient: sel ? C.brandGrad : null,
          color:    sel ? null : C.card2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: sel ? C.orange : C.border)),
        child: Text(label, style: TextStyle(
          fontSize: 12, fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
          color: sel ? Colors.white : C.text2))));
  }

  Widget _filterRow(BuildContext ctx, AppState st) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: Row(children: [
      Text('${st.filteredProducts.length} parts',
        style: const TextStyle(color: C.text2, fontSize: 12)),
      const Spacer(),
      // Sort
      GestureDetector(
        onTap: () => _sortSheet(ctx, st),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: C.card2,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: C.border)),
          child: Row(children: [
            const Icon(Icons.sort, size: 14, color: C.text2),
            const SizedBox(width: 4),
            Text(_sortLabel(st.sortBy),
              style: const TextStyle(fontSize: 12, color: C.text2)),
          ]))),
      const SizedBox(width: 8),
      // In stock toggle
      GestureDetector(
        onTap: () => st.setInStock(!st.onlyInStock),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: st.onlyInStock ? C.green.withOpacity(.15) : C.card2,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: st.onlyInStock ? C.green : C.border)),
          child: Row(children: [
            Icon(Icons.inventory_2_outlined, size: 14,
              color: st.onlyInStock ? C.green : C.text2),
            const SizedBox(width: 4),
            Text('In stock', style: TextStyle(
              fontSize: 12,
              color: st.onlyInStock ? C.green : C.text2)),
          ]))),
    ]));

  Widget _grid(BuildContext ctx, AppState st) {
    final products = st.filteredProducts;
    if (products.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.car_repair, color: C.orange.withOpacity(.3), size: 72),
        const SizedBox(height: 16),
        const Text('No products found',
          style: TextStyle(color: C.text2, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: st.clearFilters,
          child: const Text('Clear filters',
            style: TextStyle(color: C.orange, fontSize: 13))),
      ]));
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 90),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, childAspectRatio: .68,
        crossAxisSpacing: 10, mainAxisSpacing: 10),
      itemCount: products.length,
      itemBuilder: (_, i) => _productCard(ctx, st, products[i]),
    );
  }

  Widget _productCard(BuildContext ctx, AppState st, Product p) {
    return GestureDetector(
      onTap: () => Navigator.push(ctx,
        MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p))),
      child: Container(
        decoration: BoxDecoration(
          color: C.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: C.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Product image
          Stack(children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: PImage(p.imageUrl,
                height: 145, width: double.infinity)),
            // Badges
            Positioned(top: 8, left: 8,
              child: Column(children: [
                if (p.discount != null) DiscountBadge(p.discount!),
                if (!p.inStock) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: C.red,
                      borderRadius: BorderRadius.circular(6)),
                    child: const Text('Out',
                      style: TextStyle(color: Colors.white,
                        fontSize: 10, fontWeight: FontWeight.w700))),
                ],
              ])),
            if (p.featured) Positioned(top: 8, right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: C.amber,
                  borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.star_rounded, size: 12, color: Colors.black))),
          ]),

          // Info
          Expanded(child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Category
              Text(p.category, style: const TextStyle(
                fontSize: 9.5, color: C.orange, fontWeight: FontWeight.w600),
                maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              // Name
              Text(p.name, style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700, color: C.text),
                maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              // Brand
              if (p.brand.isNotEmpty)
                Text(p.brand, style: const TextStyle(
                  fontSize: 10.5, color: C.text2), maxLines: 1),
              const Spacer(),
              // Price + cart button
              Row(children: [
                Expanded(child: PriceText(p.price,
                  compare: p.comparePrice, fontSize: 13)),
                GestureDetector(
                  onTap: p.inStock
                    ? () { st.addToCart(p); toast(context, 'Added to cart'); }
                    : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: p.inStock ? C.brandGrad : null,
                      color: p.inStock ? null : C.card2,
                      borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.add_shopping_cart_outlined,
                      size: 16,
                      color: p.inStock ? Colors.white : C.text3))),
              ]),
            ])),
          ),
        ]),
      ),
    );
  }

  void _sortSheet(BuildContext ctx, AppState st) => showModalBottomSheet(
    context: ctx, backgroundColor: C.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Sort By', style: TextStyle(
          fontSize: 17, fontWeight: FontWeight.w700, color: C.text)),
        const SizedBox(height: 14),
        ...[('newest','Newest First'),('price_asc','Price: Low to High'),
            ('price_desc','Price: High to Low'),('rating','Best Rating')]
          .map((s) => ListTile(
            leading: Icon(
              st.sortBy == s.$1 ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: st.sortBy == s.$1 ? C.orange : C.text2),
            title: Text(s.$2, style: const TextStyle(color: C.text)),
            onTap: () { st.setSortBy(s.$1); Navigator.pop(ctx); })),
      ])));

  String _sortLabel(String s) => switch(s) {
    'price_asc'  => 'Price ↑',
    'price_desc' => 'Price ↓',
    'rating'     => 'Rating',
    _            => 'Newest',
  };
}
