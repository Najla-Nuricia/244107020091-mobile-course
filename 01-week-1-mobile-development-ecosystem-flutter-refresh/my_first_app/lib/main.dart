import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Profil Mahasiswa'),
        ),
        body: const Center(
          child: Column(mainAxisSize:MainAxisSize.min, children: [
            Icon(Icons.person, size: 72),
            SizedBox(height: 16),
            Text('Nama: Najla Nuricia Laudy'),
            Text('NIM: 244107020091'),
            Text('Semester: 5'),
            Text('Pemrograman Mobile - Minggu 1'),
          ]),
        ),
      )
     
      
    );
  }
}
