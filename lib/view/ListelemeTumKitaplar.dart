import 'package:flutter/material.dart';
import 'package:flutter_yazar_sqlite/YerelVeriTabani.dart';
import 'package:flutter_yazar_sqlite/model/kitap_model.dart';

class Listelemetumkitaplar extends StatefulWidget {

  @override
  State<Listelemetumkitaplar> createState() => _ListelemetumkitaplarState();
}

class _ListelemetumkitaplarState extends State<Listelemetumkitaplar> {

  YerelVeriTabani _yerelVeriTabani = YerelVeriTabani();
  List<KitapModel> _tumKitaplar = [];

  TextEditingController _controllerKitapAdi = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _build_appBar(),
      floatingActionButton: _build_fab(context),
      body: _build_body(context),
    );
  }

  //       ***************** Ekran Tasarim Islemleri *****************
  AppBar _build_appBar(){
    return AppBar(
      title: Text("Kitaplar"),
    );
  }

  Widget _build_fab(BuildContext context){
    return FloatingActionButton(
      onPressed: (){
        _ekleKitap(context);
      },
      child: Icon(Icons.add),
    );
  }

  Widget _build_body(BuildContext context){
    return FutureBuilder(
      future: getirTumKitaplar(),
      builder: _build_FutureBuilder
    );
  }

  Widget _build_FutureBuilder(BuildContext context, AsyncSnapshot snapshot){
    return ListView.builder(
      itemCount: _tumKitaplar.length,
      itemBuilder: _build_ListView,
    );
  }

  Widget _build_ListView(BuildContext context, int index){
    DateTime cdate = _tumKitaplar[index].kitap_cdate;
    String formatted_cdate = "${cdate.day}/${cdate.month}/${cdate.year}";
    
    DateTime udate = _tumKitaplar[index].kitap_udate;
    String formatted_udate = "${udate.day}/${udate.month}/${udate.year}";
    
    return Card(
      color: Colors.blueAccent,
      child: ListTile(
        title: Text(
          _tumKitaplar[index].kitap_ad,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        leading: CircleAvatar(
          backgroundColor: Colors.orange,
          child: Text(
            _tumKitaplar[index].kitap_id.toString(),
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Oluşturma Tarihi: $formatted_cdate",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            Text(
              "Son Değiştirme Tarihi: $formatted_udate",
              style: TextStyle(
                color: Colors.white,
              ),
            )
          ],
        ),
        trailing: IconButton(
          onPressed: (){
            _silKitap(context, _tumKitaplar[index]);
          },
          icon: Icon(
            Icons.delete,
            size: 40,
            color: Colors.white,
          ),
        ),
        onTap: (){
          _guncelleKitap(context, index);
        },
      ),
    );
  }

  Future<String?> _build_alert_dialog(
    BuildContext context,
    {KitapModel? updateKitap}
  ){
    return showDialog<String>(
      context: context,
      builder: (context){

        String? kitapAdi;
        if (updateKitap != null){
          _controllerKitapAdi.text = updateKitap.kitap_ad;
        }
        return AlertDialog(
          title: updateKitap != null
              ? Text("Kitap Güncelle")
              : Text("Kitap Ekle"),
          content: TextField(
            controller: _controllerKitapAdi,
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
                      setState(() {
                        _controllerKitapAdi.clear();
                      });
                    },
                    child: Text("Vazgeç")
                ),
                TextButton(
                  onPressed: (){
                    Navigator.pop(context, kitapAdi);
                    setState(() {
                      _controllerKitapAdi.clear();
                    });
                  },
                  child: updateKitap != null
                      ? Text("Güncelle")
                      : Text("Ekle"),
                )
              ],
            )
          ],
        );
      },
    );
  }

  void _ekleKitap(BuildContext context) async {
    String? kitapAdi = await _build_alert_dialog(context);

    if(kitapAdi != null){
      KitapModel kitap = KitapModel(
        kitapAdi,
        DateTime.now(),
        DateTime.now(),
      );
      int eklenen_kitap_id = await _yerelVeriTabani.ekleKitap(kitap);

      if(eklenen_kitap_id != -1){
        setState(() {});
      }
    }
  }

  void _silKitap(BuildContext context, KitapModel kitap) async {
    int silinenSatirSayisi = await _yerelVeriTabani.silKitap(kitap);
    if (silinenSatirSayisi != 0){
      setState(() {});
    }
  }

  void _guncelleKitap(BuildContext context, int index) async {
    String? yeniKitapAdi = await _build_alert_dialog(
      context,
      updateKitap: _tumKitaplar[index],
    );

    if(yeniKitapAdi != null){
      KitapModel kitap = _tumKitaplar[index];
      kitap.kitap_ad = yeniKitapAdi;
      kitap.kitap_udate = DateTime.now();

      int guncellenenSatirSayisi = await _yerelVeriTabani.guncelleKitap(kitap);

      if(guncellenenSatirSayisi > 0){
        setState(() {});
      }
    }
  }

  Future<void> getirTumKitaplar() async {
    _tumKitaplar = await _yerelVeriTabani.getirTumKitaplar();
  }

}
