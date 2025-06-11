import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greengrow_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:greengrow_app/presentation/blocs/auth/auth_event.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Konfigurasi Otomatisasi', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Otomatisasi Aktif'),
                        const Spacer(),
                        Switch(value: true, onChanged: (v) {}), // Dummy
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Ambang Suhu (°C)',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: '30',
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Ambang Kelembapan (%)',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: '60',
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Simpan Konfigurasi'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Monitoring Suhu & Kelembapan', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    Text('Suhu: 29°C'),
                    Text('Kelembapan: 65%'),
                    SizedBox(height: 8),
                    Text('Status: Normal'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Status Perangkat', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    Text('Blower: OFF'),
                    Text('Sprayer: ON'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 