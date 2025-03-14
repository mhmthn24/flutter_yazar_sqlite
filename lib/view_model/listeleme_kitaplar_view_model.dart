import 'package:flutter/material.dart';
import 'package:flutter_yazar_sqlite/model/kitap_model.dart';
import 'package:flutter_yazar_sqlite/repository/database_repository.dart';
import 'package:flutter_yazar_sqlite/tools/locator.dart';
import 'package:flutter_yazar_sqlite/tools/sabitler.dart';
import 'package:flutter_yazar_sqlite/view/listeleme_bolumler.dart';
import 'package:flutter_yazar_sqlite/view_model/listeleme_bolumler_view_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class ListelemeKitaplarViewModel with ChangeNotifier{

  final DatabaseRepository _databaseRepository = locator<DatabaseRepository>();

  // Veritabanından çekilen tüm kitapların tutulduğu liste
  List<KitapModel> _tumKitaplar = [];
  List<KitapModel> get tumKitaplar => _tumKitaplar;

  // Kullanıcının kitap adı girmesi için TextField kontrolcüsü
  final TextEditingController _controllerKitapAdi = TextEditingController();

  final ScrollController _controllerScroll = ScrollController();
  ScrollController get controllerScroll => _controllerScroll;

  List<int> _tumKategoriler = [-1];

  List<int> get tumKategoriler => _tumKategoriler;

  List<int> _secilenKitapID = [];
  bool _tumKitaplariSec = false;

  bool get tumKitaplariSec => _tumKitaplariSec;

  set tumKitaplariSec(bool value) {
    _tumKitaplariSec = value;
    notifyListeners();
  }

  List<int> get secilenKitapID => _secilenKitapID;

  int _secilenKategori = -1;
  int get secilenKategori => _secilenKategori;

  set secilenKategori(int value) {
    _secilenKategori = value;
    notifyListeners();
  }

  TextEditingController get controllerKitapAdi => _controllerKitapAdi;

  ListelemeKitaplarViewModel(){
    _tumKategoriler.addAll(Sabitler.kategoriler.keys);
    _controllerScroll.addListener(_kaydirmaKontrol);

    WidgetsBinding.instance.addPostFrameCallback((_){
      getirIlkKitaplar();
    });
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
                      /*
                      setState(() {
                        _controllerKitapAdi.clear();
                      });
                       */
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
                      /*
                      setState(() {
                        _controllerKitapAdi.clear();
                      });
                       */
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
  void ekleKitap(BuildContext context) async {

    Map<String, dynamic>? alertGelenParams = await _build_alert_dialog(context);

    if(alertGelenParams != null){
      KitapModel kitap = KitapModel(
          alertGelenParams["kitap_ad"],
          DateTime.now(),
          DateTime.now(),
          alertGelenParams["kitap_kategori"]
      );
      int eklenenKitapId = await _databaseRepository.ekleKitap(kitap);

      if(eklenenKitapId != -1){
        notifyListeners();
      }
    }
  }

  // Seçilen kitabı silme fonksiyonu
  void silKitap(BuildContext context, KitapModel kitap) async {
    int silinenSatirSayisi = await _databaseRepository.silKitap(kitap);
    if (silinenSatirSayisi >= 0){
      _tumKitaplar.remove(kitap);
      notifyListeners();
    }
  }

  void secilenKitaplariSil() async {
    int silinenSatirSayisi = await _databaseRepository.silSecilenKitaplar(_secilenKitapID);
    if(silinenSatirSayisi != 0){
      _tumKitaplar.removeWhere((kitap) => _secilenKitapID.contains(kitap.kitap_id));
      _secilenKitapID.clear();
      notifyListeners();
    }
  }

  // Seçilen kitabı güncelleme fonksiyonu
  void guncelleKitap(BuildContext context, int index) async {
    Map<String, dynamic>? alertGelenParam = await _build_alert_dialog(
        context,
        updateKitap: _tumKitaplar[index]
    );
    KitapModel _kitap = _tumKitaplar[index];
    if (alertGelenParam != null){
      String yeniIsim = alertGelenParam["kitap_ad"];
      int yeniKategori = alertGelenParam["kitap_kategori"];
      DateTime udate = DateTime.now();
      _kitap.guncelleKitap(yeniIsim, yeniKategori, udate);
      await _databaseRepository.guncelleKitap(_kitap);
    }
  }

  // Veritabanından tüm kitapları getirme fonksiyonu
  Future<void> getirIlkKitaplar() async {
    if(_tumKitaplar.isEmpty){
      _tumKitaplar = await _databaseRepository.getirTumKitaplar(_secilenKategori, 0);
    }
    notifyListeners();
  }

  Future<void> getirSonrakiKitaplar() async {
    int? sonKitapID = _tumKitaplar.last.kitap_id;

    if(sonKitapID != null){
      List<KitapModel> sonrakiKitaplar = await _databaseRepository.getirTumKitaplar(
        _secilenKategori,
        sonKitapID,
      );
      _tumKitaplar.addAll(sonrakiKitaplar);
      notifyListeners();
    }
  }

  void gitBolumler(BuildContext context, KitapModel kitap){
    MaterialPageRoute gidilecekSayfa = MaterialPageRoute(builder: (context){
      return ChangeNotifierProvider(create: (context) => ListelemeBolumlerViewModel(kitap), child: Listelemekitapbolumler(),);
    });
    Navigator.push(context, gidilecekSayfa);
  }

  void _kaydirmaKontrol() {
    if(_controllerScroll.offset == _controllerScroll.position.maxScrollExtent){
      getirSonrakiKitaplar();
    }
  }

}