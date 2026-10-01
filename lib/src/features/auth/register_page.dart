import 'package:flutter/material.dart';
import '../../widgets/brand_logo.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          children: [
            const Align(alignment: Alignment.centerLeft, child: BrandLogo(size: 62, borderRadius: 18)),
            const SizedBox(height: 24),
            const Text(
              'Vincula tu crédito',
              style: TextStyle(fontSize: 29, fontWeight: FontWeight.w800, letterSpacing: -0.7),
            ),
            const SizedBox(height: 8),
            const Text(
              'Usaremos tus datos para comprobar que ya eres cliente antes de crear tu acceso.',
              style: TextStyle(color: Color(0xFF667085), fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 26),
            const TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Número de cliente',
                hintText: 'Ej. 00001234',
                prefixIcon: Icon(Icons.badge_outlined),
                helperText: 'Lo encuentras en tu contrato o comprobante.',
              ),
            ),
            const SizedBox(height: 18),
            const TextField(
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Celular o correo registrado',
                prefixIcon: Icon(Icons.verified_user_outlined),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: null, child: const Text('Verificar mis datos')),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF4FF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.sms_outlined, color: Color(0xFF175CD3)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Después enviaremos un código de 6 dígitos al medio de contacto que ya tenemos registrado.',
                      style: TextStyle(color: Color(0xFF344054), height: 1.4),
                    ),
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
