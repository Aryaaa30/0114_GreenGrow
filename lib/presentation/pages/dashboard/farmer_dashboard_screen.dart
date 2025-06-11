import 'package:flutter/material.dart';

class FarmerDashboardScreen extends StatelessWidget {
  const FarmerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Dashboard'),
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
                  children: [
                    const Text('Kontrol Perangkat', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Blower'),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text('ON'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text('OFF'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Sprayer'),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text('ON'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text('OFF'),
                        ),
                      ],
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