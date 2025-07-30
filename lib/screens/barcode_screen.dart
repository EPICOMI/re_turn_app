import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:screen_brightness/screen_brightness.dart';

class BarcodeScreen extends StatefulWidget {
  final String barcode;

  const BarcodeScreen({super.key, required this.barcode});

  @override
  _BarcodeScreenState createState() => _BarcodeScreenState();
}

class _BarcodeScreenState extends State<BarcodeScreen> {
  double _originalBrightness = 0.5;

  @override
  void initState() {
    super.initState();
    _setBrightness(1.0);
  }

  @override
  void dispose() {
    _resetBrightness();
    super.dispose();
  }

  Future<void> _setBrightness(double brightness) async {
    try {
      _originalBrightness = await ScreenBrightness.instance.current;
      print('Original brightness: $_originalBrightness');
      await ScreenBrightness.instance.setScreenBrightness(brightness);
      print('Brightness set to: $brightness');
    } catch (e) {
      print('Failed to set brightness: $e');
    }
  }

  Future<void> _resetBrightness() async {
    try {
      await ScreenBrightness.instance.setScreenBrightness(_originalBrightness);
      print('Brightness reset to: $_originalBrightness');
    } catch (e) {
      print('Failed to reset brightness: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: BarcodeWidget(
              barcode: Barcode.code128(),
              data: widget.barcode,
              drawText: true,
              color: Colors.black,
              backgroundColor: Colors.white,
              width: MediaQuery.of(context).size.width * 0.9,
              height: 150,
            ),
          ),
        ),
      ),
    );
  }
}
