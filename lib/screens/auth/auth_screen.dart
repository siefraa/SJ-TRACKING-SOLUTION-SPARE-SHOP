import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../utils/theme.dart';
import '../../utils/constants.dart';
import '../../widgets/widgets.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _phoneC = TextEditingController();
  final _otpC   = List.generate(6, (_) => TextEditingController());
  final _otpF   = List.generate(6, (_) => FocusNode());

  @override void dispose() {
    _phoneC.dispose();
    for (final c in _otpC) c.dispose();
    for (final f in _otpF) f.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    final st = context.watch<AppState>();
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(children: [
            const SizedBox(height: 20),
            // ── Logo ─────────────────────────────────────────────
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: C.brandGrad,
                boxShadow: C.glow(C.orange, b: 28)),
              child: const Center(
                child: Text('⚙️', style: TextStyle(fontSize: 48)))),
            const SizedBox(height: 18),
            const Text(AppConf.appName, style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w900, color: C.text,
              letterSpacing: 1)),
            const SizedBox(height: 4),
            const Text(AppConf.tagline, style: TextStyle(
              color: C.text2, fontSize: 13)),

            const SizedBox(height: 36),

            // ── Auth card ─────────────────────────────────────────
            DCard(child: st.otpStep
              ? _otpPanel(ctx, st)
              : _phonePanel(ctx, st)),

            const SizedBox(height: 16),
            // ── Demo hint ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: C.amber.withOpacity(.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: C.amber.withOpacity(.3))),
              child: const Text(
                '🔑  Demo mode — use any phone + OTP: 123456\n'
                '👑  Admin phone: +255700000001',
                style: TextStyle(color: C.amber, fontSize: 12),
                textAlign: TextAlign.center)),
          ]),
        ),
      ),
    );
  }

  Widget _phonePanel(BuildContext ctx, AppState st) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Login / Register', style: TextStyle(
        fontSize: 20, fontWeight: FontWeight.w800, color: C.text)),
      const SizedBox(height: 4),
      const Text('Enter your phone number to continue',
        style: TextStyle(color: C.text2, fontSize: 13)),
      const SizedBox(height: 20),

      TextFormField(
        controller: _phoneC,
        keyboardType: TextInputType.phone,
        style: const TextStyle(color: C.text, fontSize: 16),
        decoration: const InputDecoration(
          labelText: 'Phone Number',
          hintText: '+255 7XX XXX XXX',
          prefixIcon: Icon(Icons.phone_outlined, color: C.text2)),
      ),
      const SizedBox(height: 16),

      if (st.authErr != null)
        Padding(padding: const EdgeInsets.only(bottom: 12),
          child: Text(st.authErr!, style: const TextStyle(color: C.red, fontSize: 13))),

      SizedBox(width: double.infinity,
        child: GradBtnFull(
          label: 'Send OTP Code',
          icon: Icons.send_outlined,
          busy: st.busy,
          onTap: () {
            final p = _phoneC.text.trim();
            if (p.length >= 8) st.requestOtp(p);
          })),
    ]);

  Widget _otpPanel(BuildContext ctx, AppState st) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [
        IconButton(
          onPressed: st.busy ? null : () => st.resetOtp(),
          icon: const Icon(Icons.arrow_back_ios, size: 18, color: C.text2)),
        const SizedBox(width: 4),
        const Text('Enter OTP', style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w800, color: C.text)),
      ]),
      const SizedBox(height: 4),
      Text('Code sent to ${st.pendPhone}',
        style: const TextStyle(color: C.text2, fontSize: 13)),
      const SizedBox(height: 22),

      // OTP boxes
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(6, (i) => SizedBox(
          width: 46, height: 54,
          child: TextField(
            controller: _otpC[i], focusNode: _otpF[i],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: C.text),
            decoration: InputDecoration(
              counterText: '',
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: C.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: C.orange, width: 2)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: C.border)),
              filled: true, fillColor: C.card2),
            onChanged: (v) {
              if (v.isNotEmpty && i < 5)
                FocusScope.of(ctx).requestFocus(_otpF[i+1]);
              else if (v.isEmpty && i > 0)
                FocusScope.of(ctx).requestFocus(_otpF[i-1]);
              if (i == 5 && v.isNotEmpty) _verify(ctx, st);
            },
          )))),

      const SizedBox(height: 16),
      if (st.authErr != null)
        Padding(padding: const EdgeInsets.only(bottom: 12),
          child: Text(st.authErr!, style: const TextStyle(color: C.red, fontSize: 13))),

      GradBtnFull(
        label: 'Verify & Login',
        icon: Icons.verified_outlined,
        busy: st.busy,
        color: C.teal,
        onTap: () => _verify(ctx, st)),
    ]);

  Future<void> _verify(BuildContext ctx, AppState st) async {
    final code = _otpC.map((c) => c.text).join();
    if (code.length < 6) return;
    final ok = await st.verifyOtp(code);
    if (!ok && ctx.mounted) {
      for (final c in _otpC) c.clear();
      _otpF[0].requestFocus();
    }
  }
}
