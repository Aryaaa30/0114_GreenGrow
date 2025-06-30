import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        title: const Text(
          'Tentang Aplikasi',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[400]!, Colors.green[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.eco,
                      size: 60,
                      color: Colors.green[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'GreenGrow',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Smart Greenhouse Monitoring',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Versi 1.0.0',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Overview Section
            _buildInfoSection(
              'Tentang GreenGrow',
              [
                _buildInfoText(
                  'GreenGrow adalah aplikasi mobile berbasis Flutter yang dikembangkan khusus untuk membantu petani melon di greenhouse dalam memantau dan mengendalikan kondisi lingkungan secara real-time.',
                ),
                const SizedBox(height: 12),
                _buildInfoText(
                  'Aplikasi ini memberikan solusi monitoring dan kontrol jarak jauh berbasis IoT yang efisien dan ramah pengguna, sehingga petani dapat merespons cepat terhadap perubahan kondisi greenhouse.',
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Key Features
            _buildInfoSection(
              'Fitur Utama',
              [
                _buildFeatureItem(
                  Icons.thermostat,
                  'Monitoring Real-time',
                  'Pantau suhu dan kelembapan greenhouse secara langsung dari smartphone',
                ),
                _buildFeatureItem(
                  Icons.settings_remote,
                  'Kontrol Jarak Jauh',
                  'Kendali blower dan sprayer dari mana saja tanpa perlu ke lokasi',
                ),
                _buildFeatureItem(
                  Icons.auto_mode,
                  'Otomatisasi Cerdas',
                  'Sistem otomatis mengatur perangkat berdasarkan ambang batas yang ditentukan',
                ),
                _buildFeatureItem(
                  Icons.history,
                  'Riwayat Lengkap',
                  'Simpan dan analisis data historis sensor untuk evaluasi pertanian',
                ),
                _buildFeatureItem(
                  Icons.photo_camera,
                  'Dokumentasi Visual',
                  'Upload foto bukti perawatan tanaman untuk monitoring yang lebih baik',
                ),
                _buildFeatureItem(
                  Icons.map,
                  'Integrasi GPS',
                  'Tampilkan lokasi greenhouse di peta untuk memudahkan navigasi',
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Target Users
            _buildInfoSection(
              'Pengguna Target',
              [
                _buildUserTypeItem(
                  Icons.agriculture,
                  'Petani Melon',
                  'Monitoring dan kontrol greenhouse secara langsung',
                  Colors.green,
                ),
                _buildUserTypeItem(
                  Icons.admin_panel_settings,
                  'Admin Greenhouse',
                  'Konfigurasi sistem dan pengaturan otomatisasi',
                  Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Technical Info
            _buildInfoSection(
              'Informasi Teknis',
              [
                _buildTechItem('Platform', 'Android'),
                _buildTechItem('Framework', 'Flutter'),
                _buildTechItem('Arsitektur', 'Clean Architecture'),
                _buildTechItem('State Management', 'BLoC Pattern'),
                _buildTechItem('Database Lokal', 'SQLite'),
                _buildTechItem('Database Server', 'MySQL'),
                _buildTechItem('Hardware', 'ESP32 + Sensor DHT22'),
                _buildTechItem('Konektivitas', 'WiFi + Internet'),
              ],
            ),
            const SizedBox(height: 20),

            // Development Timeline
            _buildInfoSection(
              'Timeline Pengembangan',
              [
                _buildTimelineItem('Mei 2025', 'Mulai pengembangan', true),
                _buildTimelineItem('Juni 2025', 'Development fase 1 (P0 features)', true),
                _buildTimelineItem('Juli 2025', 'Integration & Testing', false),
                _buildTimelineItem('Akhir Semester Ganjil 2025', 'Release versi 1.0', false),
              ],
            ),
            const SizedBox(height: 20),

            // Contact & Support
            _buildInfoSection(
              'Kontak & Dukungan',
              [
                _buildContactItem(
                  Icons.email,
                  'Email',
                  'support@greengrow.app',
                  () => _showContactDialog(context, 'Email'),
                ),
                _buildContactItem(
                  Icons.phone,
                  'WhatsApp',
                  '+62 812-3456-7890',
                  () => _showContactDialog(context, 'WhatsApp'),
                ),
                _buildContactItem(
                  Icons.web,
                  'Website',
                  'www.greengrow.app',
                  () => _showContactDialog(context, 'Website'),
                ),
                _buildContactItem(
                  Icons.bug_report,
                  'Laporkan Bug',
                  'Bantu kami tingkatkan aplikasi',
                  () => _showBugReportDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Credits
            _buildInfoSection(
              'Pengembang',
              [
                _buildInfoText(
                  'GreenGrow dikembangkan sebagai solusi inovatif untuk mendukung petani Indonesia dalam mengoptimalkan hasil pertanian melalui teknologi IoT dan monitoring cerdas.',
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    '🌱 Developed with 💚 for Indonesian Farmers',
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.green[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '© 2025 GreenGrow',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Smart Agriculture Technology',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        height: 1.5,
        color: Colors.grey[700],
      ),
      textAlign: TextAlign.justify,
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.green[700],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTypeItem(IconData icon, String title, String description, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': ', style: TextStyle(fontSize: 14)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String date, String milestone, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green : Colors.grey[300],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  milestone,
                  style: TextStyle(
                    fontSize: 14,
                    color: isCompleted ? Colors.green[700] : Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (isCompleted)
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 16,
            ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.green[700]),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  void _showContactDialog(BuildContext context, String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hubungi via $type'),
        content: Text('Anda akan diarahkan ke aplikasi $type untuk menghubungi tim dukungan GreenGrow.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement actual contact functionality
            },
            child: const Text('Lanjutkan'),
          ),
        ],
      ),
    );
  }

  void _showBugReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Laporkan Bug'),
        content: const Text('Terima kasih telah membantu kami meningkatkan GreenGrow! Anda akan diarahkan ke formulir pelaporan bug.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement bug report functionality
            },
            child: const Text('Laporkan'),
          ),
        ],
      ),
    );
  }
}