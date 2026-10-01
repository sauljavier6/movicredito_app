import 'package:flutter/material.dart';
import '../../config/app_config.dart';

const _brandLogoUrl =
    'https://raw.githubusercontent.com/sauljavier6/movicredito_frontend/main/public/logo.jpg';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          children: [
            const _Header(),
            const SizedBox(height: 30),
            Text(
              'Tu crédito, claro y a la mano.',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                    color: const Color(0xFF101828),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Consulta tu próximo pago, calendario, contrato y el estado de tu equipo.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF667085),
                    height: 1.45,
                  ),
            ),
            const SizedBox(height: 24),
            const _CreditHero(),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(
                  child: _QuickCard(
                    icon: Icons.calendar_month_rounded,
                    title: 'Calendario',
                    subtitle: 'Tus pagos',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _QuickCard(
                    icon: Icons.receipt_long_rounded,
                    title: 'Contrato',
                    subtitle: 'Documentos',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Expanded(
                  child: _QuickCard(
                    icon: Icons.smartphone_rounded,
                    title: 'Mi equipo',
                    subtitle: 'Estado',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _QuickCard(
                    icon: Icons.support_agent_rounded,
                    title: 'Ayuda',
                    subtitle: 'Soporte',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const _ConnectionCard(),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 58,
            height: 58,
            color: Colors.white,
            child: Image.network(
              _brandLogoUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.phone_iphone_rounded,
                color: Color(0xFF175CD3),
                size: 30,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MoviCrédito',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: Color(0xFF101828),
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Financiamiento móvil',
                style: TextStyle(
                  color: Color(0xFF667085),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE8ECF4)),
          ),
          child: const Icon(Icons.notifications_none_rounded),
        ),
      ],
    );
  }
}

class _CreditHero extends StatelessWidget {
  const _CreditHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF175CD3), Color(0xFF4F46E5)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24175CD3),
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'MI CRÉDITO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(Icons.lock_outline_rounded, color: Colors.white70, size: 20),
            ],
          ),
          const SizedBox(height: 28),
          const Text(
            'Vincula tu cuenta',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Inicia sesión para consultar información real de tu financiamiento.',
            style: TextStyle(color: Color(0xFFDCE8FF), height: 1.4),
          ),
          const SizedBox(height: 22),
          FilledButton(
            onPressed: null,
            style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.white),
              foregroundColor: WidgetStatePropertyAll(Color(0xFF175CD3)),
            ),
            child: const Text('Acceso de clientes próximamente'),
          ),
        ],
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF4FF),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: const Color(0xFF175CD3), size: 22),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF101828),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: const TextStyle(color: Color(0xFF667085), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectionCard extends StatelessWidget {
  const _ConnectionCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF3),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(Icons.cloud_done_outlined, color: Color(0xFF039855)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Preparando conexión segura',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    AppConfig.apiUrl,
                    style: const TextStyle(color: Color(0xFF667085), fontSize: 12),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Los saldos y pagos se mostrarán únicamente cuando provengan del backend.',
                    style: TextStyle(color: Color(0xFF667085), height: 1.35),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
