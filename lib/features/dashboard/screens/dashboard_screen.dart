import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/provider/auth_provider.dart';
import '../../members/screens/member_list_screen.dart';
import '../../../features/admin/services/admin_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AdminService _adminService = AdminService();
  late Future<Map<String, dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _adminService.getDashboardStats();
  }

  Future<void> _refresh() async {
    setState(() {
      _statsFuture = _adminService.getDashboardStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<Map<String, dynamic>>(
          future: _statsFuture,
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

            final stats = snap.data!;
            final members = stats['members'] as Map<String, dynamic>? ?? {};
            final payments = stats['payments'] as Map<String, dynamic>? ?? {};
            final alerts = stats['alerts'] as Map<String, dynamic>? ?? {};

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SectionHeader(title: 'Members'),
                _StatsGrid(items: [
                  _StatItem(
                    label: 'Total',
                    value: members['total_members']?.toString() ?? '—',
                    icon: Icons.people,
                    color: Colors.indigo,
                  ),
                  _StatItem(
                    label: 'Active',
                    value: members['active_members']?.toString() ?? '—',
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                  ),
                  _StatItem(
                    label: 'Expired',
                    value: members['expired_members']?.toString() ?? '—',
                    icon: Icons.cancel_outlined,
                    color: Colors.red,
                  ),
                  _StatItem(
                    label: 'Expiring soon',
                    value: alerts['expiring_soon']?.toString() ?? '—',
                    icon: Icons.warning_amber_outlined,
                    color: Colors.orange,
                  ),
                ]),
                const SizedBox(height: 24),
                _SectionHeader(title: 'Revenue'),
                _StatsGrid(items: [
                  _StatItem(
                    label: 'Total',
                    value: '₹${payments['total_revenue'] ?? '—'}',
                    icon: Icons.account_balance_wallet_outlined,
                    color: Colors.teal,
                  ),
                  _StatItem(
                    label: 'This month',
                    value: '₹${payments['revenue_this_month'] ?? '—'}',
                    icon: Icons.trending_up,
                    color: Colors.blue,
                  ),
                ]),
                const SizedBox(height: 32),
                _SectionHeader(title: 'Quick actions'),
                const SizedBox(height: 8),
                FilledButton.icon(
                  icon: const Icon(Icons.people_alt_outlined),
                  label: const Text('View all members'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const MemberListScreen()),
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

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      );
}

class _StatsGrid extends StatelessWidget {
  final List<_StatItem> items;
  const _StatsGrid({required this.items});

  @override
  Widget build(BuildContext context) => GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
        children: items,
      );
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 28),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}