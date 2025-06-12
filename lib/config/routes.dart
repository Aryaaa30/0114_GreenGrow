import 'package:flutter/material.dart';

class Routes {
  static const String greenhouseMap = '/greenhouse-map';
  
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      greenhouseMap: (context) => const GreenhouseMapScreen(),
    };
  }
} 