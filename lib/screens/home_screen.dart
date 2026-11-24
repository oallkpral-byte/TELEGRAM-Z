import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final search = TextEditingController();
  List<Map<String, dynamic>> profiles = [];
  bool loading = true;
  String? error;

  Future<void> loadProfiles() async {
    setState(() { loading = true; error = null; });
    try {
      final uid = Supabase.instance.client.auth.currentUser!.id;
      final data = await Supabase.instance.client.from('profiles')
          .select('id, username, display_name')
          .neq('id', uid)
          .order('username')
          .limit(100);
      profiles = List<Map<String, dynamic>>.from(data);
    } catch (_) {
      error = 'Не удалось загрузить пользователей. Проверьте SQL-настройку из README.md.';
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void initState() { super.initState(); loadProfiles(); }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('TELEGRAM X'), actions: [
      IconButton(onPressed: loadProfiles, icon: const Icon(Icons.refresh)),
      IconButton(onPressed: signOut, icon: const Icon(Icons.logout)),
    ]),
    body: Column(children: [
      Padding(padding: const EdgeInsets.all(12), child: TextField(
        controller: search, onChanged: (_) => setState(() {}),
        decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Поиск пользователей', border: OutlineInputBorder()),
      )),
      Expanded(child: loading
        ? const Center(child: CircularProgressIndicator())
        : error != null
          ? Center(child: Text(error!))
          : ListView(children: profiles.where((p) {
              final q = search.text.toLowerCase();
              return ('${p['username']} ${p['display_name'] ?? ''}').toLowerCase().contains(q);
            }).map((p) => ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text((p['display_name'] ?? p['username'] ?? 'Пользователь').toString()),
              subtitle: Text('@${p['username'] ?? 'user'}'),
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => ChatScreen(otherUserId: p['id'].toString(),
                  title: (p['display_name'] ?? p['username'] ?? 'Чат').toString()),
              )),
            )).toList()),
      ),
    ]),
  );
}
