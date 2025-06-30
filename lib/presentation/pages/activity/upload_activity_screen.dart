import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

class UploadActivityScreen extends StatefulWidget {
  final int greenhouseId;

  const UploadActivityScreen({
    super.key,
    required this.greenhouseId,
  });

  @override
  State<UploadActivityScreen> createState() => _UploadActivityScreenState();
}

class _UploadActivityScreenState extends State<UploadActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String _selectedActivityType = 'watering';
  XFile? _selectedImage;
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

  Future<void> _getImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        // Validasi ukuran file
        final file = File(image.path);
        final fileSize = await file.length();
        if (fileSize > 5 * 1024 * 1024) {
          // 5MB
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ukuran foto maksimal 5MB'),
              ),
            );
          }
          return;
        }

        setState(() {
          _selectedImage = image;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error mengambil foto: ${e.toString()}'),
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Sumber Foto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                _getImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                _getImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadActivity() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih foto terlebih dahulu'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final repository = ActivityRepository();
      final now = DateTime.now();

      await repository.createActivityLog(
        greenhouseId: widget.greenhouseId,
        activityType: _selectedActivityType,
        description: _descriptionController.text,
        photo: _selectedImage!,
        token: authProvider.token!,
      );

      if (mounted) {
        Navigator.pop(context, true); // Kembali dan trigger refresh
      }
    } catch (e) {
      setState(() {
        _error = _getErrorMessage(e);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_error!),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Upload Aktivitas'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Mengupload foto...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Aktivitas'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Preview Foto
              if (_selectedImage != null)
                Stack(
                  children: [
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(File(_selectedImage!.path)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _selectedImage = null;
                          });
                        },
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 16),

              // Tombol Ambil Foto
              CustomButton(
                onPressed: _showImageSourceDialog,
                child: const Text('Ambil Foto'),
              ),

              const SizedBox(height: 16),

              // Tipe Aktivitas
              DropdownButtonFormField<String>(
                value: _selectedActivityType,
                decoration: const InputDecoration(
                  labelText: 'Tipe Aktivitas',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'watering',
                    child: Text('Penyiraman'),
                  ),
                  DropdownMenuItem(
                    value: 'fertilizing',
                    child: Text('Pemupukan'),
                  ),
                  DropdownMenuItem(
                    value: 'pruning',
                    child: Text('Pemangkasan'),
                  ),
                  DropdownMenuItem(
                    value: 'pest_control',
                    child: Text('Pengendalian Hama'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedActivityType = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Deskripsi
              CustomTextField(
                controller: _descriptionController,
                labelText: 'Deskripsi',
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  if (value.length < 10) {
                    return 'Deskripsi minimal 10 karakter';
                  }
                  return null;
                },
              ),

              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Tombol Upload
              CustomButton(
                onPressed: _isLoading ? null : _uploadActivity,
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text('Mengupload...'),
                        ],
                      )
                    : const Text('Upload'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 3, // Index untuk tab Aktivitas
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const FarmerDashboardScreen(),
                ),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const DeviceScreen(),
                ),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ActivityHistoryScreen(greenhouseId: widget.greenhouseId),
                ),
              );
              break;
            case 3:
              // Sudah di halaman ini
              break;
            case 4:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(),
                ),
              );
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

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}
