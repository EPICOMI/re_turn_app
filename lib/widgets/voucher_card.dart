import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:re_turn_app/models/voucher.dart';
import 'package:re_turn_app/providers/voucher_provider.dart';

class VoucherCard extends StatelessWidget {
  final Voucher voucher;

  const VoucherCard({super.key, required this.voucher});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy • HH:mm');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: voucher.isUsed ? 1 : 3,
      child: InkWell(
        onTap: () => _showVoucherDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: voucher.isUsed ? Colors.grey[50] : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Deposit Value
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 6.0,
                    ),
                    decoration: BoxDecoration(
                      color: voucher.isUsed
                          ? Colors.grey[300]
                          : Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '€${voucher.depositValue.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: voucher.isUsed ? Colors.grey[700] : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),

                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: voucher.isUsed ? Colors.grey[300] : Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          voucher.isUsed ? Icons.check_circle : Icons.radio_button_unchecked,
                          size: 14,
                          color: voucher.isUsed ? Colors.grey[600] : Colors.green[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          voucher.isUsed ? 'Used' : 'Active',
                          style: TextStyle(
                            color: voucher.isUsed ? Colors.grey[600] : Colors.green[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Store Information
              if (voucher.storeName != null || voucher.storeLocation != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.store,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        voucher.storeName ?? 'Unknown Store',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: voucher.isUsed ? Colors.grey[600] : null,
                        ),
                      ),
                    ),
                  ],
                ),
                if (voucher.storeLocation != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          voucher.storeLocation!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
              ],

              // Date Information
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Created: ${dateFormat.format(voucher.dateCreated)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),

              if (voucher.isUsed && voucher.usedDate != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Used: ${dateFormat.format(voucher.usedDate!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),

              // Barcode Preview (truncated)
              Row(
                children: [
                  Icon(
                    Icons.qr_code,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      voucher.barcode,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _showVoucherDetails(context),
                    child: const Text('View'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVoucherDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => VoucherDetailsSheet(voucher: voucher),
    );
  }
}

class VoucherDetailsSheet extends StatelessWidget {
  final Voucher voucher;

  const VoucherDetailsSheet({super.key, required this.voucher});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM dd, yyyy • HH:mm');

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
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

              const SizedBox(height: 24),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Voucher Details',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        '€${voucher.depositValue.toStringAsFixed(2)} deposit',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleMenuAction(context, value),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'copy',
                        child: Row(
                          children: [
                            Icon(Icons.copy),
                            SizedBox(width: 8),
                            Text('Copy Barcode'),
                          ],
                        ),
                      ),
                      if (!voucher.isUsed)
                        const PopupMenuItem(
                          value: 'mark_used',
                          child: Row(
                            children: [
                              Icon(Icons.check_circle),
                              SizedBox(width: 8),
                              Text('Mark as Used'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Barcode Display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // Barcode Widget
                    SizedBox(
                      height: 80,
                      child: BarcodeWidget(
                        barcode: Barcode.code128(),
                        data: voucher.barcode,
                        drawText: false,
                        color: Colors.black,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SelectableText(
                      voucher.barcode,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Details
              _buildDetailRow('Store', voucher.storeName ?? 'Unknown'),
              if (voucher.storeLocation != null)
                _buildDetailRow('Location', voucher.storeLocation!),
              _buildDetailRow('Created', dateFormat.format(voucher.dateCreated)),
              if (voucher.isUsed && voucher.usedDate != null)
                _buildDetailRow('Used', dateFormat.format(voucher.usedDate!)),
              _buildDetailRow(
                'Status',
                voucher.isUsed ? 'Used' : 'Active',
                valueColor: voucher.isUsed ? Colors.grey[600] : Colors.green[700],
              ),

              const Spacer(),

              // Action Button
              if (!voucher.isUsed)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _markAsUsed(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Mark as Used'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'copy':
        Clipboard.setData(ClipboardData(text: voucher.barcode));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Barcode copied to clipboard')),
        );
        break;
      case 'mark_used':
        _markAsUsed(context);
        break;
      case 'delete':
        _deleteVoucher(context);
        break;
    }
  }

  void _markAsUsed(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Used'),
        content: Text(
            'Are you sure you want to mark this €${voucher.depositValue.toStringAsFixed(2)} voucher as used?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider = Provider.of<VoucherProvider>(context, listen: false);
              final success = await provider.markVoucherAsUsed(voucher.id!);

              if (context.mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close bottom sheet

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Voucher marked as used'
                          : 'Failed to mark voucher as used',
                    ),
                  ),
                );
              }
            },
            child: const Text('Mark Used'),
          ),
        ],
      ),
    );
  }

  void _deleteVoucher(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Voucher'),
        content: const Text('Are you sure you want to delete this voucher? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider = Provider.of<VoucherProvider>(context, listen: false);
              final success = await provider.deleteVoucher(voucher.id!);

              if (context.mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close bottom sheet

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Voucher deleted'
                          : 'Failed to delete voucher',
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}