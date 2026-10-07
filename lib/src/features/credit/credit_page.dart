import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/api/api_client.dart';
import '../auth/auth_service.dart';

class CreditPage extends StatefulWidget {
  const CreditPage({super.key});
  @override State<CreditPage> createState() => _CreditPageState();
}

class _CreditPageState extends State<CreditPage> {
  final auth = AuthService();
  Map<String, dynamic>? data;
  bool loading = true;
  String? error;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final result = await auth.credit();
      if (mounted) setState(() { data = result; loading = false; error = null; });
    } on ApiException catch (e) {
      if (mounted) setState(() { error = e.message; loading = false; });
    } catch (_) {
      if (mounted) setState(() { error = 'No pudimos cargar tu crédito.'; loading = false; });
    }
  }

  @override Widget build(BuildContext context) {
    final credit = data?['credit'] as Map<String, dynamic>?;
    final installments = (data?['installments'] as List?)?.cast<dynamic>() ?? [];
    return Scaffold(
      appBar: AppBar(title: const Text('Mi crédito', style: TextStyle(fontWeight: FontWeight.w800))),
      body: loading ? const Center(child: CircularProgressIndicator()) :
        error != null ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [Text(error!), const SizedBox(height: 16), FilledButton(onPressed: () { setState(() => loading = true); _load(); }, child: const Text('Reintentar'))]))) :
        credit == null ? const Center(child: Text('No tienes un crédito activo.')) :
        RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              _Summary(credit: credit),
              const SizedBox(height: 24),
              const Text('Calendario de pagos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              if (installments.isEmpty) const Card(child: Padding(padding: EdgeInsets.all(18), child: Text('Todavía no hay parcialidades registradas.'))),
              ...installments.map((raw) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _InstallmentTile(item: Map<String, dynamic>.from(raw as Map)))),
            ],
          ),
        ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.credit});
  final Map<String, dynamic> credit;
  @override Widget build(BuildContext context) => Card(child: Padding(
    padding: const EdgeInsets.all(20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Saldo pendiente', style: TextStyle(color: Color(0xFF667085))),
      const SizedBox(height: 5),
      Text(_money(credit['balance']), style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
      const SizedBox(height: 18),
      Row(children: [
        Expanded(child: _Detail('Monto financiado', _money(credit['principal']))),
        Expanded(child: _Detail('Total', _money(credit['totalAmount']))),
      ]),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(child: _Detail('Plazo', '${credit['termMonths'] ?? '—'} meses')),
        Expanded(child: _Detail('Estado', _status(credit['status']))),
      ]),
    ]),
  ));
}

class _Detail extends StatelessWidget {
  const _Detail(this.label, this.value);
  final String label, value;
  @override Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(color: Color(0xFF667085), fontSize: 12)),
    const SizedBox(height: 3),
    Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
  ]);
}

class _InstallmentTile extends StatelessWidget {
  const _InstallmentTile({required this.item});
  final Map<String, dynamic> item;
  @override Widget build(BuildContext context) {
    final status = item['status']?.toString() ?? 'pending';
    final paid = status == 'paid';
    final overdue = status == 'overdue';
    return Card(child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: paid ? const Color(0xFFECFDF3) : overdue ? const Color(0xFFFEF3F2) : const Color(0xFFEEF4FF),
        child: Icon(paid ? Icons.check_rounded : overdue ? Icons.warning_amber_rounded : Icons.calendar_today_rounded, color: paid ? const Color(0xFF027A48) : overdue ? const Color(0xFFB42318) : const Color(0xFF175CD3)),
      ),
      title: Text('Pago #${item['number']}', style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text('${_date(item['dueDate'])} · ${_status(status)}'),
      trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(_money(item['amount']), style: const TextStyle(fontWeight: FontWeight.w800)),
        if (status == 'partial') Text('Falta ${_money(item['pendingAmount'])}', style: const TextStyle(fontSize: 11, color: Color(0xFFB54708))),
      ]),
    ));
  }
}

String _money(dynamic value) => NumberFormat.currency(locale: 'es_MX', symbol: '\$', decimalDigits: 2).format(num.tryParse(value?.toString() ?? '') ?? 0);
String _date(dynamic value) {
  final d = DateTime.tryParse(value?.toString() ?? '');
  if (d == null) return 'Sin fecha';
  return DateFormat('dd/MM/yyyy').format(d);
}
String _status(dynamic value) {
  switch (value?.toString()) {
    case 'active': return 'Activo';
    case 'overdue': return 'Vencido';
    case 'paid': return 'Pagado';
    case 'partial': return 'Parcial';
    case 'waived': return 'Condonado';
    default: return 'Pendiente';
  }
}
