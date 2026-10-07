import 'package:flutter/material.dart';
import '../auth/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final auth = AuthService();
  Map<String, dynamic>? customer;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await auth.me();
      if (!mounted) return;
      setState(() {
        customer = data;
        loading = false;
        error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = 'No pudimos cargar tu perfil.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mi perfil',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const CircleAvatar(
                              radius: 34,
                              backgroundColor: Color(0xFFEEF4FF),
                              child: Icon(
                                Icons.person_rounded,
                                size: 36,
                                color: Color(0xFF175CD3),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              (customer?['fullName'] ?? '').toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Cliente ${customer?['customerNumber'] ?? ''}',
                              style: const TextStyle(color: Color(0xFF667085)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Column(
                        children: [
                          _item(Icons.email_outlined, 'Correo', customer?['email']),
                          const Divider(height: 1, indent: 58),
                          _item(Icons.phone_outlined, 'Teléfono', customer?['phone']),
                          const Divider(height: 1, indent: 58),
                          _item(Icons.badge_outlined, 'Estado', customer?['status']),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        'Los cambios a tus datos personales deben validarse con MoviCrédito.',
                        style: TextStyle(
                          color: Color(0xFF667085),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _item(IconData icon, String label, dynamic value) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF475467)),
      title: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Color(0xFF667085)),
      ),
      subtitle: Text(
        (value ?? '—').toString(),
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Color(0xFF101828),
        ),
      ),
    );
  }
}
