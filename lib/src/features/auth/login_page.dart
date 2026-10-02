import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../widgets/brand_logo.dart';
import '../home/home_page.dart';
import 'auth_service.dart';
import 'register_page.dart';
import 'reset_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final loginController = TextEditingController();
  final passwordController = TextEditingController();
  final auth = AuthService();
  bool obscurePassword = true;
  bool loading = false;

  @override
  void dispose() { loginController.dispose(); passwordController.dispose(); super.dispose(); }

  Future<void> submit() async {
    if (loginController.text.trim().isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingresa tu correo y contraseña.'))); return;
    }
    setState(() => loading = true);
    try {
      await auth.login(loginController.text, passwordController.text);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomePage()), (_) => false);
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No pudimos conectar con MoviCrédito.')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
          children: [
            const Center(child: BrandLogo(size: 88, borderRadius: 24)),
            const SizedBox(height: 16),
            const Text('MoviCrédito', textAlign: TextAlign.center, style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800, letterSpacing: -0.6)),
            const SizedBox(height: 42),
            const Text('Bienvenido', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -0.8)),
            const SizedBox(height: 8),
            const Text('Consulta y administra tu crédito de celular desde un solo lugar.', style: TextStyle(color: Color(0xFF667085), fontSize: 16, height: 1.4)),
            const SizedBox(height: 28),
            TextField(controller: loginController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Correo', prefixIcon: Icon(Icons.person_outline_rounded))),
            const SizedBox(height: 14),
            TextField(
              controller: passwordController,
              obscureText: obscurePassword,
              onSubmitted: (_) => loading ? null : submit(),
              decoration: InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(onPressed: () => setState(() => obscurePassword = !obscurePassword), icon: Icon(obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined)),
              ),
            ),
            Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ResetPasswordPage())), child: const Text('¿Olvidaste tu contraseña?'))),
            const SizedBox(height: 8),
            FilledButton(onPressed: loading ? null : submit, child: Text(loading ? 'Ingresando...' : 'Iniciar sesión')),
            const SizedBox(height: 22),
            const Row(children: [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('¿Primera vez?', style: TextStyle(color: Color(0xFF667085)))), Expanded(child: Divider())]),
            const SizedBox(height: 18),
            OutlinedButton(onPressed: loading ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage())), child: const Text('Crear mi cuenta')),
            const SizedBox(height: 18),
            const Text('Tu cuenta se vincula únicamente con clientes que ya tienen un expediente MoviCrédito.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF667085), fontSize: 12, height: 1.4)),
          ],
        ),
      ),
    );
  }
}
