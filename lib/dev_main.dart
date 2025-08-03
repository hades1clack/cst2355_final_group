// lib/dev_main.dart

import 'package:flutter/material.dart';
import 'reservation_page.dart'; // Replace with your actual file name

void main() {
  runApp(const DevTestApp());
}

class DevTestApp extends StatelessWidget {
  const DevTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reservation Page Test',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ReservationPage(), // Replace with your page’s widget
    );
  }
}
