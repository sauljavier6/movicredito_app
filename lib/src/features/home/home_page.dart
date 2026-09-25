import 'package:flutter/material.dart';
import '../../config/app_config.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 12),
            Text('MoviCrédito', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: const Color(0xFF2563EB), fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Text('Tu crédito en un solo lugar.', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -1.2)),
            const SizedBox(height: 10),
            Text('Consulta tus pagos, calendario, contrato y el estado de tu equipo financiado.', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF4F46E5)]),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Próximo pago', style: TextStyle(color: Colors.white70)),
                SizedBox(height: 8),
                Text('Conecta tu crédito', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)),
                SizedBox(height: 8),
                Text('La app mostrará información real del backend; no usamos saldos de demostración.', style: TextStyle(color: Colors.white70)),
              ]),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('API configurada', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(AppConfig.apiUrl),
                  const SizedBox(height: 12),
                  const Text('Siguiente paso: autenticación/vinculación segura del cliente y endpoint móvil de resumen.', style: TextStyle(color: Colors.black54)),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
