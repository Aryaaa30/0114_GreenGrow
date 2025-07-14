import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/config/api_config.dart';
import '../../../domain/repositories/activity_repository.dart';
import '../../../domain/models/activity_log.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../../core/providers/auth_provider.dart';
import '../dashboard/farmer_dashboard_screen.dart';
import '../device/device_screen.dart';
import 'activity_history_screen.dart';
import '../settings/settings_screen.dart';
import 'package:image/image.dart' as img;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class UploadActivityScreen extends StatefulWidget {
  final int greenhouseId;
  final int userId;

  const UploadActivityScreen({
    Key? key,
    required this.greenhouseId,
    required this.userId,
  }) : super(key: key);

  @override
  State<UploadActivityScreen> createState() => _UploadActivityScreenState();
}

class _UploadActivityScreenState extends State<UploadActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  String? _activityType;
  File? _photoFile;
  bool _isLoading = false;
  String? _error;

  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('network')) {
      return 'Koneksi internet bermasalah';
    } else if (error.toString().contains('timeout')) {
      return 'Koneksi timeout';
    } else if (error.toString().contains('401')) {
      return 'Sesi anda telah berakhir, silakan login kembali';
    } else if (error.toString().contains('413')) {
      return 'Ukuran foto terlalu besar';
    } else if (error.toString().contains('415')) {
      return 'Format foto tidak didukung';
    }
    return 'Terjadi kesalahan, silakan coba lagi';
  }

  Future<bool> _checkAndRequestPermissions() async {
    final cameraStatus = await Permission.camera.request();
    if (cameraStatus.isDenied) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Izin Kamera Diperlukan'),
            content: const Text(
              'Aplikasi membutuhkan izin untuk mengakses kamera. Silakan berikan izin di pengaturan.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: const Text('Buka Pengaturan'),
              ),
            ],
          ),
        );
      }
      return false;
    }

    final storageStatus = await Permission.storage.request();
    if (storageStatus.isDenied) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Izin Penyimpanan Diperlukan'),
            content: const Text(
              'Aplikasi membutuhkan izin untuk mengakses penyimpanan. Silakan berikan izin di pengaturan.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: const Text('Buka Pengaturan'),
              ),
            ],
          ),
        );
      }
      return false;
    }

    return true;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (pickedFile != null) {
      File file = File(pickedFile.path);
      // Cek ekstensi file
      final ext = file.path.split('.').last.toLowerCase();
      if (ext != 'jpg' && ext != 'jpeg' && ext != 'png') {
        // Konversi ke JPEG
        final bytes = await file.readAsBytes();
        final decoded = img.decodeImage(bytes);
        if (decoded != null) {
          final jpgBytes = img.encodeJpg(decoded);
          final newPath = file.path.replaceAll(RegExp(r'\.[^.]*$'), '.jpg');
          final jpgFile = await File(newPath).writeAsBytes(jpgBytes);
          file = jpgFile;
        }
      }
      setState(() {
        _photoFile = file;
      });
    }
  }

  Future<void> _uploadActivity() async {
    if (!_formKey.currentState!.validate() || _photoFile == null) {
      setState(() { _error = 'Lengkapi semua data dan ambil foto!'; });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_error!)));
      return;
    }
    setState(() { _isLoading = true; _error = null; });
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      final userId = widget.userId;
      if (token == null) throw Exception('Token tidak ditemukan, silakan login ulang.');
      if (userId == 0) {
        setState(() { _error = 'User tidak valid, silakan login ulang.'; });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_error!)));
        setState(() { _isLoading = false; });
        return;
      }
      final uri = Uri.parse('http://10.0.2.2:3000/api/activities');
      var request = http.MultipartRequest('POST', uri);
      request.fields['user_id'] = widget.userId.toString();
      request.fields['greenhouse_id'] = widget.greenhouseId.toString();
      request.fields['activity_type'] = _activityType!;
      request.fields['description'] = _descController.text;
      request.fields['activity_date'] = DateTime.now().toIso8601String();
      // Pastikan nama file dan contentType benar
      String uploadFilePath = _photoFile!.path;
      String uploadFileName = uploadFilePath.split('/').last;
      if (!uploadFileName.endsWith('.jpg') && !uploadFileName.endsWith('.jpeg') && !uploadFileName.endsWith('.png')) {
        uploadFileName = uploadFileName.replaceAll(RegExp(r'\.[^.]*$'), '.jpg');
      }
      final mimeType = lookupMimeType(uploadFilePath) ?? 'image/jpeg';
      request.files.add(
        await http.MultipartFile.fromPath(
          'photo',
          uploadFilePath,
          contentType: MediaType('image', 'jpeg'),
          filename: uploadFileName,
        ),
      );
      request.headers['Authorization'] = 'Bearer $token';
      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aktivitas berhasil diupload!')));
        print('Token setelah upload: \\${authProvider.token}');
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/activity-history');
        }
      } else {
        setState(() { _error = 'Upload gagal: ${response.statusCode}\n$respStr'; });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_error!)));
      }
    } catch (e) {
      setState(() { _error = 'Error: $e'; });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_error!)));
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    int _selectedIndex = 3;
    void _onItemTapped(int index) {
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/');
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/device');
          break;
        case 2:
          Navigator.pushReplacementNamed(context, '/activity-history');
          break;
        case 3:
          // Sudah di halaman ini
          break;
        case 4:
          Navigator.pushReplacementNamed(context, '/settings');
          break;
      }
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Aktivitas')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _photoFile != null
                  ? Stack(
                      children: [
                        Image.file(_photoFile!, height: 180, width: double.infinity, fit: BoxFit.cover),
                        Positioned(
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => setState(() => _photoFile = null),
                          ),
                        ),
                      ],
                    )
                  : ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text('Ambil Foto'),
                    ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _activityType,
                items: const [
                  DropdownMenuItem(value: 'penyiraman', child: Text('Penyiraman')),
                  DropdownMenuItem(value: 'pemupukan', child: Text('Pemupukan')),
                  DropdownMenuItem(value: 'pemangkasan', child: Text('Pemangkasan')),
                ],
                onChanged: (val) => setState(() => _activityType = val),
                validator: (val) => val == null ? 'Pilih tipe aktivitas' : null,
                decoration: const InputDecoration(labelText: 'Tipe Aktivitas'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                validator: (val) => val == null || val.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _uploadActivity,
                      child: const Text('Upload'),
                    ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }
}
