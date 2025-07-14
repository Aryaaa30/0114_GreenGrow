import 'package:flutter/material.dart';
import '../dashboard/farmer_dashboard_screen.dart';
import '../device/device_screen.dart';
import '../activity/activity_history_screen.dart';
import '../activity/upload_activity_screen.dart';
import '../map/greenhouse_map_screen.dart';
import '../profile/profile_farmer_screen.dart';
import '../privacy/privacy_screen.dart';
import '../notification/notification_screen.dart';
import '../about/about_screen.dart';
import '../supports/supports_screen.dart';
import '../auth/register_screen.dart';
import '../auth/login_screen.dart';
import 'threshold_screen.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Setelan',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Action untuk profile
            },
            icon: const Icon(
              Icons.person_outline,
              color: Colors.black,
              size: 24,
            ),
          ),
        ],
        leading: const SizedBox(), // Menghilangkan back button
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSettingsItem('Akun Saya', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileFarmerScreen(),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  _buildSettingsItem('Privacy', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PrivacyScreen(),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  _buildSettingsItem('Pengaturan Ambang Batas', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ThresholdScreen(),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  _buildSettingsItem('Lokasi Greenhouse', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GreenhouseMapScreen(),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  _buildSettingsItem('Notifikasi', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationScreen(),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  _buildSettingsItem('Tentang Aplikasi', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AboutScreen(),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  _buildSettingsItem('Help & Support', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SupportsScreen(),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  _buildSettingsItem('Add Account', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegisterScreen(),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  _buildSettingsItem('Log out', () {
                    // Handle logout
                    _showLogoutDialog(context);
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 4,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => FarmerDashboardScreen(),
                ),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => DeviceScreen(),
                ),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ActivityHistoryScreen(greenhouseId: 1),
                ),
              );
              break;
            case 3:
              final userIdStr = Provider.of<AuthProvider>(context, listen: false).userId;
              final userId = userIdStr != null ? int.tryParse(userIdStr) ?? 0 : 0;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => UploadActivityScreen(greenhouseId: 1, userId: userId),
                ),
              );
              break;
            case 4:
              // Sudah di halaman ini
              break;
          }
        },
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.developer_board),
            label: 'Control',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_photo_alternate),
            label: 'Aktivitas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(String title, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Hapus token dan redirect ke login
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await authProvider.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false,
                );
              },
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );
  }
}