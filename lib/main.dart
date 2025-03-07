import 'package:flutter/material.dart';
import 'package:flutter_yazar_sqlite/view/listeleme_kitaplar.dart';

void main() {
  runApp(AnaUygulama());
}

class AnaUygulama extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Listelemetumkitaplar(),
    );
  }
}
