import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:re_turn_app/models/voucher.dart';
import 'package:re_turn_app/providers/voucher_provider.dart';
import 'package:re_turn_app/widgets/voucher_card.dart';

// Copied from profile_screen.dart
enum SortOption {
  depositLowToHigh,
  depositHighToLow,
  dateOldestToNewest,
  dateNewestToOldest,
}

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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  // State from profile_screen.dart
  late TabController _tabController;
  SortOption _sortOption = SortOption.dateNewestToOldest;
  final List<String> storeNames = [
    'Tesco', 'Supervalu', 'Lidl', 'Aldi', 'Dunnes', 'Centra', 'Spar',
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
        title: const Text('Re-Turn Digital'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<VoucherProvider>(
        builder: (context, voucherProvider, child) {
          if (voucherProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              await voucherProvider.loadVouchers();
            },
            // Using NestedScrollView to coordinate the header and the tab view
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: Container(
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
                            'Welcome back!',
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        controller: _tabController,
                        labelColor: Theme.of(context).primaryColor,
                        unselectedLabelColor: Colors.grey[600],
                        indicatorColor: Theme.of(context).primaryColor,
                        tabs: const [
                          Tab(text: 'All', icon: Icon(Icons.list)),
                          Tab(text: 'Active', icon: Icon(Icons.radio_button_unchecked)),
                          Tab(text: 'Used', icon: Icon(Icons.check_circle)),
                        ],
                      ),
                    ),
                    pinned: true,
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildVoucherList(voucherProvider.vouchers, voucherProvider),
                  _buildVoucherList(voucherProvider.activeVouchers, voucherProvider),
                  _buildVoucherList(voucherProvider.usedVouchers, voucherProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // _buildVoucherList method from profile_screen.dart
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

    List<Voucher> filteredVouchers = selectedStores.isEmpty
        ? vouchers
        : vouchers
            .where((v) =>
                selectedStores.any((s) => s.toLowerCase() == v.storeName.toLowerCase()))
            .toList();

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
                      fontSize: 14,
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
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _showFilterDialog(),
                child: Row(
                  children: [
                    Text(
                      'Filter',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.filter_list, color: Theme.of(context).primaryColor),
                  ],
                ),
              ),
            ],
          ),
        ),
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

  // _showFilterDialog method from profile_screen.dart
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

// _SliverAppBarDelegate class from profile_screen.dart
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.grey[50],
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}