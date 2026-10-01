import 'package:flutter/material.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar acceso')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
          children: [
            Container(
              width: 58,
              height: 58,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF4FF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.lock_reset_rounded, size: 30, color: Color(0xFF175CD3)),
            ),
            const SizedBox(height: 24),
            const Text(
              'Recupera tu contraseña',
              style: TextStyle(fontSize: 29, fontWeight: FontWeight.w800, letterSpacing: -0.7),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ingresa el celular o correo asociado a tu cuenta. Te enviaremos un código para validar tu identidad.',
              style: TextStyle(color: Color(0xFF667085), fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 28),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Correo o celular',
                prefixIcon: Icon(Icons.alternate_email_rounded),
              ),
            ),
            const SizedBox(height: 22),
            FilledButton(onPressed: null, child: const Text('Enviar código')),
          ],
        ),
      ),
    );
  }
}
