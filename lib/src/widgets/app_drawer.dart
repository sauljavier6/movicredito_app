import 'package:flutter/material.dart';
import 'brand_logo.dart';
import '../features/auth/auth_service.dart';
import '../features/auth/login_page.dart';
import '../features/home/home_page.dart';
import '../features/credit/credit_page.dart';
import '../features/payments/payments_page.dart';
import '../features/device/device_page.dart';
import '../features/documents/documents_page.dart';
import '../features/profile/profile_page.dart';
import '../features/support/support_center_page.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key, this.customer, this.currentSection = 'home'});
  final Map<String, dynamic>? customer;
  final String currentSection;
  @override State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final auth = AuthService();
  Map<String, dynamic>? customer;

  @override
  void initState() {
    super.initState();
    customer = widget.customer;
    if (customer == null) _loadCustomer();
  }

  Future<void> _loadCustomer() async {
    try {
      final data = await auth.me();
      if (mounted) setState(() => customer = data);
    } catch (_) {}
  }

  Future<void> _logout() async {
    await auth.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false);
  }

  void _go(Widget page, String section, {bool detail = false}) {
    Navigator.pop(context);
    if (section == widget.currentSection && !detail) return;
    if (detail) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = customer?['fullName']?.toString() ?? 'Mi cuenta';
    final number = customer?['customerNumber']?.toString() ?? '';
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(children: [
                const BrandLogo(size: 54, borderRadius: 16),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  if (number.isNotEmpty) Text('Cliente $number', style: const TextStyle(color: Color(0xFF667085), fontSize: 12)),
                ])),
              ]),
            ),
            const Divider(height: 1),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 6),
              child: Text('MI CUENTA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: .8, color: Color(0xFF98A2B3))),
            ),
            _item(Icons.home_outlined, 'Inicio', 'home', () => _go(const HomePage(), 'home')),
            _item(Icons.account_balance_wallet_outlined, 'Mi crédito', 'credit', () => _go(const CreditPage(), 'credit', detail: true)),
            _item(Icons.calendar_month_outlined, 'Calendario de pagos', 'calendar', () => _go(const CreditPage(), 'calendar', detail: true)),
            _item(Icons.receipt_long_outlined, 'Pagos y recibos', 'payments', () => _go(const PaymentsPage(), 'payments')),
            _item(Icons.smartphone_outlined, 'Mi equipo', 'device', () => _go(const DevicePage(), 'device')),
            _item(Icons.description_outlined, 'Contrato y documentos', 'documents', () => _go(const DocumentsPage(), 'documents', detail: true)),
            _item(Icons.person_outline_rounded, 'Mi perfil', 'profile', () => _go(const ProfilePage(), 'profile', detail: true)),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 6),
              child: Text('AYUDA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: .8, color: Color(0xFF98A2B3))),
            ),
            _item(Icons.help_outline_rounded, 'Ayuda y soporte', 'support', () => _go(const SupportCenterPage(), 'support', detail: true)),
            const Divider(height: 24),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              leading: const Icon(Icons.logout_rounded, color: Color(0xFF475467)),
              title: const Text('Cerrar sesión', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () async { Navigator.pop(context); await _logout(); },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _item(IconData icon, String label, String section, VoidCallback onTap) {
    final selected = widget.currentSection == section;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
      child: ListTile(
        selected: selected,
        selectedTileColor: const Color(0xFFEEF4FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        leading: Icon(icon, color: selected ? const Color(0xFF175CD3) : const Color(0xFF475467)),
        title: Text(label, style: TextStyle(fontWeight: selected ? FontWeight.w800 : FontWeight.w600, color: selected ? const Color(0xFF175CD3) : null)),
        onTap: onTap,
      ),
    );
  }
}
