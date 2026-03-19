import 'package:flutter/material.dart';
import '../services/member_service.dart';

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  final MemberService _service = MemberService();
  late Future<MembersResult> _future;
  int _page = 1;
  static const int _limit = 10;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = _service.getMembers(page: _page, limit: _limit);
  }

  Future<void> _refresh() async {
    setState(() {
      _page = 1;
      _load();
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'expired':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add member',
            onPressed: () {
              // TODO: navigate to add member form
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<MembersResult>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snap.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(snap.error.toString()),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: _refresh, child: const Text('Retry')),
                  ],
                ),
              );
            }

            final result = snap.data!;

            if (result.data.isEmpty) {
              return const Center(child: Text('No members found'));
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: result.data.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final member = result.data[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.indigo.shade100,
                            child: Text(
                              member.name[0].toUpperCase(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo),
                            ),
                          ),
                          title: Text(member.name),
                          subtitle: Text(member.email),
                          trailing: Chip(
                            label: Text(
                              member.membershipStatus,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 11),
                            ),
                            backgroundColor:
                                _statusColor(member.membershipStatus),
                            padding: EdgeInsets.zero,
                          ),
                          onTap: () {
                            // TODO: navigate to member detail screen
                          },
                        ),
                      );
                    },
                  ),
                ),
                // Simple pagination controls
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: _page <= 1
                            ? null
                            : () => setState(() {
                                  _page--;
                                  _load();
                                }),
                      ),
                      Text('Page $_page'),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: (_page * _limit) >= result.total
                            ? null
                            : () => setState(() {
                                  _page++;
                                  _load();
                                }),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}