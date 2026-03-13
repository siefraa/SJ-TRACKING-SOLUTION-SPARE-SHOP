import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/app_state.dart';
import '../../utils/theme.dart';
import '../../utils/constants.dart';
import '../../widgets/widgets.dart';
import '../../models/models.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});
  @override State<ProductDetailScreen> createState() => _PDState();
}

class _PDState extends State<ProductDetailScreen> {
  int _qty = 1;
  int _imgIdx = 0;
  final _pageCtrl = PageController();

  @override void dispose() { _pageCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final p  = widget.product;

    return Scaffold(
      backgroundColor: C.bg,
      body: CustomScrollView(slivers: [
        // ── Hero image ────────────────────────────────────────────
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          backgroundColor: C.bg,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(fit: StackFit.expand, children: [
              PageView.builder(
                controller: _pageCtrl,
                itemCount: p.images.isEmpty ? 1 : p.images.length,
                onPageChanged: (i) => setState(() => _imgIdx = i),
                itemBuilder: (_, i) => PImage(
                  p.images.isEmpty ? p.imageUrl : p.images[i],
                  fit: BoxFit.cover)),
              // Image dots
              if (p.images.length > 1)
                Positioned(bottom: 14, left: 0, right: 0,
                  child: Row(mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(p.images.length, (i) =>
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: _imgIdx == i ? 16 : 6, height: 6,
                        decoration: BoxDecoration(
                          color: _imgIdx == i ? C.orange : C.text3,
                          borderRadius: BorderRadius.circular(3)))))),
              // Discount badge
              if (p.discount != null) Positioned(top: 12, right: 12,
                child: DiscountBadge(p.discount!)),
            ]),
          ),
          actions: [
            // Admin edit shortcut
            if (st.isAdmin)
              IconButton(
                icon: Container(padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: C.card.withOpacity(.8),
                    borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.edit_outlined,
                    size: 18, color: C.orange)),
                onPressed: () => Navigator.pop(context)),
          ],
        ),

        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(delegate: SliverChildListDelegate([

            // ── Name + brand ──────────────────────────────────────
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: C.orange.withOpacity(.12),
                    borderRadius: BorderRadius.circular(8)),
                  child: Text(p.category, style: const TextStyle(
                    color: C.orange, fontSize: 11, fontWeight: FontWeight.w600))),
                const SizedBox(height: 8),
                Text(p.name, style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800, color: C.text)),
                if (p.brand.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(p.brand, style: const TextStyle(
                    color: C.text2, fontSize: 13)),
                ],
              ])),
              if (p.featured)
                Container(padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: C.amber.withOpacity(.15),
                    borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.star_rounded, color: C.amber, size: 20)),
            ]),
            const SizedBox(height: 12),

            // ── Rating ────────────────────────────────────────────
            RatingRow(rating: p.rating, count: p.reviewCount),
            const SizedBox(height: 14),

            // ── Price ─────────────────────────────────────────────
            Row(children: [
              PriceText(p.price, compare: p.comparePrice, fontSize: 24),
              const Spacer(),
              // Stock indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: p.inStock
                    ? C.green.withOpacity(.12) : C.red.withOpacity(.12),
                  borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  Icon(Icons.circle, size: 8,
                    color: p.inStock ? C.green : C.red),
                  const SizedBox(width: 5),
                  Text(p.inStock ? '${p.stock} in stock' : 'Out of stock',
                    style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600,
                      color: p.inStock ? C.green : C.red)),
                ])),
            ]),
            const SizedBox(height: 16),

            // ── Part details card ─────────────────────────────────
            DCard(child: Column(children: [
              _row(Icons.tag, 'Part Number', p.partNumber.isNotEmpty ? p.partNumber : '—'),
              const Divider(color: C.border, height: 1),
              _row(Icons.directions_car, 'Compatible With',
                p.compatibility.isNotEmpty ? p.compatibility : '—'),
              const Divider(color: C.border, height: 1),
              _row(Icons.inventory_2_outlined, 'Stock', '${p.stock} units'),
            ])),
            const SizedBox(height: 14),

            // ── Description ───────────────────────────────────────
            if (p.description.isNotEmpty) ...[
              const Text('Description', style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w700, color: C.text)),
              const SizedBox(height: 8),
              Text(p.description,
                style: const TextStyle(color: C.text2, height: 1.6, fontSize: 14)),
              const SizedBox(height: 16),
            ],

            // ── Qty picker ────────────────────────────────────────
            if (p.inStock) ...[
              Row(children: [
                const Text('Quantity',
                  style: TextStyle(color: C.text2, fontSize: 13)),
                const Spacer(),
                _qtyBtn(Icons.remove, () {
                  if (_qty > 1) setState(() => _qty--);
                }),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('$_qty', style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800, color: C.text))),
                _qtyBtn(Icons.add, () {
                  if (_qty < p.stock) setState(() => _qty++);
                }),
              ]),
              const SizedBox(height: 20),
            ],

            // ── WA inquiry button ─────────────────────────────────
            WaButton(
              label: 'Ask about this part on WhatsApp',
              onTap: () => _waInquiry(p)),
            const SizedBox(height: 100),
          ])),
        ),
      ]),

      // ── Bottom add-to-cart ─────────────────────────────────────
      bottomNavigationBar: p.inStock ? Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        decoration: const BoxDecoration(
          color: C.bg2,
          border: Border(top: BorderSide(color: C.border))),
        child: Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Total', style: TextStyle(color: C.text2, fontSize: 11)),
            PriceText(widget.product.price * _qty, fontSize: 20),
          ]),
          const SizedBox(width: 16),
          Expanded(child: GradBtnFull(
            label: 'Add to Cart',
            icon: Icons.shopping_cart_outlined,
            onTap: () {
              context.read<AppState>().addToCart(widget.product, qty: _qty);
              toast(context, 'Added to cart! 🛒');
              Navigator.pop(context);
            })),
        ]),
      ) : null,
    );
  }

  Widget _row(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
    child: Row(children: [
      Icon(icon, size: 16, color: C.orange),
      const SizedBox(width: 10),
      Text(label, style: const TextStyle(color: C.text2, fontSize: 13)),
      const Spacer(),
      Flexible(child: Text(value,
        style: const TextStyle(color: C.text, fontSize: 13,
          fontWeight: FontWeight.w600),
        textAlign: TextAlign.end, maxLines: 2)),
    ]));

  Widget _qtyBtn(IconData icon, VoidCallback fn) => GestureDetector(
    onTap: fn,
    child: Container(
      width: 34, height: 34,
      decoration: BoxDecoration(color: C.card2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: C.border)),
      child: Icon(icon, size: 16, color: C.text)));

  Future<void> _waInquiry(Product p) async {
    final msg = Uri.encodeComponent(
      'Hi SJ Tracking! I need info about:\n'
      '${p.name}\nPart #: ${p.partNumber}\nPrice: ${PriceText.fmtPrice(p.price)}');
    final url = Uri.parse('https://wa.me/${AppConf.waNumber}?text=$msg');
    if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
  }
}
