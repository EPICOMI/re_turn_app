import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:re_turn_app/models/voucher.dart';
import 'package:re_turn_app/providers/voucher_provider.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _barcodeController = TextEditingController();
  final _depositController = TextEditingController();
  final _storeNameController = TextEditingController();
  final _storeLocationController = TextEditingController();

  bool _isScanning = false;
  bool _isManualEntry = false;
  Position? _currentPosition;
  String? _currentAddress;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _depositController.dispose();
    _storeNameController.dispose();
    _storeLocationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Voucher'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isManualEntry = !_isManualEntry;
              });
            },
            icon: Icon(_isManualEntry ? Icons.qr_code_scanner : Icons.edit),
            tooltip: _isManualEntry ? 'Switch to Scanner' : 'Manual Entry',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Card(
              elevation: 2,
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor.withOpacity(0.1),
                      Theme.of(context).primaryColor.withOpacity(0.05),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _isManualEntry ? Icons.edit : Icons.qr_code_scanner,
                      size: 48,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isManualEntry ? 'Manual Entry' : 'Scan Voucher',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isManualEntry
                          ? 'Enter voucher details manually'
                          : 'Scan the barcode on your re-turn receipt',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            if (!_isManualEntry) ...[
              // Scanner Buttons
              _buildScanButton(
                'Scan Barcode',
                Icons.qr_code_scanner,
                _scanBarcode,
                isPrimary: true,
              ),
              const SizedBox(height: 12),
              _buildScanButton(
                'Scan from Photo',
                Icons.photo_library,
                _scanFromPhoto,
              ),
              const SizedBox(height: 24),
            ],

            // Manual Entry Form
            if (_isManualEntry || _barcodeController.text.isNotEmpty) ...[
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Barcode Input
                    TextFormField(
                      controller: _barcodeController,
                      decoration: InputDecoration(
                        labelText: 'Barcode *',
                        hintText: 'Enter or scan barcode',
                        prefixIcon: const Icon(Icons.qr_code),
                        suffixIcon: IconButton(
                          onPressed: _scanBarcode,
                          icon: const Icon(Icons.qr_code_scanner),
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a barcode';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Deposit Value Input
                    TextFormField(
                      controller: _depositController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Deposit Value (€) *',
                        hintText: '0.00',
                        prefixIcon: Icon(Icons.euro),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the deposit value';
                        }
                        final deposit = double.tryParse(value);
                        if (deposit == null || deposit <= 0) {
                          return 'Please enter a valid deposit amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Store Name Input
                    TextFormField(
                      controller: _storeNameController,
                      decoration: const InputDecoration(
                        labelText: 'Store Name *',
                        hintText: 'e.g., Lidl, Tesco, SuperValu',
                        prefixIcon: Icon(Icons.store),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a store name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Store Location Input
                    TextFormField(
                      controller: _storeLocationController,
                      decoration: InputDecoration(
                        labelText: 'Store Location',
                        hintText: _currentAddress ?? 'Enter store location',
                        prefixIcon: const Icon(Icons.location_on),
                        suffixIcon: IconButton(
                          onPressed: _useCurrentLocation,
                          icon: const Icon(Icons.my_location),
                        ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Location Info
                    if (_currentAddress != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.blue[700],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Current Location',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                  Text(
                                    _currentAddress!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveVoucher,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Save Voucher',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Help Card
            Card(
              color: Colors.grey[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.help_outline,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'How to use',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '1. Scan the barcode on your re-turn receipt\n'
                          '2. Enter the deposit value shown on the receipt\n'
                          '3. Optionally add store name and location\n'
                          '4. Save to your digital voucher collection',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanButton(
      String title,
      IconData icon,
      VoidCallback onPressed, {
        bool isPrimary = false,
      }) {
    return SizedBox(
      width: double.infinity,
      child: isPrimary
          ? ElevatedButton.icon(
        onPressed: _isScanning ? null : onPressed,
        icon: _isScanning
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Icon(icon),
        label: Text(_isScanning ? 'Scanning...' : title),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      )
          : OutlinedButton.icon(
        onPressed: _isScanning ? null : onPressed,
        icon: Icon(icon),
        label: Text(title),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<void> _scanBarcode() async {
    try {
      setState(() {
        _isScanning = true;
      });

      String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.BARCODE,
      );

      if (barcodeScanRes != '-1' && mounted) {
        _barcodeController.text = barcodeScanRes;
        setState(() {
          _isManualEntry = true;
        });

        // Focus on deposit field after successful scan
        FocusScope.of(context).nextFocus();
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error scanning barcode: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  Future<void> _scanFromPhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null && mounted) {
        // Note: flutter_barcode_scanner doesn't support image scanning
        // This would require a different package or image processing library
        _showInfoSnackBar('Photo scanning not yet implemented. Please enter barcode manually.');
        setState(() {
          _isManualEntry = true;
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error selecting photo: ${e.toString()}');
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition();

      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      if (placemarks.isNotEmpty && mounted) {
        final place = placemarks.first;
        setState(() {
          _currentAddress = [
            if (place.street?.isNotEmpty == true) place.street,
            if (place.locality?.isNotEmpty == true) place.locality,
            if (place.administrativeArea?.isNotEmpty == true) place.administrativeArea,
          ].join(', ');
        });
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  void _useCurrentLocation() {
    if (_currentAddress != null) {
      _storeLocationController.text = _currentAddress!;
    } else {
      _showInfoSnackBar('Location not available. Please check GPS settings.');
    }
  }

  Future<void> _saveVoucher() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final barcode = _barcodeController.text.trim();
    final depositValue = double.parse(_depositController.text.trim());
    final storeName = _storeNameController.text.trim();
    final storeLocation = _storeLocationController.text.trim().isEmpty
        ? null
        : _storeLocationController.text.trim();

    final voucher = Voucher(
      barcode: barcode,
      depositValue: depositValue,
      storeName: storeName,
      storeLocation: storeLocation,
      dateCreated: DateTime.now(),
      latitude: _currentPosition?.latitude,
      longitude: _currentPosition?.longitude,
    );

    try {
      final provider = Provider.of<VoucherProvider>(context, listen: false);
      final success = await provider.addVoucher(voucher);

      if (mounted) {
        if (success) {
          _showSuccessSnackBar('Voucher saved successfully!');
          _clearForm();
        } else {
          _showErrorSnackBar('Failed to save voucher. Barcode may already exist.');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error saving voucher: ${e.toString()}');
      }
    }
  }

  void _clearForm() {
    _barcodeController.clear();
    _depositController.clear();
    _storeNameController.clear();
    _storeLocationController.clear();
    setState(() {
      _isManualEntry = false;
    });
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}