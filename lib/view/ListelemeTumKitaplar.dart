import 'package:flutter/material.dart';
import 'package:flutter_yazar_sqlite/YerelVeriTabani.dart';

class Listelemetumkitaplar extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _build_appBar(),
      floatingActionButton: _build_fab(),
      //body: _build_body(),
    );
  }

  AppBar _build_appBar(){
    return AppBar(
      title: Text("Kitaplar"),
    );
  }

  Widget _build_fab(){
    return FloatingActionButton(
      onPressed: (){},
      child: Icon(Icons.add),
    );
  }


}
