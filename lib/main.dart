import 'package:flutter/material.dart';
import 'package:flutter_yazar_sqlite/tools/locator.dart';
import 'package:flutter_yazar_sqlite/view/listeleme_kitaplar.dart';
import 'package:flutter_yazar_sqlite/view_model/listeleme_kitaplar_view_model.dart';
import 'package:provider/provider.dart';

void main() {
  setupLocator();
  runApp(AnaUygulama());
}

class AnaUygulama extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChangeNotifierProvider(
        create: (context) => ListelemeKitaplarViewModel(),
        child: Listelemetumkitaplar(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
