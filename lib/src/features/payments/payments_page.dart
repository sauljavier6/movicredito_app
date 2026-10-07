import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/api/api_client.dart';
import '../auth/auth_service.dart';
import 'payment_checkout_page.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});
  @override State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  final auth = AuthService();
  List<dynamic> payments = [];
  bool loading = true;
  String? error;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final data = await auth.payments();
      if (mounted) setState(() { payments = (data['payments'] as List?) ?? []; loading = false; error = null; });
    } on ApiException catch (e) {
      if (mounted) setState(() { error = e.message; loading = false; });
    } catch (_) {
      if (mounted) setState(() { error = 'No pudimos cargar tus pagos.'; loading = false; });
    }
  }

  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Pagos y recibos', style: TextStyle(fontWeight: FontWeight.w800)),
      actions: [IconButton(tooltip: 'Realizar pago', icon: const Icon(Icons.add_card_rounded), onPressed: () async { final paid = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const PaymentCheckoutPage())); if (paid == true) _load(); })],
    ),
    body: loading ? const Center(child: CircularProgressIndicator()) :
      error != null ? _Error(message: error!, retry: () { setState(() => loading = true); _load(); }) :
      RefreshIndicator(
        onRefresh: _load,
        child: payments.isEmpty
          ? ListView(physics: const AlwaysScrollableScrollPhysics(), padding: const EdgeInsets.all(24), children: const [
              SizedBox(height: 100),
              Icon(Icons.receipt_long_outlined, size: 54, color: Color(0xFF98A2B3)),
              SizedBox(height: 16),
              Text('Aún no tienes pagos registrados', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              SizedBox(height: 8),
              Text('Cuando se aplique un pago a tu crédito aparecerá aquí.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF667085))),
            ])
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              itemCount: payments.length,
              itemBuilder: (_, i) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _PaymentCard(payment: Map<String, dynamic>.from(payments[i] as Map))),
            ),
      ),
  );
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.payment});
  final Map<String, dynamic> payment;
  @override Widget build(BuildContext context) {
    final status = payment['status']?.toString() ?? '';
    final applied = status == 'applied';
    return Card(child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(color: applied ? const Color(0xFFECFDF3) : const Color(0xFFFFFAEB), borderRadius: BorderRadius.circular(14)), child: Icon(applied ? Icons.check_circle_outline_rounded : Icons.schedule_rounded, color: applied ? const Color(0xFF027A48) : const Color(0xFFB54708))),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_money(payment['amount']), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text('${_method(payment['method'])} · ${_date(payment['paidAt'])}', style: const TextStyle(color: Color(0xFF667085), fontSize: 13)),
          if ((payment['externalReference'] ?? '').toString().isNotEmpty) ...[const SizedBox(height: 3), Text('Ref. ${payment['externalReference']}', style: const TextStyle(color: Color(0xFF98A2B3), fontSize: 11))],
        ])),
        Text(_status(status), style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: applied ? const Color(0xFF027A48) : const Color(0xFFB54708))),
      ]),
    ));
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.message, required this.retry});
  final String message;
  final VoidCallback retry;
  @override Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [Text(message, textAlign: TextAlign.center), const SizedBox(height: 16), FilledButton(onPressed: retry, child: const Text('Reintentar'))])));
}

String _money(dynamic v) => NumberFormat.currency(locale: 'es_MX', symbol: '\$', decimalDigits: 2).format(num.tryParse(v?.toString() ?? '') ?? 0);
String _date(dynamic v) { final d = DateTime.tryParse(v?.toString() ?? '')?.toLocal(); return d == null ? 'Sin fecha' : DateFormat('dd/MM/yyyy').format(d); }
String _method(dynamic v) { final s = v?.toString().replaceAll('_', ' ') ?? 'Pago'; return s.isEmpty ? 'Pago' : '${s[0].toUpperCase()}${s.substring(1)}'; }
String _status(String v) { switch(v) { case 'applied': return 'Aplicado'; case 'pending': return 'Pendiente'; case 'rejected': return 'Rechazado'; case 'reversed': return 'Revertido'; default: return v; } }
