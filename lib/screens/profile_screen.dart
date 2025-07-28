import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:re_turn_app/providers/voucher_provider.dart';
import 'package:re_turn_app/widgets/voucher_card.dart';

import '../models/voucher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

// sorting enum
enum SortOption {
  depositLowToHigh,
  depositHighToLow,
  dateOldestToNewest,
  dateNewestToOldest,
}

// sorting extensions for display names
extension SortOptionExtension on SortOption {
  String get displayName {
    switch (this) {
      case SortOption.depositLowToHigh:
        return 'Deposit (low to high)';
      case SortOption.depositHighToLow:
        return 'Deposit (high to low)';
      case SortOption.dateOldestToNewest:
        return 'Date (oldest first)';
      case SortOption.dateNewestToOldest:
        return 'Date (newest first)';
    }
  }
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  SortOption _sortOption = SortOption.dateNewestToOldest;

  // Store names and selected stores state
  final List<String> storeNames = [
    'Tesco',
    'Supervalu',
    'Lidl',
    'Aldi',
    'Dunnes',
    'Centra',
    'Spar',
  ];
  Set<String> selectedStores = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .inversePrimary,
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

          return Column(
            children: [
              // Profile Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Theme
                      .of(context)
                      .colorScheme
                      .inversePrimary,
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
                      backgroundColor: Theme
                          .of(context)
                          .primaryColor,
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
                      style: Theme
                          .of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Eco-friendly recycler since ${DateTime
                          .now()
                          .year}',
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

              // Tab Bar
              Container(
                color: Colors.grey[50],
                child: TabBar(
                  controller: _tabController,
                  labelColor: Theme
                      .of(context)
                      .primaryColor,
                  unselectedLabelColor: Colors.grey[600],
                  indicatorColor: Theme
                      .of(context)
                      .primaryColor,
                  tabs: const [
                    Tab(text: 'All', icon: Icon(Icons.list)),
                    Tab(text: 'Active',
                        icon: Icon(Icons.radio_button_unchecked)),
                    Tab(text: 'Used', icon: Icon(Icons.check_circle)),
                  ],
                ),
              ),

              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // All Vouchers
                    _buildVoucherList(
                        voucherProvider.vouchers, voucherProvider),
                    // Active Vouchers
                    _buildVoucherList(
                        voucherProvider.activeVouchers, voucherProvider),
                    // Used Vouchers
                    _buildVoucherList(
                        voucherProvider.usedVouchers, voucherProvider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatColumn(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Theme
            .of(context)
            .primaryColor, size: 20),
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

  Widget _buildVoucherList(List<Voucher> vouchers, VoucherProvider provider) {
    if (vouchers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No vouchers found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    // Filter vouchers based on selected stores with case-insensitive matching
    List<Voucher> filteredVouchers = selectedStores.isEmpty
        ? vouchers
        : vouchers
        .where((v) =>
        selectedStores.any((s) => s.toLowerCase() == v.storeName.toLowerCase()))
        .toList();

    // Sort the vouchers based on _sortOption
    List<Voucher> sortedVouchers = List.from(filteredVouchers);
    switch (_sortOption) {
      case SortOption.depositLowToHigh:
        sortedVouchers.sort((a, b) => a.depositValue.compareTo(b.depositValue));
        break;
      case SortOption.depositHighToLow:
        sortedVouchers.sort((a, b) => b.depositValue.compareTo(a.depositValue));
        break;
      case SortOption.dateOldestToNewest:
        sortedVouchers.sort((a, b) => a.dateCreated.compareTo(b.dateCreated));
        break;
      case SortOption.dateNewestToOldest:
        sortedVouchers.sort((a, b) => b.dateCreated.compareTo(a.dateCreated));
        break;
    }

    return Column(
      children: [
        // Add sorting dropdown above the list
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [

                  Text(
                    'Sort by',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<SortOption>(
                    initialValue: _sortOption,
                    onSelected: (SortOption option) {
                      setState(() {
                        _sortOption = option;
                      });
                    },
                    itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<SortOption>>[
                      const PopupMenuItem<SortOption>(
                        value: SortOption.depositLowToHigh,
                        child: Text('Deposit Value (low to high)'),
                      ),
                      const PopupMenuItem<SortOption>(
                        value: SortOption.depositHighToLow,
                        child: Text('Deposit Value (high to low)'),
                      ),
                      const PopupMenuItem<SortOption>(
                        value: SortOption.dateOldestToNewest,
                        child: Text('Date (oldest to newest)'),
                      ),
                      const PopupMenuItem<SortOption>(
                        value: SortOption.dateNewestToOldest,
                        child: Text('Date (newest to oldest)'),
                      ),
                    ],
                    child: Row(
                      children: [
                        Text(
                          _sortOption.displayName,
                          style: TextStyle(
                            color: Theme
                                .of(context)
                                .primaryColor,
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: Theme
                              .of(context)
                              .primaryColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Filter button with text and icon
              GestureDetector(
                onTap: () => _showFilterDialog(),
                child: Row(
                  children: [
                    Text(
                      'Filter',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.filter_list, color: Theme
                        .of(context)
                        .primaryColor),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Use Expanded to ensure ListView takes remaining space and scrolls properly
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await provider.loadVouchers();
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: sortedVouchers.length,
              itemBuilder: (context, index) {
                return VoucherCard(voucher: sortedVouchers[index]);
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24.0),
        child: Wrap(
          direction: Axis.vertical,
          spacing: 12,
          runSpacing: 12,
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

            Text(
              'Settings',
              style: Theme.of(context).textTheme.headlineSmall,
            ),

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
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon,
      String title,
      String subtitle,
      VoidCallback onTap,) {
    return ListTile(
      leading: Icon(icon, color: Theme
          .of(context)
          .primaryColor),
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


  void _showFilterDialog() async {
    Set<String> tempSelected = Set.from(selectedStores);
    final result = await showDialog<Set<String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter by Store'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: storeNames.map((store) {
                    return CheckboxListTile(
                      title: Text(store),
                      value: tempSelected.contains(store),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            tempSelected.add(store);
                          } else {
                            tempSelected.remove(store);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, tempSelected),
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        selectedStores = result;
      });
    }
  }

}