import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../widgets/brand_logo.dart';
import '../home/home_page.dart';
import 'auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final customerNumberController = TextEditingController();
  final contactController = TextEditingController();
  final codeController = TextEditingController();
  final passwordController = TextEditingController();
  final auth = AuthService();

  bool loading = false;
  bool obscurePassword = true;
  String? challengeId;
  String? destination;

  bool get canStart =>
      customerNumberController.text.trim().isNotEmpty &&
      contactController.text.trim().isNotEmpty &&
      !loading;

  bool get canComplete =>
      challengeId != null &&
      codeController.text.trim().length == 6 &&
      passwordController.text.length >= 10 &&
      !loading;

  @override
  void initState() {
    super.initState();
    customerNumberController.addListener(_refresh);
    contactController.addListener(_refresh);
    codeController.addListener(_refresh);
    passwordController.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    customerNumberController.dispose();
    contactController.dispose();
    codeController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> startRegistration() async {
    setState(() => loading = true);
    try {
      final data = await auth.startRegistration(
        customerNumberController.text,
        contactController.text,
      );
      if (!mounted) return;
      setState(() {
        challengeId = data['challengeId']?.toString();
        destination = data['destination']?.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Código enviado a ${destination ?? 'tu correo registrado'}.')),
      );
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No pudimos conectar con MoviCrédito.')),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> completeRegistration() async {
    final id = challengeId;
    if (id == null) return;
    setState(() => loading = true);
    try {
      await auth.completeRegistration(id, codeController.text, passwordController.text);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
        (_) => false,
      );
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No pudimos completar el registro.')),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final verifying = challengeId != null;
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: BrandLogo(size: 62, borderRadius: 18),
            ),
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
            TextField(
              controller: customerNumberController,
              enabled: !verifying,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Número de cliente',
                hintText: 'Ej. 8732303A',
                prefixIcon: Icon(Icons.badge_outlined),
                helperText: 'Lo encuentras en tu contrato o comprobante.',
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: contactController,
              enabled: !verifying,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Celular o correo registrado',
                prefixIcon: Icon(Icons.verified_user_outlined),
              ),
            ),
            const SizedBox(height: 24),
            if (!verifying) ...[
              FilledButton(
                onPressed: canStart ? startRegistration : null,
                child: Text(loading ? 'Verificando...' : 'Verificar mis datos'),
              ),
            ] else ...[
              if (destination != null)
                Text(
                  'Enviamos un código de 6 dígitos a $destination.',
                  style: const TextStyle(color: Color(0xFF667085)),
                ),
              const SizedBox(height: 16),
              TextField(
                controller: codeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'Código de verificación',
                  prefixIcon: Icon(Icons.password_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Crea tu contraseña',
                  helperText: 'Mínimo 10 caracteres.',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => obscurePassword = !obscurePassword),
                    icon: Icon(obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: canComplete ? completeRegistration : null,
                child: Text(loading ? 'Creando cuenta...' : 'Crear mi cuenta'),
              ),
            ],
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
