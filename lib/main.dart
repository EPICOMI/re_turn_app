import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:re_turn_app/providers/voucher_provider.dart';
import 'package:re_turn_app/screens/home_screen.dart';
import 'package:re_turn_app/screens/scan_screen.dart';
import 'package:re_turn_app/screens/profile_screen.dart';
import 'package:re_turn_app/database/database_helper.dart';
import 'dart:io' show Platform;  // Add this import
import 'package:sqflite_common_ffi/sqflite_ffi.dart';  // Add this import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database factory for desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();  // Initialize FFI
    databaseFactory = databaseFactoryFfi;  // Set the database factory
  }

  // Initialize database
  await DatabaseHelper.instance.database;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => VoucherProvider(databaseHelper: DatabaseHelper.instance),
      child: MaterialApp(
        title: 'Re-Turn Digital',
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.light,
          ),
        ),
        home: const MainNavigationScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

import 'dart:async';

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  Timer? _timer;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ScanScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _startVoucherCleanupTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startVoucherCleanupTimer() {
    // Run the cleanup task every 24 hours
    _timer = Timer.periodic(const Duration(hours: 24), (timer) {
      final voucherProvider =
          Provider.of<VoucherProvider>(context, listen: false);
      voucherProvider.deleteOldVouchers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}