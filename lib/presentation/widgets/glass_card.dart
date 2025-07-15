import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  const GlassCard({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class SensorCombinedCard extends StatelessWidget {
  final double? previousTemp;
  final double? currentTemp;
  final double? forecastTemp;
  final double? previousHum;
  final double? currentHum;
  final double? forecastHum;
  const SensorCombinedCard({
    this.previousTemp,
    this.currentTemp,
    this.forecastTemp,
    this.previousHum,
    this.currentHum,
    this.forecastHum,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Kolom Suhu
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Suhu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SensorVerticalValue(
                      previous: previousTemp,
                      current: currentTemp,
                      forecast: forecastTemp,
                      unit: '°C',
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 100,
                color: Colors.white.withOpacity(0.2),
              ),
              // Kolom Kelembapan
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Kelembapan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SensorVerticalValue(
                      previous: previousHum,
                      current: currentHum,
                      forecast: forecastHum,
                      unit: '%',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SensorVerticalValue extends StatelessWidget {
  final double? previous;
  final double? current;
  final double? forecast;
  final String unit;
  const SensorVerticalValue({
    this.previous,
    this.current,
    this.forecast,
    required this.unit,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous (atas)
        Text(
          previous != null ? previous!.toStringAsFixed(1) : '-',
          style: TextStyle(
            fontSize: 20,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
            fontFamily: 'Courier',
          ),
        ),
        // Current (tengah, besar)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              current != null ? current!.toStringAsFixed(1) : '-',
              style: const TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Courier',
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Text(
                unit,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        // Forecast (bawah)
        Text(
          forecast != null ? forecast!.toStringAsFixed(1) : '-',
          style: TextStyle(
            fontSize: 20,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
            fontFamily: 'Courier',
          ),
        ),
      ],
    );
  }
} 