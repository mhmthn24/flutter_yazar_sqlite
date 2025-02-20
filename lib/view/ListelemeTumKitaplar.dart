import 'package:flutter/material.dart';
import 'package:flutter_yazar_sqlite/YerelVeriTabani.dart';
import 'package:flutter_yazar_sqlite/model/kitap_model.dart';

class Listelemetumkitaplar extends StatefulWidget {

  @override
  State<Listelemetumkitaplar> createState() => _ListelemetumkitaplarState();
}

class _ListelemetumkitaplarState extends State<Listelemetumkitaplar> {

  YerelVeriTabani _yerelVeriTabani = YerelVeriTabani();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _build_appBar(),
      floatingActionButton: _build_fab(context),
      //body: _build_body(),
    );
  }

  AppBar _build_appBar(){
    return AppBar(
      title: Text("Kitaplar"),
    );
  }

  Widget _build_fab(BuildContext context){
    return FloatingActionButton(
      onPressed: (){
        ekleKitap(context);
      },
      child: Icon(Icons.add),
    );
  }

  Future<String?> _build_alert_dialog(BuildContext context){
    return showDialog<String>(
      context: context,
      builder: (context){

        String? kitapAdi;

        return AlertDialog(
          title: Text("Kitap Ekle"),
          content: TextField(
            onChanged: (String kullaniciGiris){
              kitapAdi = kullaniciGiris;
            },
          ),
          actions: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    child: Text("Vazgeç")
                ),
                TextButton(
                  onPressed: (){
                    Navigator.pop(context, kitapAdi);
                  },
                  child: Text("Ekle"),
                )
              ],
            )
          ],
        );
      },
    );
  }

  void ekleKitap(BuildContext context) async {
    String? kitapAdi = await _build_alert_dialog(context);

    if(kitapAdi != null){
      KitapModel kitap = KitapModel(
        kitapAdi,
        DateTime.now(),
        DateTime.now(),
      );
      int eklenen_kitap_id = await _yerelVeriTabani.ekleKitap(kitap);
      print("Kitap ID: $eklenen_kitap_id");

      if(eklenen_kitap_id != -1){
        setState(() {});
      }
    }
  }
}
