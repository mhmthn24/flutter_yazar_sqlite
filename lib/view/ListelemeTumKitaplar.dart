import 'package:flutter/material.dart';
import 'package:flutter_yazar_sqlite/YerelVeriTabani.dart';
import 'package:flutter_yazar_sqlite/model/kitap_model.dart';
import 'package:flutter_yazar_sqlite/sabitler.dart';
import 'package:flutter_yazar_sqlite/view/ListelemeKitapBolumler.dart';

/*
  Bu sınıf, SQLite ile saklanan kitapları listelemek ve
  yönetmek için oluşturulmuştur.

  - Tüm kitapları listeleme
  - Yeni kitap ekleme
  - Kitap silme
  - Kitap güncelleme
    işlemlerini yapar.
*/

class Listelemetumkitaplar extends StatefulWidget {
  const Listelemetumkitaplar({super.key});


  @override
  State<Listelemetumkitaplar> createState() => _ListelemetumkitaplarState();
}

class _ListelemetumkitaplarState extends State<Listelemetumkitaplar> {

  /*
    SQLite veritabanı işlemleri için YerelVeriTabani
    sınıfının bir nesnesi oluşturuldu.
   */
  final YerelVeriTabani _yerelVeriTabani = YerelVeriTabani();

  // Veritabanından çekilen tüm kitapların tutulduğu liste
  List<KitapModel> _tumKitaplar = [];

  // Kullanıcının kitap adı girmesi için TextField kontrolcüsü
  final TextEditingController _controllerKitapAdi = TextEditingController();

  List<int> _tumKategoriler = [-1];
  int secilenKategori = -1;

  @override
  void initState() {
    super.initState();
    _tumKategoriler.addAll(Sabitler.kategoriler.keys);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _build_appBar(), // Üst menüyü oluştur
      floatingActionButton: _build_fab(context), // Yeni kitap ekleme butonu
      body: _build_body(context), // Kitap listesini gösteren ana bileşen
    );
  }

  // *************** EKRAN TASARIMI FONKSİYONLARI ***************

  // Uygulamanın üst kısmında bulunan başlık (AppBar)
  AppBar _build_appBar(){
    return AppBar(
      title: Text("Kitaplar"), // Sayfa başlığı
    );
  }

  // Yeni kitap eklemek için "+" butonu
  Widget _build_fab(BuildContext context){
    return FloatingActionButton(
      onPressed: (){
        _controllerKitapAdi.clear();
        _ekleKitap(context); // Yeni kitap ekleme fonksiyonunu çağır
      },
      child: Icon(Icons.add), // Buton ikonu
    );
  }

  // Sayfanın ana içeriği: Tüm kitapları listeleyen FutureBuilder
  Widget _build_body(BuildContext context){
    return FutureBuilder(
      future: getirTumKitaplar(), // Veritabanından kitapları alalım
      builder: _build_FutureBuilder
    );
  }

  // FutureBuilder, veriler geldiğinde listeyi oluşturur
  Widget _build_FutureBuilder(BuildContext context, AsyncSnapshot snapshot){
    return Column(
      children: [
        _build_kategoriler(),
        Expanded(
          child: ListView.builder(
            itemCount: _tumKitaplar.length, // Toplam kitap sayısı
            itemBuilder: _build_ListView, // Her bir kitabı listede göster
          ),
        ),
      ],
    );
  }

  // **ListView içinde tek bir kitap kartını oluşturur**
  Widget _build_ListView(BuildContext context, int index){

    // Oluşturulma tarihini okunaklı bir formata çevirelim
    DateTime cdate = _tumKitaplar[index].kitap_cdate;
    String formattedCdate = "${cdate.day}/${cdate.month}/${cdate.year}";

    // Güncellenme tarihini okunaklı bir formata çevir
    DateTime udate = _tumKitaplar[index].kitap_udate;
    String formattedUdate = "${udate.day}/${udate.month}/${udate.year}";

    return Card(
      color: Colors.cyanAccent, // Kartın arka plan rengini belirleyelim
      child: ListTile(
        title: Text(
          _tumKitaplar[index].kitap_ad, // Kitap adını başlık olarak verelim
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          Sabitler.kategoriler[_tumKitaplar[index].kitap_kategori] ?? "",
        ),
        leading: CircleAvatar(
          backgroundColor: Colors.orange,
          child: Text(
            _tumKitaplar[index].kitap_id.toString(), // Kitap ID
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
                _silKitap(context, _tumKitaplar[index]); // Kitabı sil
              },
              icon: Icon(
                Icons.delete,
                size: 40,
                color: Colors.black,
              ),
            ),
            IconButton(
              onPressed: (){
                _guncelleKitap(context, index); // Kitabı guncelle
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
          gitBolumler(context, _tumKitaplar[index]);
        },
      ),
    );
  }

  Widget _build_kategoriler(){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            "Kategori: ",
            style: TextStyle(
                fontSize: 16
            ),
          ),
          DropdownButton<int>(
            value: secilenKategori,
            items: _tumKategoriler.map((kategoriID){
              return DropdownMenuItem<int>(
                value: kategoriID,
                child: Text(
                  kategoriID == -1
                      ? "Hepsi"
                      : Sabitler.kategoriler[kategoriID] ?? "",
                ),
              );
            }).toList(),
            onChanged: (int? yeniID){
              if (yeniID != null){
                setState(() {
                  secilenKategori = yeniID;
                });
              }
            },
          ),
        ],
      ),
    );
  }
  // *************** CRUD İŞLEMLERİ ***************

  Future<Map<String, dynamic>?> _build_alert_dialog(
    BuildContext context,
    {KitapModel? updateKitap}
  ){
    /*
    - Yeni bir kitap eklemek veya var olan bir kitabı güncellemek için
      kullanıcıdan bilgi almak için bir giriş ekranı açar.
    - Kullanıcının girdiği kitap adını döndürür.
  */

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context){

        String? kitapAdi;
        int kategori = 0;
        if (updateKitap != null){
          _controllerKitapAdi.text = updateKitap.kitap_ad;
          kategori = updateKitap.kitap_kategori;
        }
        return AlertDialog(
          title: updateKitap != null
              ? Text("Kitap Güncelle")
              : Text("Kitap Ekle"),
          content: StatefulBuilder(
            builder: (
              BuildContext context,
              void Function(
                  void Function()
              ) setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _controllerKitapAdi,
                      onChanged: (String kullaniciGiris){
                        kitapAdi = kullaniciGiris;
                      },
                    ),
                    SizedBox(height: 16,),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Kategori: ",
                            style: TextStyle(
                                fontSize: 16
                            ),
                          ),
                          DropdownButton<int>(
                            value: kategori,
                            items: Sabitler.kategoriler.keys.map((kategoriID){
                              return DropdownMenuItem<int>(
                                value: kategoriID,
                                child: Text(Sabitler.kategoriler[kategoriID] ?? ""),
                              );
                            }).toList(),
                            onChanged: (int? yeniID){
                              if (yeniID != null){
                                setState(() {
                                  kategori = yeniID;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
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
                    if (_controllerKitapAdi.text != ""
                        && _controllerKitapAdi.text != null){
                      Map<String, dynamic> alertDialogParams = {
                        "kitap_ad": _controllerKitapAdi.text,
                        "kitap_kategori": kategori,
                      };
                      Navigator.pop(context, alertDialogParams);
                      setState(() {
                        _controllerKitapAdi.clear();
                      });
                    }


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

  // Yeni kitap ekleme fonksiyonu
  void _ekleKitap(BuildContext context) async {

    Map<String, dynamic>? alertGelenParams = await _build_alert_dialog(context);

    if(alertGelenParams != null){
      KitapModel kitap = KitapModel(
          alertGelenParams["kitap_ad"],
          DateTime.now(),
          DateTime.now(),
          alertGelenParams["kitap_kategori"]
      );
      int eklenenKitapId = await _yerelVeriTabani.ekleKitap(kitap);

      if(eklenenKitapId != -1){
        setState(() {});
      }
    }
    /*
    if(kitapAdi != null){
      KitapModel kitap = KitapModel(
        kitapAdi,
        DateTime.now(),
        DateTime.now(),
        Sabitler.kategoriler[]
      );
      int eklenenKitapId = await _yerelVeriTabani.ekleKitap(kitap);

      if(eklenenKitapId != -1){
        setState(() {});
      }
    }
     */
  }

  // Seçilen kitabı silme fonksiyonu
  void _silKitap(BuildContext context, KitapModel kitap) async {
    int silinenSatirSayisi = await _yerelVeriTabani.silKitap(kitap);
    if (silinenSatirSayisi != 0){
      setState(() {});
    }
  }

  // Seçilen kitabı güncelleme fonksiyonu
  void _guncelleKitap(BuildContext context, int index) async {
    Map<String, dynamic>? alertGelenParam = await _build_alert_dialog(
      context,
      updateKitap: _tumKitaplar[index]
    );

    if (alertGelenParam != null){
      KitapModel kitap = _tumKitaplar[index];
      kitap.kitap_ad = alertGelenParam["kitap_ad"];
      kitap.kitap_kategori = alertGelenParam["kitap_kategori"];
      kitap.kitap_udate = DateTime.now();

      int guncellenenSatirSayisi = await _yerelVeriTabani.guncelleKitap(kitap);

      if(guncellenenSatirSayisi > 0){
        setState(() {});
      }
    }
    /*
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

     */
  }

  // Veritabanından tüm kitapları getirme fonksiyonu
  Future<void> getirTumKitaplar() async {
    _tumKitaplar = await _yerelVeriTabani.getirTumKitaplar(secilenKategori);
  }

  void gitBolumler(BuildContext context, KitapModel kitap){
    MaterialPageRoute gidilecekSayfa = MaterialPageRoute(builder: (context){
      return Listelemekitapbolumler(kitap);
    });
    Navigator.push(context, gidilecekSayfa);
  }
}
