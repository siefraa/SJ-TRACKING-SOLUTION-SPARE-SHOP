import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';

// ══════════════════════════════════════════════════════
//  Shared widgets
// ══════════════════════════════════════════════════════

// ── Product image — handles network, file://, placeholder ─────────
class PImage extends StatelessWidget {
  final String url;
  final double? width, height;
  final BoxFit  fit;
  final BorderRadius? radius;

  const PImage(this.url, {
    super.key,
    this.width,
    this.height,
    this.fit    = BoxFit.cover,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    Widget img;
    if (url.startsWith('file://')) {
      final f = File(url.substring(7));
      img = Image.file(f, width: width, height: height, fit: fit,
        errorBuilder: (_, __, ___) => _placeholder());
    } else if (url.startsWith('http')) {
      img = CachedNetworkImage(
        imageUrl: url, width: width, height: height, fit: fit,
        placeholder: (_, __) => _loading(),
        errorWidget: (_, __, ___) => _placeholder(),
      );
    } else {
      img = _placeholder();
    }
    if (radius != null) {
      return ClipRRect(borderRadius: radius!, child: img);
    }
    return img;
  }

  Widget _loading() => Container(
    width: width, height: height,
    color: C.card2,
    child: const Center(child: CircularProgressIndicator(
      color: C.orange, strokeWidth: 2)));

  Widget _placeholder() => Container(
    width: width, height: height,
    color: C.card2,
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.car_repair, color: C.orange.withOpacity(.4), size: 40),
      const SizedBox(height: 4),
      Text('No Image', style: TextStyle(color: C.text3, fontSize: 11)),
    ]));
}

// ── Gradient Button ────────────────────────────────────────────────
class GradBtn extends StatelessWidget {
  final String  label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool    busy;
  final Color?  color;
  final bool    outlined;
  final bool    small;

  const GradBtn({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.busy    = false,
    this.color,
    this.outlined = false,
    this.small   = false,
  });

  @override
  Widget build(BuildContext context) {
    final h  = small ? 40.0 : 52.0;
    final fs = small ? 12.0 : 14.0;
    final col = color ?? C.orange;

    return GestureDetector(
      onTap: (busy || onTap == null) ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: h,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: outlined ? null : LinearGradient(
            colors: [col, Color.lerp(col, Colors.amber, .3)!],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
          border: outlined ? Border.all(color: col, width: 1.5) : null,
          borderRadius: BorderRadius.circular(14),
          boxShadow: outlined ? null : C.glow(col),
        ),
        child: Center(child: busy
          ? const SizedBox(width: 20, height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : Row(mainAxisSize: MainAxisSize.min, children: [
              if (icon != null) ...[
                Icon(icon, size: small ? 15 : 18,
                  color: outlined ? col : Colors.white),
                SizedBox(width: small ? 6 : 8),
              ],
              Text(label, style: TextStyle(
                fontSize: fs, fontWeight: FontWeight.w700,
                color: outlined ? col : Colors.white, letterSpacing: .3)),
            ])),
      ),
    );
  }
}

// Full-width gradient button
class GradBtnFull extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool busy;
  final Color? color;

  const GradBtnFull({
    super.key, required this.label, this.icon,
    this.onTap, this.busy = false, this.color,
  });

  @override
  Widget build(BuildContext ctx) => SizedBox(
    width: double.infinity,
    child: GradBtn(label: label, icon: icon, onTap: onTap, busy: busy, color: color));
}

// ── Section header ─────────────────────────────────────────────────
class SectionHead extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHead(this.title, {super.key, this.action, this.onAction});

  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: Text(title, style: const TextStyle(
      fontSize: 18, fontWeight: FontWeight.w800, color: C.text))),
    if (action != null)
      GestureDetector(onTap: onAction,
        child: Text(action!, style: const TextStyle(
          color: C.orange, fontSize: 13, fontWeight: FontWeight.w600))),
  ]);
}

// ── Status chip ────────────────────────────────────────────────────
class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip(this.status, {super.key});

  static Color _color(String s) => switch (s) {
    'Pending'    => C.amber,
    'Confirmed'  => C.blue,
    'Processing' => C.purple,
    'Shipped'    => C.teal,
    'Delivered'  => C.green,
    'Cancelled'  => C.red,
    _            => C.text2,
  };

  @override
  Widget build(BuildContext context) {
    final col = _color(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: col.withOpacity(.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: col.withOpacity(.4))),
      child: Text(status, style: TextStyle(
        color: col, fontSize: 11, fontWeight: FontWeight.w700)));
  }
}

// ── Price display ──────────────────────────────────────────────────
class PriceText extends StatelessWidget {
  final double price;
  final double? compare;
  final double fontSize;

  const PriceText(this.price, {super.key, this.compare, this.fontSize = 16});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min, children: [
    Text(fmtPrice(price), style: TextStyle(
      fontSize: fontSize, fontWeight: FontWeight.w800, color: C.orange)),
    if (compare != null && compare! > price) ...[
      const SizedBox(width: 6),
      Text(fmtPrice(compare!), style: TextStyle(
        fontSize: fontSize - 3, color: C.text3,
        decoration: TextDecoration.lineThrough)),
    ],
  ]);

  static String fmtPrice(double v) =>
    'TSh ${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
}

// ── Discount badge ─────────────────────────────────────────────────
class DiscountBadge extends StatelessWidget {
  final int pct;
  const DiscountBadge(this.pct, {super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(color: C.red, borderRadius: BorderRadius.circular(8)),
    child: Text('-$pct%',
      style: const TextStyle(color: Colors.white, fontSize: 11,
        fontWeight: FontWeight.w800)));
}

// ── Rating stars ───────────────────────────────────────────────────
class RatingRow extends StatelessWidget {
  final double rating;
  final int    count;

  const RatingRow({super.key, required this.rating, required this.count});

  @override
  Widget build(BuildContext context) => Row(children: [
    ...List.generate(5, (i) => Icon(
      i < rating.floor() ? Icons.star_rounded
      : i < rating       ? Icons.star_half_rounded
      : Icons.star_border_rounded,
      color: C.amber, size: 14)),
    const SizedBox(width: 5),
    Text('($count)', style: const TextStyle(color: C.text2, fontSize: 11)),
  ]);
}

// ── Toast helper ───────────────────────────────────────────────────
void toast(BuildContext ctx, String msg, {Color? color}) =>
  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
    content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
    backgroundColor: color ?? C.green,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    duration: const Duration(seconds: 2)));

// ── Admin gate: show child only to admins ──────────────────────────
class AdminOnly extends StatelessWidget {
  final bool isAdmin;
  final Widget child;
  final Widget? fallback;

  const AdminOnly({
    super.key, required this.isAdmin,
    required this.child, this.fallback,
  });

  @override
  Widget build(BuildContext context) =>
    isAdmin ? child : (fallback ?? const SizedBox.shrink());
}

// ── Shimmer loading card ───────────────────────────────────────────
class ShimmerCard extends StatefulWidget {
  final double height;
  const ShimmerCard({super.key, this.height = 200});
  @override State<ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;

  @override void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _a = Tween(begin: .3, end: .8).animate(_c);
  }

  @override void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _a,
    builder: (_, __) => Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: C.card2.withOpacity(_a.value),
        borderRadius: BorderRadius.circular(16))));
}

// ── WhatsApp chat button ───────────────────────────────────────────
class WaButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const WaButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF25D366).withOpacity(.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF25D366).withOpacity(.4))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Text('💬', style: TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(
          color: Color(0xFF25D366), fontWeight: FontWeight.w700, fontSize: 13)),
      ])));
}

// ── Card container ─────────────────────────────────────────────────
class DCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? color;

  const DCard({super.key, required this.child, this.padding, this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: padding ?? const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color ?? C.card,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: C.border)),
    child: child);
}
