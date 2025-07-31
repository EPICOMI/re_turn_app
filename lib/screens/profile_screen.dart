import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:re_turn_app/providers/voucher_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () => _showSettingsBottomSheet(context),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Consumer<VoucherProvider>(
        builder: (context, voucherProvider, child) {
          final stats = voucherProvider.getStatistics();

          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: const Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // User Info
                      Text(
                        'Re-Turn User',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Eco-friendly recycler since ${DateTime.now().year}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Quick Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatColumn(
                            '${stats['total']}',
                            'Total Vouchers',
                            Icons.receipt_long,
                          ),
                          Container(
                            height: 40,
                            width: 1,
                            color: Colors.grey[300],
                          ),
                          _buildStatColumn(
                            '€${voucherProvider.totalValue.toStringAsFixed(2)}',
                            'Available Credit',
                            Icons.euro,
                          ),
                          Container(
                            height: 40,
                            width: 1,
                            color: Colors.grey[300],
                          ),
                          _buildStatColumn(
                            '${stats['used']}',
                            'Used Vouchers',
                            Icons.check_circle,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatColumn(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final maxHeight = constraints.maxHeight;
            // Using proportional padding and spacing
            final verticalPadding = maxHeight * 0.04;
            final spacing = maxHeight * 0.03;

            return Container(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: verticalPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 50,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(height: spacing),

                  Text(
                    'Settings',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: spacing),

                  // Settings Options
                  _buildSettingsTile(
                    Icons.notifications,
                    'Notifications',
                    'Manage notification preferences',
                    () {
                      Navigator.pop(context);
                      _showComingSoonSnackBar(context, 'Notifications');
                    },
                  ),
                  _buildSettingsTile(
                    Icons.location_on,
                    'Location Services',
                    'Auto-detect store locations',
                    () {
                      Navigator.pop(context);
                      _showComingSoonSnackBar(context, 'Location Services');
                    },
                  ),
                  _buildSettingsTile(
                    Icons.backup,
                    'Backup & Sync',
                    'Backup vouchers to cloud',
                    () {
                      Navigator.pop(context);
                      _showComingSoonSnackBar(context, 'Backup & Sync');
                    },
                  ),
                  _buildSettingsTile(
                    Icons.help,
                    'Help & Support',
                    'Get help and contact support',
                    () {
                      Navigator.pop(context);
                      _showAboutDialog(context);
                    },
                  ),
                  _buildSettingsTile(
                    Icons.bar_chart,
                    'Lifetime Stats',
                    'See your lifetime recycling statistics',
                    () {
                      Navigator.pop(context);
                      _showLifetimeStatsDialog(context);
                    },
                  ),
                  _buildSettingsTile(
                    Icons.info,
                    'About',
                    'App version and information',
                    () {
                      Navigator.pop(context);
                      _showAboutDialog(context);
                    },
                  ),

                  SizedBox(height: spacing),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSettingsTile(IconData icon,
      String title,
      String subtitle,
      VoidCallback onTap,) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showComingSoonSnackBar(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('About Re-Turn Digital'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Version: 1.0.0'),
                SizedBox(height: 8),
                Text(
                  'Re-Turn Digital helps you manage your bottle return vouchers digitally, making it easier to track and use your deposit credits.',
                ),
                SizedBox(height: 16),
                Text(
                  'Features:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text('• Scan and store voucher barcodes'),
                Text('• Track total available credit'),
                Text('• Mark vouchers as used'),
                Text('• View voucher history'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showLifetimeStatsDialog(BuildContext context) {
    final voucherProvider = Provider.of<VoucherProvider>(
        context, listen: false);
    final stats = voucherProvider.getStatistics();
    final lifetimeCredit = stats['lifetimeCredit'];
    final estimatedItems = lifetimeCredit > 0
        ? (lifetimeCredit / 0.20).round()
        : 0;

    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Lifetime Stats'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Lifetime Credit: €${lifetimeCredit.toStringAsFixed(
                      2)}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  'Wow! You have recycled approximately $estimatedItems items. Thank you for helping the planet!',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}