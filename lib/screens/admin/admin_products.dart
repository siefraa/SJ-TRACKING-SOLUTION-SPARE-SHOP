import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/app_state.dart';
import '../../utils/theme.dart';
import '../../utils/constants.dart';
import '../../widgets/widgets.dart';
import '../../models/models.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});
  @override State<AdminProductsScreen> createState() => _APState();
}

class _APState extends State<AdminProductsScreen> {
  final _q = TextEditingController();
  bool _searchOpen = false;

  @override void dispose() { _q.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    var prods = st.allProducts;
    if (_q.text.isNotEmpty) {
      final lq = _q.text.toLowerCase();
      prods = prods.where((p) =>
        p.name.toLowerCase().contains(lq) ||
        p.category.toLowerCase().contains(lq) ||
        p.partNumber.toLowerCase().contains(lq)).toList();
    }
    prods.sort((a,b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        title: _searchOpen
          ? TextField(controller: _q, autofocus: true,
              style: const TextStyle(color: C.text),
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Search products…',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero))
          : const Text('Products', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: Icon(_searchOpen ? Icons.close : Icons.search, color: C.text2),
            onPressed: () => setState(() {
              _searchOpen = !_searchOpen;
              if (!_searchOpen) { _q.clear(); }
            })),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: C.orange, size: 24),
            onPressed: () => _openForm(context, null)),
        ],
      ),
      body: Column(children: [
        // Stats bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(children: [
            _stat('${prods.length}', 'Total'),
            _stat('${prods.where((p) => p.active).length}', 'Active'),
            _stat('${prods.where((p) => p.featured).length}', 'Featured'),
            _stat('${prods.where((p) => p.stock < 3).length}', 'Low Stock',
              color: C.amber),
          ])),

        Expanded(child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          itemCount: prods.length,
          itemBuilder: (_, i) => _productRow(context, st, prods[i]))),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context, null),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Product',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
    );
  }

  Widget _stat(String val, String label, {Color? color}) => Expanded(child: Column(children: [
    Text(val, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
      color: color ?? C.orange)),
    Text(label, style: const TextStyle(color: C.text3, fontSize: 10)),
  ]));

  Widget _productRow(BuildContext ctx, AppState st, Product p) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(color: C.card,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: p.active ? C.border : C.border.withOpacity(.4))),
    child: Row(children: [
      // Image
      ClipRRect(borderRadius: const BorderRadius.horizontal(left: Radius.circular(13)),
        child: Opacity(opacity: p.active ? 1 : .45,
          child: PImage(p.imageUrl, width: 80, height: 80))),
      Expanded(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(p.name, style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w700,
            color: p.active ? C.text : C.text3),
            maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(p.category,
            style: const TextStyle(color: C.orange, fontSize: 10.5)),
          const SizedBox(height: 4),
          Row(children: [
            PriceText(p.price, fontSize: 13),
            const SizedBox(width: 8),
            _stockBadge(p.stock),
          ]),
        ]))),
      // Actions column
      Column(mainAxisAlignment: MainAxisAlignment.center,
        children: [
        _iconBtn(Icons.edit_outlined,   C.blue, () => _openForm(ctx, p)),
        _iconBtn(Icons.star_outline,    p.featured ? C.amber : C.text3,
          () => st.toggleFeatured(p.id)),
        _iconBtn(p.active ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          p.active ? C.text3 : C.green,
          () => st.toggleActive(p.id)),
        _iconBtn(Icons.delete_outline, C.red, () => _confirmDelete(ctx, st, p)),
      ]),
    ]));

  Widget _stockBadge(int stock) {
    final color = stock <= 0 ? C.red : stock < 3 ? C.amber : C.green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(6)),
      child: Text('$stock in stock',
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)));
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback fn) => GestureDetector(
    onTap: fn,
    child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Icon(icon, size: 20, color: color)));

  void _openForm(BuildContext ctx, Product? existing) =>
    Navigator.push(ctx, MaterialPageRoute(
      builder: (_) => ProductFormScreen(existing: existing)));

  Future<void> _confirmDelete(BuildContext ctx, AppState st, Product p) async {
    final ok = await showDialog<bool>(context: ctx, builder: (_) => AlertDialog(
      backgroundColor: C.card,
      title: const Text('Delete Product?', style: TextStyle(color: C.text)),
      content: Text('This will permanently delete "${p.name}".',
        style: const TextStyle(color: C.text2)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Delete', style: TextStyle(color: C.red,
            fontWeight: FontWeight.w700))),
      ]));
    if (ok == true) {
      await st.deleteProduct(p.id);
      if (ctx.mounted) toast(ctx, 'Product deleted', color: C.red);
    }
  }
}

// ═══════════════════════════════════════════════
//  Product Form (Add / Edit)
// ═══════════════════════════════════════════════
class ProductFormScreen extends StatefulWidget {
  final Product? existing;
  const ProductFormScreen({super.key, this.existing});
  @override State<ProductFormScreen> createState() => _PFState();
}

class _PFState extends State<ProductFormScreen> {
  final _fk    = GlobalKey<FormState>();
  late final _nameC   = TextEditingController(text: widget.existing?.name ?? '');
  late final _descC   = TextEditingController(text: widget.existing?.description ?? '');
  late final _priceC  = TextEditingController(
    text: widget.existing?.price.toStringAsFixed(0) ?? '');
  late final _wasC    = TextEditingController(
    text: widget.existing?.comparePrice?.toStringAsFixed(0) ?? '');
  late final _stockC  = TextEditingController(
    text: widget.existing?.stock.toString() ?? '0');
  late final _partC   = TextEditingController(text: widget.existing?.partNumber ?? '');
  late final _brandC  = TextEditingController(text: widget.existing?.brand ?? '');
  late final _compatC = TextEditingController(text: widget.existing?.compatibility ?? '');
  late final _imgC    = TextEditingController(text: widget.existing?.imageUrl ?? '');

  String _category = AppConf.categories.first;
  bool   _featured = false;
  bool   _active   = true;
  bool   _saving   = false;

  @override void initState() {
    super.initState();
    if (widget.existing != null) {
      _category = widget.existing!.category;
      _featured = widget.existing!.featured;
      _active   = widget.existing!.active;
    }
  }

  @override void dispose() {
    for (final c in [_nameC,_descC,_priceC,_wasC,_stockC,
                     _partC,_brandC,_compatC,_imgC]) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Product' : 'Add Product',
          style: const TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => _save(context),
            child: Text(_saving ? 'Saving…' : 'Save',
              style: const TextStyle(color: C.orange,
                fontWeight: FontWeight.w800, fontSize: 15))),
        ],
      ),
      body: Form(key: _fk, child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Image preview + picker
          GestureDetector(
            onTap: () => _pickImage(context),
            child: Container(
              height: 180,
              decoration: BoxDecoration(color: C.card2,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: C.border)),
              child: _imgC.text.isNotEmpty
                ? ClipRRect(borderRadius: BorderRadius.circular(15),
                    child: PImage(_imgC.text, height: 180, width: double.infinity))
                : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.add_photo_alternate_outlined,
                      color: C.orange, size: 42),
                    const SizedBox(height: 8),
                    const Text('Tap to add product image',
                      style: TextStyle(color: C.text2)),
                    const SizedBox(height: 4),
                    const Text('Camera · Gallery · Paste URL',
                      style: TextStyle(color: C.text3, fontSize: 11)),
                  ]))),
          const SizedBox(height: 8),
          // Image URL field
          TextFormField(
            controller: _imgC,
            style: const TextStyle(color: C.text, fontSize: 12),
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Image URL (or pick from gallery)',
              prefixIcon: Icon(Icons.link, color: C.text2, size: 18))),
          const SizedBox(height: 16),

          _section('Product Info'),
          _field(_nameC,  'Product Name *', required: true),
          _field(_descC,  'Description', lines: 3),
          _dropdown('Category', _category, AppConf.categories,
            (v) => setState(() => _category = v!)),
          const SizedBox(height: 4),

          _section('Parts Details'),
          _field(_partC,   'Part Number'),
          _field(_brandC,  'Brand'),
          _field(_compatC, 'Compatible With (Toyota, Nissan…)', lines: 2),

          _section('Pricing & Stock'),
          Row(children: [
            Expanded(child: _field(_priceC, 'Price (TSh) *',
              type: TextInputType.number, required: true)),
            const SizedBox(width: 10),
            Expanded(child: _field(_wasC, 'Was Price (optional)',
              type: TextInputType.number)),
          ]),
          _field(_stockC, 'Stock Quantity *',
            type: TextInputType.number, required: true),

          const SizedBox(height: 16),
          _section('Options'),
          // Featured + Active switches
          DCard(child: Column(children: [
            SwitchListTile(
              value: _featured,
              onChanged: (v) => setState(() => _featured = v),
              title: const Text('Featured Product',
                style: TextStyle(color: C.text, fontSize: 14)),
              subtitle: const Text('Show on homepage',
                style: TextStyle(color: C.text2, fontSize: 11)),
              activeColor: C.amber,
              contentPadding: EdgeInsets.zero),
            const Divider(color: C.border, height: 1),
            SwitchListTile(
              value: _active,
              onChanged: (v) => setState(() => _active = v),
              title: const Text('Active / Visible',
                style: TextStyle(color: C.text, fontSize: 14)),
              subtitle: const Text('Hide from shop if inactive',
                style: TextStyle(color: C.text2, fontSize: 11)),
              activeColor: C.green,
              contentPadding: EdgeInsets.zero),
          ])),

          const SizedBox(height: 24),
          GradBtnFull(
            label: isEdit ? 'Update Product' : 'Add Product',
            icon: Icons.save_outlined,
            busy: _saving,
            onTap: () => _save(context)),
          const SizedBox(height: 40),
        ],
      )),
    );
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 10, top: 4),
    child: Text(title, style: const TextStyle(
      fontSize: 13, color: C.orange, fontWeight: FontWeight.w700,
      letterSpacing: .5)));

  Widget _field(TextEditingController c, String label, {
    bool required = false, int lines = 1,
    TextInputType? type,
  }) => Padding(padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: c, maxLines: lines,
      keyboardType: type,
      style: const TextStyle(color: C.text),
      decoration: InputDecoration(labelText: label),
      validator: required
        ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null : null));

  Widget _dropdown(String label, String val, List<String> items, void Function(String?) fn) =>
    Padding(padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: val,
        dropdownColor: C.card2,
        style: const TextStyle(color: C.text),
        decoration: InputDecoration(labelText: label),
        items: items.map((i) => DropdownMenuItem(value: i,
          child: Text(i, style: const TextStyle(fontSize: 13)))).toList(),
        onChanged: fn));

  Future<void> _pickImage(BuildContext ctx) async {
    final src = await showModalBottomSheet<String>(
      context: ctx, backgroundColor: C.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(leading: const Icon(Icons.camera_alt, color: C.orange),
            title: const Text('Camera', style: TextStyle(color: C.text)),
            onTap: () => Navigator.pop(ctx, 'camera')),
          ListTile(leading: const Icon(Icons.photo_library_outlined, color: C.blue),
            title: const Text('Gallery', style: TextStyle(color: C.text)),
            onTap: () => Navigator.pop(ctx, 'gallery')),
        ])));
    if (src == null) return;
    final path = await context.read<AppState>().pickAndSaveImage(
      src == 'camera' ? ImageSource.camera : ImageSource.gallery);
    if (path != null) setState(() => _imgC.text = path);
  }

  Future<void> _save(BuildContext ctx) async {
    if (!(_fk.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final st = ctx.read<AppState>();
    final price = double.tryParse(_priceC.text.trim()) ?? 0;
    final was   = double.tryParse(_wasC.text.trim());
    final stock = int.tryParse(_stockC.text.trim()) ?? 0;

    try {
      if (widget.existing != null) {
        await st.updateProduct(widget.existing!.copyWith(
          name:          _nameC.text.trim(),
          description:   _descC.text.trim(),
          category:      _category,
          price:         price,
          comparePrice:  was,
          stock:         stock,
          imageUrl:      _imgC.text.trim(),
          images:        _imgC.text.trim().isNotEmpty ? [_imgC.text.trim()] : null,
          partNumber:    _partC.text.trim(),
          brand:         _brandC.text.trim(),
          compatibility: _compatC.text.trim(),
          featured:      _featured,
          active:        _active,
          clearCompare:  was == null,
        ));
        if (ctx.mounted) { toast(ctx, 'Product updated!'); Navigator.pop(ctx); }
      } else {
        final p = Product(
          id: const Uuid().v4(),
          name:          _nameC.text.trim(),
          description:   _descC.text.trim(),
          category:      _category,
          price:         price,
          comparePrice:  was,
          stock:         stock,
          imageUrl:      _imgC.text.trim().isNotEmpty
            ? _imgC.text.trim()
            : 'https://images.unsplash.com/photo-1558981408-db0ecd8a1ee4?w=600',
          partNumber:    _partC.text.trim(),
          brand:         _brandC.text.trim(),
          compatibility: _compatC.text.trim(),
          featured:      _featured,
          active:        _active,
        );
        await st.addProduct(p);
        if (ctx.mounted) { toast(ctx, 'Product added! ✅'); Navigator.pop(ctx); }
      }
    } catch (e) {
      if (ctx.mounted) toast(ctx, 'Error: $e', color: C.red);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
