import 'package:flutter/material.dart';
import '../../widgets/brand_logo.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const _AppDrawer(),
      appBar: AppBar(
        titleSpacing: 0,
        title: const Row(
          children: [
            BrandLogo(size: 38, borderRadius: 11),
            SizedBox(width: 10),
            Text('MoviCrédito', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19)),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded)),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: const [
          Text('Hola', style: TextStyle(color: Color(0xFF667085), fontSize: 15)),
          SizedBox(height: 3),
          Text('Tu crédito', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.7)),
          SizedBox(height: 18),
          _CreditCard(),
          SizedBox(height: 22),
          _DeviceCard(),
          SizedBox(height: 22),
          Text('Actividad reciente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          SizedBox(height: 12),
          _EmptyActivity(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.payments_outlined), label: 'Pagos'),
          NavigationDestination(icon: Icon(Icons.smartphone_outlined), label: 'Mi equipo'),
        ],
      ),
    );
  }
}

class _CreditCard extends StatelessWidget {
  const _CreditCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF175CD3), Color(0xFF4F46E5)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [BoxShadow(color: Color(0x24175CD3), blurRadius: 26, offset: Offset(0, 12))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('PRÓXIMO PAGO', style: TextStyle(color: Color(0xFFDCE8FF), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: .7)),
              Spacer(),
              Icon(Icons.verified_user_outlined, color: Colors.white70, size: 20),
            ],
          ),
          const SizedBox(height: 24),
          const Text('—', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('Conecta tu cuenta para consultar importe y fecha.', style: TextStyle(color: Color(0xFFDCE8FF), height: 1.35)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: null,
              style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.white), foregroundColor: WidgetStatePropertyAll(Color(0xFF175CD3))),
              child: Text('Pagar'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(color: const Color(0xFFEEF4FF), borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.smartphone_rounded, color: Color(0xFF175CD3), size: 28),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mi equipo', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  SizedBox(height: 4),
                  Text('El equipo financiado aparecerá aquí.', style: TextStyle(color: Color(0xFF667085), fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF98A2B3)),
          ],
        ),
      ),
    );
  }
}

class _EmptyActivity extends StatelessWidget {
  const _EmptyActivity();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const Icon(Icons.receipt_long_outlined, color: Color(0xFF98A2B3)),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Tus pagos y movimientos reales aparecerán aquí.', style: TextStyle(color: Colors.grey.shade600)),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                children: [
                  BrandLogo(size: 54, borderRadius: 16),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('MoviCrédito', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
                      Text('Mi cuenta', style: TextStyle(color: Color(0xFF667085))),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            const SizedBox(height: 8),
            const _DrawerItem(Icons.home_outlined, 'Inicio'),
            const _DrawerItem(Icons.account_balance_wallet_outlined, 'Mi crédito'),
            const _DrawerItem(Icons.calendar_month_outlined, 'Calendario de pagos'),
            const _DrawerItem(Icons.receipt_long_outlined, 'Pagos y recibos'),
            const _DrawerItem(Icons.smartphone_outlined, 'Mi equipo'),
            const _DrawerItem(Icons.description_outlined, 'Contrato y documentos'),
            const _DrawerItem(Icons.person_outline_rounded, 'Mi perfil'),
            const Spacer(),
            const Divider(height: 1),
            const _DrawerItem(Icons.help_outline_rounded, 'Ayuda'),
            const _DrawerItem(Icons.logout_rounded, 'Cerrar sesión'),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: Icon(icon, color: const Color(0xFF475467)),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      onTap: () => Navigator.pop(context),
    );
  }
}
