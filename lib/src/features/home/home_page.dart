import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/api/api_client.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/app_drawer.dart';
import '../auth/auth_service.dart';
import '../auth/login_page.dart';
import '../payments/payments_page.dart';
import '../payments/payment_checkout_page.dart';
import '../device/device_page.dart';
import '../support/support_center_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final auth = AuthService();
  Map<String, dynamic>? customer;
  Map<String, dynamic>? summary;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() { loading = true; error = null; });
    try {
      final results = await Future.wait([auth.me(), auth.summary()]);
      if (!mounted) return;
      setState(() {
        customer = results[0];
        summary = results[1];
        loading = false;
      });
    } on ApiException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403) {
        await auth.logout();
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false);
        return;
      }
      if (mounted) setState(() { error = e.message; loading = false; });
    } catch (_) {
      if (mounted) setState(() { error = 'No pudimos cargar tu información.'; loading = false; });
    }
  }


  @override
  Widget build(BuildContext context) {
    final credit = summary?['credit'] as Map<String, dynamic>?;
    final installment = summary?['nextInstallment'] as Map<String, dynamic>?;
    final device = summary?['device'] as Map<String, dynamic>?;
    final fullName = (customer?['fullName'] ?? '').toString().trim();
    final firstName = fullName.isEmpty ? '' : _capitalize(fullName.split(RegExp(r'\s+')).first);

    return Scaffold(
      drawer: AppDrawer(customer: customer, currentSection: 'home'),
      appBar: AppBar(
        titleSpacing: 0,
        title: const Row(children: [
          BrandLogo(size: 38, borderRadius: 11),
          SizedBox(width: 10),
          Text('MoviCrédito', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19)),
        ]),
        actions: [IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportCenterPage())), tooltip: 'Notificaciones y ayuda', icon: const Icon(Icons.notifications_none_rounded)), IconButton(onPressed: _load, tooltip: 'Actualizar', icon: const Icon(Icons.refresh_rounded)), const SizedBox(width: 8)],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? _ErrorState(message: error!, onRetry: _load)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                    children: [
                      Text(firstName.isEmpty ? 'Hola' : 'Hola, $firstName', style: const TextStyle(color: Color(0xFF667085), fontSize: 15)),
                      const SizedBox(height: 3),
                      const Text('Tu crédito', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.7)),
                      const SizedBox(height: 18),
                      _CreditCard(credit: credit, installment: installment),
                      if (credit != null) ...[
                        const SizedBox(height: 14),
                        _BalanceCard(credit: credit),
                      ],
                      const SizedBox(height: 22),
                      _DeviceCard(device: device),
                      const SizedBox(height: 22),
                      const Text('Actividad reciente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 12),
                      const _EmptyActivity(),
                    ],
                  ),
                ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PaymentsPage()));
          if (index == 2) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DevicePage()));
        },
        destinations: [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.payments_outlined), label: 'Pagos'),
          NavigationDestination(icon: Icon(Icons.smartphone_outlined), label: 'Mi equipo'),
        ],
      ),
    );
  }
}

String _capitalize(String value) => value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1).toLowerCase()}';
String _money(dynamic value) => NumberFormat.currency(locale: 'es_MX', symbol: '\$', decimalDigits: 2).format(num.tryParse(value.toString()) ?? 0);
String _date(dynamic value) {
  final date = DateTime.tryParse(value?.toString() ?? '')?.toLocal();
  if (date == null) return 'Fecha por confirmar';
  const months = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

class _CreditCard extends StatelessWidget {
  const _CreditCard({required this.credit, required this.installment});
  final Map<String, dynamic>? credit;
  final Map<String, dynamic>? installment;

  @override
  Widget build(BuildContext context) {
    final pending = installment == null ? 0 : (num.tryParse(installment!['amount'].toString()) ?? 0) - (num.tryParse(installment!['paidAmount'].toString()) ?? 0);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF175CD3), Color(0xFF4F46E5)]),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [BoxShadow(color: Color(0x24175CD3), blurRadius: 26, offset: Offset(0, 12))],
      ),
      child: credit == null
          ? const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('SIN CRÉDITO ACTIVO', style: TextStyle(color: Color(0xFFDCE8FF), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: .7)),
              SizedBox(height: 20),
              Text('No tienes un crédito activo', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
              SizedBox(height: 6),
              Text('Cuando tengas un financiamiento vigente aparecerá aquí.', style: TextStyle(color: Color(0xFFDCE8FF), height: 1.35)),
            ])
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Text('PRÓXIMO PAGO', style: TextStyle(color: Color(0xFFDCE8FF), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: .7)),
                const Spacer(),
                if (installment != null) Text('Pago #${installment!['number']}', style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 22),
              Text(installment == null ? 'Al corriente' : _money(pending), style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(installment == null ? 'No tienes pagos pendientes.' : 'Vence el ${_date(installment!['dueDate'])}', style: const TextStyle(color: Color(0xFFDCE8FF), height: 1.35)),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, child: FilledButton(
                onPressed: installment == null ? null : () async {
                  final paid = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const PaymentCheckoutPage()));
                  if (paid == true && context.mounted) {
                    final state = context.findAncestorStateOfType<_HomePageState>();
                    await state?._load();
                  }
                },
                style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.white), foregroundColor: WidgetStatePropertyAll(Color(0xFF175CD3))),
                child: const Text('Pagar'),
              )),
            ]),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.credit});
  final Map<String, dynamic> credit;
  @override
  Widget build(BuildContext context) {
    final status = credit['status']?.toString() ?? '';
    return Card(child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Saldo pendiente', style: TextStyle(color: Color(0xFF667085), fontSize: 13)),
          const SizedBox(height: 4),
          Text(_money(credit['balance']), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(color: const Color(0xFFECFDF3), borderRadius: BorderRadius.circular(99)),
          child: Text(status == 'overdue' ? 'Vencido' : 'Activo', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
        ),
      ]),
    ));
  }
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({required this.device});
  final Map<String, dynamic>? device;
  @override
  Widget build(BuildContext context) {
    final title = device == null ? 'Mi equipo' : [device!['brand'], device!['model']].where((e) => e != null && e.toString().trim().isNotEmpty).join(' ');
    final details = device == null
        ? 'No hay un equipo asociado al crédito activo.'
        : [device!['storage'], device!['color']].where((e) => e != null && e.toString().trim().isNotEmpty).join(' · ');
    return Card(child: InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DevicePage())),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(children: [
          Container(width: 54, height: 54, decoration: BoxDecoration(color: const Color(0xFFEEF4FF), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.smartphone_rounded, color: Color(0xFF175CD3), size: 28)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title.isEmpty ? 'Mi equipo' : title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 4),
            Text(details.isEmpty ? 'Equipo financiado' : details, style: const TextStyle(color: Color(0xFF667085), fontSize: 13)),
          ])),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF98A2B3)),
        ]),
      ),
    ));
  }
}

class _EmptyActivity extends StatelessWidget {
  const _EmptyActivity();
  @override
  Widget build(BuildContext context) => Card(child: Padding(
    padding: const EdgeInsets.all(18),
    child: Row(children: [
      const Icon(Icons.receipt_long_outlined, color: Color(0xFF98A2B3)),
      const SizedBox(width: 12),
      Expanded(child: Text('Tus pagos y movimientos aparecerán aquí.', style: TextStyle(color: Colors.grey.shade600))),
    ]),
  ));
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final Future<void> Function() onRetry;
  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(28),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.cloud_off_rounded, size: 48, color: Color(0xFF667085)),
      const SizedBox(height: 14),
      Text(message, textAlign: TextAlign.center),
      const SizedBox(height: 18),
      FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
    ]),
  ));
}

