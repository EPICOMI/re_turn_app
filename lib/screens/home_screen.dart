import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:re_turn_app/providers/voucher_provider.dart';
import 'package:re_turn_app/widgets/voucher_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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

          final stats = voucherProvider.getStatistics();

          return RefreshIndicator(
            onRefresh: () async {
              await voucherProvider.loadVouchers();
            },
            child: CustomScrollView(
              slivers: [
                // Statistics Header
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Total Value Card
                        Card(
                          elevation: 4,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).primaryColor,
                                  Theme.of(context).primaryColor.withOpacity(0.8),
                                ],
                              ),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Total Available Credit',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '€${voucherProvider.totalValue.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${stats['active']} active vouchers',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Quick Stats Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Total Vouchers',
                                '${stats['total']}',
                                Icons.receipt_long,
                                context,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildStatCard(
                                'Used',
                                '${stats['used']}',
                                Icons.check_circle,
                                context,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Section Header
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Recent Vouchers',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Voucher List
                voucherProvider.vouchers.isEmpty
                    ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No vouchers yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Scan your first re-turn receipt!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    : SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final voucher = voucherProvider.vouchers[index];
                      return VoucherCard(voucher: voucher);
                    },
                    childCount: voucherProvider.vouchers.length,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}