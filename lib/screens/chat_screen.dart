import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatScreen extends StatefulWidget {
  final String otherUserId;
  final String title;
  const ChatScreen({super.key, required this.otherUserId, required this.title});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final input = TextEditingController();
  final client = Supabase.instance.client;
  String? conversationId;
  bool starting = true;
  String? error;

  Future<void> ensureConversation() async {
    try {
      final uid = client.auth.currentUser!.id;
      final rows = await client.rpc('get_or_create_conversation', params: {'other_user': widget.otherUserId});
      conversationId = rows.toString();
    } catch (_) {
      error = 'Не удалось открыть чат. Проверьте SQL-функцию из README.md.';
    } finally {
      if (mounted) setState(() => starting = false);
    }
  }

  Future<void> send() async {
    final text = input.text.trim();
    final cid = conversationId;
    if (text.isEmpty || cid == null) return;
    input.clear();
    try {
      await client.from('messages').insert({
        'conversation_id': cid,
        'sender_id': client.auth.currentUser!.id,
        'body': text,
      });
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сообщение не отправлено. Проверьте настройки базы данных.')));
    }
  }

  @override
  void initState() { super.initState(); ensureConversation(); }

  @override
  void dispose() { input.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final stream = conversationId == null ? null : client.from('messages')
      .stream(primaryKey: ['id']).eq('conversation_id', conversationId!).order('created_at');
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: starting ? const Center(child: CircularProgressIndicator())
        : error != null ? Center(child: Text(error!))
        : Column(children: [
          Expanded(child: stream == null ? const SizedBox() : StreamBuilder<List<Map<String, dynamic>>>(
            stream: stream,
            builder: (context, snapshot) {
              if (snapshot.hasError) return const Center(child: Text('Ошибка загрузки сообщений'));
              final messages = snapshot.data ?? [];
              if (messages.isEmpty) return const Center(child: Text('Пока нет сообщений'));
              return ListView.builder(padding: const EdgeInsets.all(12), itemCount: messages.length,
                itemBuilder: (context, i) {
                  final m = messages[i];
                  final mine = m['sender_id'] == client.auth.currentUser!.id;
                  return Align(alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      constraints: const BoxConstraints(maxWidth: 300),
                      decoration: BoxDecoration(
                        color: mine ? const Color(0xFF176B91) : const Color(0xFF263541),
                        borderRadius: BorderRadius.circular(14)),
                      child: Text((m['body'] ?? '').toString())));
                });
            })),
          SafeArea(child: Padding(padding: const EdgeInsets.all(8), child: Row(children: [
            Expanded(child: TextField(controller: input, minLines: 1, maxLines: 4,
              decoration: const InputDecoration(hintText: 'Сообщение…', border: OutlineInputBorder()))),
            IconButton(onPressed: send, icon: const Icon(Icons.send, color: Color(0xFF229ED9))),
          ]))),
        ]),
    );
  }
}
