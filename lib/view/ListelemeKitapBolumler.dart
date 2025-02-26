import 'package:flutter/material.dart';
import 'package:flutter_yazar_sqlite/YerelVeriTabani.dart';
import 'package:flutter_yazar_sqlite/model/bolum_model.dart';
import 'package:flutter_yazar_sqlite/model/kitap_model.dart';
import 'package:flutter_yazar_sqlite/view/DetayBolum.dart';

class Listelemekitapbolumler extends StatefulWidget {
  KitapModel _kitap;

  Listelemekitapbolumler(this._kitap, {super.key});

  @override
  State<Listelemekitapbolumler> createState() => _ListelemekitapbolumlerState();
}

class _ListelemekitapbolumlerState extends State<Listelemekitapbolumler> {
  /*
    SQLite veritabanı işlemleri için YerelVeriTabani
    sınıfının bir nesnesi oluşturuldu.
   */
  final YerelVeriTabani _yerelVeriTabani = YerelVeriTabani();

  // Veritabanından çekilen tüm bolumların tutulduğu liste
  List<BolumModel> _tumBolumler = [];

  // Kullanıcının bolum adı girmesi için TextField kontrolcüsü
  final TextEditingController _controllerBolumAdi = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _build_appBar(), // Üst menüyü oluştur
      floatingActionButton: _build_fab(context), // Yeni bolum ekleme butonu
      body: _build_body(context), // Bolum listesini gösteren ana bileşen
    );
  }

  // *************** EKRAN TASARIMI FONKSİYONLARI ***************

  // Uygulamanın üst kısmında bulunan başlık (AppBar)
  AppBar _build_appBar(){
    return AppBar(
      title: Text("Bolumler"), // Sayfa başlığı
    );
  }

  // Yeni bolum eklemek için "+" butonu
  Widget _build_fab(BuildContext context){
    return FloatingActionButton(
      onPressed: (){
        _controllerBolumAdi.clear();
        _ekleBolum(context); // Yeni bolum ekleme fonksiyonunu çağır
      },
      child: Icon(Icons.add), // Buton ikonu
    );
  }

  // Sayfanın ana içeriği: Tüm bolumları listeleyen FutureBuilder
  Widget _build_body(BuildContext context){
    return FutureBuilder(
        future: getirTumBolumlar(), // Veritabanından bolumları alalım
        builder: _build_FutureBuilder
    );
  }

  // FutureBuilder, veriler geldiğinde listeyi oluşturur
  Widget _build_FutureBuilder(BuildContext context, AsyncSnapshot snapshot){
    return ListView.builder(
      itemCount: _tumBolumler.length, // Toplam bolum sayısı
      itemBuilder: _build_ListView, // Her bir kitabı listede göster
    );
  }

  // **ListView içinde tek bir bolum kartını oluşturur**
  Widget _build_ListView(BuildContext context, int index){

    // Oluşturulma tarihini okunaklı bir formata çevirelim
    DateTime cdate = _tumBolumler[index].bolum_cdate;
    String formattedCdate = "${cdate.day}/${cdate.month}/${cdate.year}";

    // Güncellenme tarihini okunaklı bir formata çevir
    DateTime udate = _tumBolumler[index].bolum_udate;
    String formattedUdate = "${udate.day}/${udate.month}/${udate.year}";

    return Card(
      color: Colors.cyanAccent, // Kartın arka plan rengini belirleyelim
      child: ListTile(
        title: Text(
          _tumBolumler[index].bolum_ad, // Bolum adını başlık olarak verelim
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        leading: CircleAvatar(
          backgroundColor: Colors.orange,
          child: Text(
            _tumBolumler[index].bolum_id.toString(), // Bolum ID
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),

        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: (){
                _silBolum(context, _tumBolumler[index]); // Kitabı sil
              },
              icon: Icon(
                Icons.delete,
                size: 40,
                color: Colors.black,
              ),
            ),
            IconButton(
              onPressed: (){
                _guncelleBolum(context, index); // Kitabı guncelle
              },
              icon: Icon(
                Icons.edit,
                size: 40,
                color: Colors.black,
              ),
            ),
          ],
        ),
        onTap: (){
          gitBolumDetay(context, _tumBolumler[index]);
        },
      ),
    );
  }

  // *************** CRUD İŞLEMLERİ ***************

  Future<String?> _build_alert_dialog(
      BuildContext context,
      {BolumModel? updateBolum}
      ){
    /*
    - Yeni bir bolum eklemek veya var olan bir kitabı güncellemek için
      kullanıcıdan bilgi almak için bir giriş ekranı açar.
    - Kullanıcının girdiği bolum adını döndürür.
  */

    return showDialog<String>(
      context: context,
      builder: (context){

        String? bolumAdi;
        if (updateBolum != null){
          _controllerBolumAdi.text = updateBolum.bolum_ad;
        }
        return AlertDialog(
          title: updateBolum != null
              ? Text("Bolum Güncelle")
              : Text("Bolum Ekle"),
          content: TextField(
            controller: _controllerBolumAdi,
            onChanged: (String kullaniciGiris){
              bolumAdi = kullaniciGiris;
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
                        _controllerBolumAdi.clear();
                      });
                    },
                    child: Text("Vazgeç")
                ),
                TextButton(
                  onPressed: (){
                    Navigator.pop(context, bolumAdi);
                    setState(() {
                      _controllerBolumAdi.clear();
                    });
                  },
                  child: updateBolum != null
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

  // Yeni bolum ekleme fonksiyonu
  void _ekleBolum(BuildContext context) async {
    String? bolumBaslik = await _build_alert_dialog(context);
    int? kitap_id = widget._kitap.kitap_id;

    if(bolumBaslik != null && kitap_id != null){
      BolumModel bolum = BolumModel(
        bolumBaslik,
        widget._kitap.kitap_id,
        DateTime.now(),
        DateTime.now(),
      );
      int eklenenBolumId = await _yerelVeriTabani.ekleBolum(bolum);

      if(eklenenBolumId != -1){
        setState(() {});
      }
    }
  }

  // Seçilen kitabı silme fonksiyonu
  void _silBolum(BuildContext context, BolumModel bolum) async {
    int silinenSatirSayisi = await _yerelVeriTabani.silBolum(bolum);
    if (silinenSatirSayisi != 0){
      setState(() {});
    }
  }

  // Seçilen kitabı güncelleme fonksiyonu
  void _guncelleBolum(BuildContext context, int index) async {
    String? yeniBolumBaslik = await _build_alert_dialog(
      context,
      updateBolum: _tumBolumler[index],
    );

    if(yeniBolumBaslik != null){
      BolumModel bolum = _tumBolumler[index];
      bolum.bolum_ad = yeniBolumBaslik;
      bolum.bolum_udate = DateTime.now();

      int guncellenenSatirSayisi = await _yerelVeriTabani.guncelleBolum(bolum);

      if(guncellenenSatirSayisi > 0){
        setState(() {});
      }
    }
  }

  // Veritabanından tüm bolumları getirme fonksiyonu
  Future<void> getirTumBolumlar() async {
    _tumBolumler = await _yerelVeriTabani.getirKitabinTumBolumleri(widget._kitap);
  }

  void gitBolumDetay(BuildContext context, BolumModel bolum){
    MaterialPageRoute gidilecekSayfa = MaterialPageRoute(builder: (context){
      return Detaybolum(bolum);
    });
    Navigator.push(context, gidilecekSayfa);
  }

}
