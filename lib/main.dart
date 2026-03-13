import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'utils/theme.dart';
import 'utils/constants.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/shared/home_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor:        Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..init(),
      child: const SjApp(),
    ),
  );
}

class SjApp extends StatelessWidget {
  const SjApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConf.appName,
      debugShowCheckedModeBanner: false,
      theme: C.theme,
      home: const _Root(),
    );
  }
}

class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();

    // Loading splash
    if (!st.isAuth && st.allProducts.isEmpty) {
      return const _SplashScreen();
    }

    // Auth wall
    if (!st.isAuth) return const AuthScreen();

    // Routed by role
    return st.isAdmin ? const AdminShell() : const UserShell();
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: C.bg,
    body: Center(child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo
        Container(
          width: 110, height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: C.brandGrad,
            boxShadow: C.glow(C.orange, b: 32)),
          child: const Center(child: Text('⚙️',
            style: TextStyle(fontSize: 56)))),
        const SizedBox(height: 24),
        const Text(AppConf.appName,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900,
            color: C.text, letterSpacing: 1.2)),
        const SizedBox(height: 6),
        const Text(AppConf.tagline,
          style: TextStyle(color: C.text2, fontSize: 14)),
        const SizedBox(height: 40),
        const CircularProgressIndicator(color: C.orange, strokeWidth: 2.5),
      ],
    )),
  );
}
