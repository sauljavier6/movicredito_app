import 'package:flutter/material.dart';
import '../../core/refresh/auto_refresh_state.dart';
import 'package:intl/intl.dart';

import '../auth/auth_service.dart';

class SupportCenterPage extends StatefulWidget {
  const SupportCenterPage({super.key});

  @override
  State<SupportCenterPage> createState() => _SupportCenterPageState();
}

class _SupportCenterPageState extends State<SupportCenterPage> with AutoRefreshState<SupportCenterPage> {
  final auth = AuthService();

  List<dynamic> tickets = [];
  List<dynamic> notifications = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Duration get autoRefreshInterval => const Duration(seconds: 7);

  @override
  Future<void> refreshData() => _load();

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        auth.supportTickets(),
        auth.notifications(),
      ]);

      if (!mounted) return;
      setState(() {
        tickets = (results[0]['items'] as List?) ?? [];
        notifications = (results[1]['items'] as List?) ?? [];
        loading = false;
        error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = 'No pudimos cargar el centro de ayuda.';
      });
    }
  }

  Future<void> _newTicket() async {
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _NewTicketSheet(),
    );

    if (result == null) return;

    try {
      await auth.createSupportTicket(
        result['subject']!,
        result['category']!,
        result['message']!,
      );
      await _load();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No fue posible enviar la consulta.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Centro de ayuda',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Soporte'),
              Tab(text: 'Notificaciones'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _newTicket,
          icon: const Icon(Icons.add_comment_outlined),
          label: const Text('Nueva consulta'),
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? _SupportError(message: error!, onRetry: _load)
                : TabBarView(
                    children: [
                      _buildTickets(),
                      _buildNotifications(),
                    ],
                  ),
      ),
    );
  }

  Widget _buildTickets() {
    if (tickets.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 180),
            Icon(
              Icons.support_agent_outlined,
              size: 52,
              color: Color(0xFF98A2B3),
            ),
            SizedBox(height: 14),
            Text(
              'No tienes consultas de soporte.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: tickets.length,
        itemBuilder: (context, index) {
          final ticket =
              Map<String, dynamic>.from(tickets[index] as Map);
          final unread = int.tryParse(ticket['unread']?.toString() ?? '0') ?? 0;

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const CircleAvatar(
                child: Icon(Icons.support_agent_rounded),
              ),
              title: Text(
                ticket['subject']?.toString() ?? '',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                '${_status(ticket['status'])} · '
                '${_date(ticket['lastMessageAt'] ?? ticket['createdAt'])}',
              ),
              trailing: unread > 0
                  ? Badge(label: Text('$unread'))
                  : const Icon(Icons.chevron_right_rounded),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SupportThreadPage(ticket: ticket),
                  ),
                );
                await _load();
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotifications() {
    if (notifications.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 180),
            Icon(
              Icons.notifications_none_rounded,
              size: 52,
              color: Color(0xFF98A2B3),
            ),
            SizedBox(height: 14),
            Text(
              'No tienes notificaciones.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification =
              Map<String, dynamic>.from(notifications[index] as Map);
          final read = notification['read'] == true;

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Icon(
                read
                    ? Icons.notifications_none_rounded
                    : Icons.notifications_active_rounded,
                color: const Color(0xFF175CD3),
              ),
              title: Text(
                notification['title']?.toString() ?? '',
                style: TextStyle(
                  fontWeight: read ? FontWeight.w600 : FontWeight.w800,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  '${notification['body'] ?? ''}\n'
                  '${_date(notification['createdAt'])}',
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SupportThreadPage extends StatefulWidget {
  const SupportThreadPage({super.key, required this.ticket});

  final Map<String, dynamic> ticket;

  @override
  State<SupportThreadPage> createState() => _SupportThreadPageState();
}

class _SupportThreadPageState extends State<SupportThreadPage> with AutoRefreshState<SupportThreadPage> {
  final auth = AuthService();
  final input = TextEditingController();

  List<dynamic> messages = [];
  bool loading = true;
  bool sending = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  @override
  Duration get autoRefreshInterval => const Duration(seconds: 5);

  @override
  Future<void> refreshData() => _load();

  Future<void> _load() async {
    try {
      final data =
          await auth.supportMessages(widget.ticket['id'].toString());
      if (!mounted) return;
      setState(() {
        messages = (data['messages'] as List?) ?? [];
        loading = false;
        error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = 'No pudimos cargar la conversación.';
      });
    }
  }

  Future<void> _send() async {
    final text = input.text.trim();
    if (text.isEmpty || sending) return;

    setState(() => sending = true);
    try {
      await auth.replySupport(widget.ticket['id'].toString(), text);
      input.clear();
      await _load();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No fue posible enviar el mensaje.')),
      );
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.ticket['subject']?.toString() ?? 'Soporte',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                    ? _SupportError(message: error!, onRetry: _load)
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = Map<String, dynamic>.from(
                            messages[index] as Map,
                          );
                          final mine =
                              message['senderType'] == 'customer';

                          return Align(
                            alignment: mine
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 11,
                              ),
                              constraints:
                                  const BoxConstraints(maxWidth: 300),
                              decoration: BoxDecoration(
                                color: mine
                                    ? const Color(0xFF175CD3)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message['message']?.toString() ?? '',
                                    style: TextStyle(
                                      color: mine
                                          ? Colors.white
                                          : const Color(0xFF101828),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _date(message['createdAt']),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: mine
                                          ? Colors.white70
                                          : const Color(0xFF98A2B3),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: input,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Escribe un mensaje...',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: sending ? null : _send,
                    icon: sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NewTicketSheet extends StatefulWidget {
  const _NewTicketSheet();

  @override
  State<_NewTicketSheet> createState() => _NewTicketSheetState();
}

class _NewTicketSheetState extends State<_NewTicketSheet> {
  final subject = TextEditingController();
  final message = TextEditingController();
  String category = 'general';

  @override
  void dispose() {
    subject.dispose();
    message.dispose();
    super.dispose();
  }

  void _submit() {
    final cleanSubject = subject.text.trim();
    final cleanMessage = message.text.trim();

    if (cleanSubject.length < 4 || cleanMessage.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escribe un asunto y una descripción.'),
        ),
      );
      return;
    }

    Navigator.pop(context, {
      'subject': cleanSubject,
      'category': category,
      'message': cleanMessage,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Nueva consulta',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: category,
              decoration: const InputDecoration(labelText: 'Categoría'),
              items: const [
                DropdownMenuItem(
                  value: 'general',
                  child: Text('Pregunta general'),
                ),
                DropdownMenuItem(
                  value: 'payment',
                  child: Text('Pago'),
                ),
                DropdownMenuItem(
                  value: 'credit',
                  child: Text('Crédito'),
                ),
                DropdownMenuItem(
                  value: 'device',
                  child: Text('Equipo'),
                ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => category = value);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: subject,
              decoration: const InputDecoration(labelText: 'Asunto'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: message,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: '¿En qué podemos ayudarte?',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _submit,
              child: const Text('Enviar consulta'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportError extends StatelessWidget {
  const _SupportError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

String _status(dynamic value) {
  switch (value?.toString()) {
    case 'open':
      return 'Abierto';
    case 'in_progress':
      return 'En atención';
    case 'resolved':
      return 'Resuelto';
    case 'closed':
      return 'Cerrado';
    default:
      return 'Soporte';
  }
}

String _date(dynamic value) {
  final date = DateTime.tryParse(value?.toString() ?? '')?.toLocal();
  if (date == null) return '';
  return DateFormat('dd/MM/yyyy HH:mm').format(date);
}
