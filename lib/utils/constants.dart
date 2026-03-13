class AppConf {
  static const appName    = 'SJ TRACKING SOLUTION';
  static const tagline    = 'Quality Car Spare Parts';
  static const currency   = 'TSh';
  static const phone      = '+255712345678';
  static const email      = 'info@sjtracking.co.tz';
  static const address    = 'Kariakoo, Dar es Salaam, Tanzania';
  static const waNumber   = '255712345678'; // no +

  // ── Demo admin phones ──────────────────────────────────────────
  // In production, admins are managed in settings
  static const defaultAdminPhones = <String>['+255700000001'];
  static const demoOtp = '123456';

  // ── WhatsApp SMS Gateway (UltraMsg / Callmebot style) ─────────
  // Admin configures these in Settings
  static const defaultWaApiUrl =
      'https://api.ultramsg.com/instance00000/messages/chat';
  static const defaultWaToken  = 'REPLACE_WITH_YOUR_TOKEN';

  // ── Product categories ─────────────────────────────────────────
  static const categories = [
    'Engine Parts',
    'Brakes & Clutch',
    'Suspension & Steering',
    'Electrical & Ignition',
    'Body Parts',
    'Filters & Fluids',
    'Cooling System',
    'Transmission',
    'Tyres & Wheels',
    'Accessories',
  ];

  // ── Order statuses ─────────────────────────────────────────────
  static const orderStatuses = [
    'Pending', 'Confirmed', 'Processing',
    'Shipped', 'Delivered', 'Cancelled',
  ];

  // ── Payment methods ────────────────────────────────────────────
  static const paymentMethods = [
    'M-Pesa', 'Tigo Pesa', 'Airtel Money',
    'Bank Transfer', 'Cash on Delivery',
  ];
}
