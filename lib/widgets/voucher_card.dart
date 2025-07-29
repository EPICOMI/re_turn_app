import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:re_turn_app/models/voucher.dart';
import 'package:re_turn_app/providers/voucher_provider.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

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
                        voucher.storeName,
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

class VoucherDetailsSheet extends StatefulWidget {
  final Voucher voucher;

  const VoucherDetailsSheet({super.key, required this.voucher});

  @override
  _VoucherDetailsSheetState createState() => _VoucherDetailsSheetState();
}

class _VoucherDetailsSheetState extends State<VoucherDetailsSheet> {
  final _barcodeKey = GlobalKey();

  Future<Uint8List?> _captureBarcode() async {
    try {
      RenderRepaintBoundary boundary = _barcodeKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print('Error capturing barcode: $e');
      return null;
    }
  }

  Future<bool> _requestStoragePermission() async {
    if (!Platform.isAndroid) {
      return true; // iOS doesn't require storage permissions for photo library
    }

    try {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt ?? 30; // Default to 30 if null
      if (sdkInt > 29) {
        return true; // No storage permission needed for API 30+
      }

      final status = await Permission.storage.request();
      if (status.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Storage permission is permanently denied. Please enable it in settings.'),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: () async {
                  await openAppSettings();
                },
              ),
            ),
          );
        }
      } else if (status.isDenied || status.isRestricted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission denied')),
          );
        }
      }
      return false;
    } catch (e) {
      print('Error checking Android SDK or permissions: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking permissions: $e')),
        );
      }
      return false;
    }
  }

  void _downloadBarcode() async {
    if (!await _requestStoragePermission()) {
      return;
    }

    final imageData = await _captureBarcode();
    if (imageData == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to capture barcode')),
        );
      }
      return;
    }

    try {
      await Gal.putImageBytes(imageData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Barcode saved to gallery')),
        );
      }
    } catch (e) {
      print('Error saving barcode to gallery: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save barcode: ${e.toString().split('\n').first}')),
        );
      }
    }
  }

  void _shareBarcode() async {
    final imageData = await _captureBarcode();
    if (imageData == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to capture barcode')),
        );
      }
      return;
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/barcode_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(imageData);
      if (!await file.exists()) {
        throw Exception('Failed to create temporary file');
      }
      print('Temporary file created at: $filePath');

      final xFile = XFile(file.path, mimeType: 'image/png', name: 'barcode.png');
      final box = context.findRenderObject() as RenderBox?;
      await SharePlus.instance.share(
        ShareParams(
          text: 'Re-Turn Voucher Barcode',
          files: [xFile],
          sharePositionOrigin: box != null ? box.localToGlobal(Offset.zero) & box.size : null,
        ),
      );
      print('Share sheet opened successfully');
    } catch (e) {
      print('Error sharing barcode: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing barcode: ${e.toString().split('\n').first}')),
        );
      }
    } finally {
      // Clean up temporary file
      try {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/barcode_${DateTime.now().millisecondsSinceEpoch}.png');
        if (await file.exists()) {
          await file.delete();
          print('Temporary file deleted');
        }
      } catch (e) {
        print('Error cleaning up temporary file: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM dd, yyyy • HH:mm');

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final maxHeight = constraints.maxHeight;
            // Define proportional spacing to avoid overflow on smaller screens
            final verticalPadding = maxHeight * 0.03;
            final spacing = maxHeight * 0.025;
            final barcodeHeight = maxHeight * 0.12;
            final buttonPadding = maxHeight * 0.02;

            return Container(
              padding: EdgeInsets.fromLTRB(24.0, verticalPadding, 24.0, verticalPadding),
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

                  SizedBox(height: spacing),

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
                            '€${widget.voucher.depositValue.toStringAsFixed(2)} deposit',
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
                          const PopupMenuItem(
                            value: 'download',
                            child: Row(
                              children: [
                                Icon(Icons.download),
                                SizedBox(width: 8),
                                Text('Download'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'share',
                            child: Row(
                              children: [
                                Icon(Icons.share),
                                SizedBox(width: 8),
                                Text('Share'),
                              ],
                            ),
                          ),
                          if (!widget.voucher.isUsed)
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

                  SizedBox(height: spacing),

                  // Barcode Display
                  RepaintBoundary(
                    key: _barcodeKey,
                    child: Container(
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
                            height: barcodeHeight,
                            child: BarcodeWidget(
                              barcode: Barcode.code128(),
                              data: widget.voucher.barcode,
                              drawText: false,
                              color: Colors.black,
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SelectableText(
                            widget.voucher.barcode,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: spacing),

                  // Details
                  _buildDetailRow('Barcode', widget.voucher.barcode),
                  _buildDetailRow('Store', widget.voucher.storeName ?? 'Unknown'),
                  if (widget.voucher.storeLocation != null)
                    _buildDetailRow('Location', widget.voucher.storeLocation!),
                  _buildDetailRow('Created', dateFormat.format(widget.voucher.dateCreated)),
                  if (widget.voucher.isUsed && widget.voucher.usedDate != null)
                    _buildDetailRow('Used', dateFormat.format(widget.voucher.usedDate!)),
                  if (widget.voucher.receiptDateTime != null)
                    _buildDetailRow(
                      'Receipt Date',
                      DateFormat('MMMM dd, yyyy • HH:mm').format(widget.voucher.receiptDateTime!),
                    ),
                  _buildDetailRow(
                    'Status',
                    widget.voucher.isUsed ? 'Used' : 'Active',
                    valueColor: widget.voucher.isUsed ? Colors.grey[600] : Colors.green[700],
                  ),

                  const Spacer(),

                  // Action Button
                  if (!widget.voucher.isUsed)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _markAsUsed(context),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: buttonPadding),
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
        Clipboard.setData(ClipboardData(text: widget.voucher.barcode));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Barcode copied to clipboard')),
        );
        break;
      case 'download':
        _downloadBarcode();
        break;
      case 'share':
        _shareBarcode();
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
            'Are you sure you want to mark this €${widget.voucher.depositValue.toStringAsFixed(2)} voucher as used?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider = Provider.of<VoucherProvider>(context, listen: false);
              final success = await provider.markVoucherAsUsed(widget.voucher.id!);

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
              final success = await provider.deleteVoucher(widget.voucher.id!);

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