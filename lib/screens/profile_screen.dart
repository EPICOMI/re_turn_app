import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:re_turn_app/providers/voucher_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  File? _image;

  String _initialName = 'Re-Turn User';
  String _initialBio = 'Eco-friendly recycler since ${DateTime.now().year}';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _bioController = TextEditingController();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('name') ?? 'Re-Turn User';
      _bioController.text = prefs.getString('bio') ?? 'Eco-friendly recycler since ${DateTime.now().year}';
      final imagePath = prefs.getString('imagePath');
      if (imagePath != null) {
        _image = File(imagePath);
      }
    });
  }

  Future<void> _saveProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _nameController.text);
    await prefs.setString('bio', _bioController.text);
    if (_image != null) {
      await prefs.setString('imagePath', _image!.path);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _cropImage(pickedFile.path);
    }
  }

  Future<void> _cropImage(String filePath) async {
    try {
      // Read the image file
      final originalFile = File(filePath);
      final originalImage = img.decodeImage(await originalFile.readAsBytes());

      if (originalImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load image')),
        );
        return;
      }

      // Calculate square crop dimensions
      final size = originalImage.width < originalImage.height
          ? originalImage.width
          : originalImage.height;
      final x = (originalImage.width - size) ~/ 2;
      final y = (originalImage.height - size) ~/ 2;

      // Crop to square
      final croppedImage = img.copyCrop(
        originalImage,
        x: x,
        y: y,
        width: size,
        height: size,
      );

      // Save cropped image to temporary directory
      final tempDir = await getTemporaryDirectory();
      final croppedFile = File('${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.png');
      await croppedFile.writeAsBytes(img.encodePng(croppedImage));

      setState(() {
        _image = croppedFile;
      });
    } catch (e) {
      debugPrint('Error cropping image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to crop image: $e')),
      );
    }
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Save changes
        _saveProfileData();
      } else {
        // Reset to initial values when entering edit mode
        _loadProfileData();
      }
    });
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _nameController.text = _initialName;
      _bioController.text = _initialBio;
      _image = null; // Or reset to a previously saved image if applicable
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Profile' : 'Profile'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: _isEditing
            ? [
                IconButton(
                  onPressed: _cancelEdit,
                  icon: const Icon(Icons.close),
                ),
                IconButton(
                  onPressed: _toggleEdit,
                  icon: const Icon(Icons.check),
                ),
              ]
            : [
                IconButton(
                  onPressed: () => _showSettingsBottomSheet(context),
                  icon: const Icon(Icons.settings),
                ),
              ],
      ),
      body: Consumer<VoucherProvider>(
        builder: (context, voucherProvider, child) {
          voucherProvider.getStatistics();

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
                      GestureDetector(
                        onTap: _isEditing ? _pickImage : null,
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Theme.of(context).primaryColor,
                          backgroundImage:
                              _image != null ? FileImage(_image!) : null,
                          child: _image == null
                              ? const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // User Info
                      _isEditing
                          ? Column(
                              children: [
                                TextField(
                                  controller: _nameController,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    hintText: 'Enter your name',
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _bioController,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    hintText: 'Enter your bio',
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                Text(
                                  _nameController.text,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _bioController.text,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
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
                    Icons.edit,
                    'Edit Profile',
                    'Change your avatar, name, and bio',
                    () {
                      Navigator.pop(context);
                      _toggleEdit();
                    },
                  ),
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