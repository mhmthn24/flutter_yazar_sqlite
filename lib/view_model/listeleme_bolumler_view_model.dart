import 'package:flutter/material.dart';
import 'package:flutter_yazar_sqlite/model/bolum_model.dart';
import 'package:flutter_yazar_sqlite/model/kitap_model.dart';
import 'package:flutter_yazar_sqlite/repository/database_repository.dart';
import 'package:flutter_yazar_sqlite/tools/locator.dart';
import 'package:flutter_yazar_sqlite/view/detay_bolum.dart';
import 'package:flutter_yazar_sqlite/view_model/detay_bolum_view_model.dart';
import 'package:provider/provider.dart';

class ListelemeBolumlerViewModel with ChangeNotifier{

  final DatabaseRepository _databaseRepository = locator<DatabaseRepository>();

  // Kullanıcının bolum adı girmesi için TextField kontrolcüsü
  TextEditingController _controllerBolumAdi = TextEditingController();


  TextEditingController get controllerBolumAdi => _controllerBolumAdi;

  set controllerBolumAdi(TextEditingController value) {
    _controllerBolumAdi = value;
    notifyListeners();
  }

  // Veritabanından çekilen tüm bolumların tutulduğu liste
  List<BolumModel> _tumBolumler = [];

  List<BolumModel> get tumBolumler => _tumBolumler;

  set tumBolumler(List<BolumModel> value) {
    _tumBolumler = value;
  }

  KitapModel _kitap;

  KitapModel get kitap => _kitap;

  ListelemeBolumlerViewModel(this._kitap){
    WidgetsBinding.instance.addPostFrameCallback((_){
      getirTumBolumlar();
    });
  }

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
                      /*
                      setState(() {
                        _controllerBolumAdi.clear();
                      });
                       */
                    },
                    child: Text("Vazgeç")
                ),
                TextButton(
                  onPressed: (){
                    Navigator.pop(context, bolumAdi);
                    /*
                    setState(() {
                      _controllerBolumAdi.clear();
                    });
                     */
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
  void ekleBolum(BuildContext context) async {
    String? bolumBaslik = await _build_alert_dialog(context);
    int? kitap_id = _kitap.kitap_id;

    if(bolumBaslik != null && kitap_id != null){
      BolumModel bolum = BolumModel(
        bolumBaslik,
        _kitap.kitap_id,
        DateTime.now(),
        DateTime.now(),
      );
      int eklenenBolumId = await _databaseRepository.ekleBolum(bolum);

      if(eklenenBolumId != -1){
        bolum.bolum_id = eklenenBolumId;
        _tumBolumler.add(bolum);
        notifyListeners();
      }
    }
  }

  // Seçilen kitabı silme fonksiyonu
  void silBolum(BuildContext context, BolumModel bolum) async {
    int silinenSatirSayisi = await _databaseRepository.silBolum(bolum);
    if (silinenSatirSayisi != 0){
      _tumBolumler.remove(bolum);
      notifyListeners();
    }
  }

  // Seçilen kitabı güncelleme fonksiyonu
  void guncelleBolum(BuildContext context, int index) async {
    String? yeniBolumBaslik = await _build_alert_dialog(
      context,
      updateBolum: _tumBolumler[index],
    );

    if(yeniBolumBaslik != null){
      BolumModel bolum = _tumBolumler[index];
      bolum.bolum_ad = yeniBolumBaslik;
      bolum.bolum_udate = DateTime.now();

      int guncellenenSatirSayisi = await _databaseRepository.guncelleBolum(bolum);

      if(guncellenenSatirSayisi > 0){
        notifyListeners();
      }
    }
  }

  // Veritabanından tüm bolumları getirme fonksiyonu
  Future<void> getirTumBolumlar() async {
    _tumBolumler = await _databaseRepository.getirKitabinTumBolumleri(_kitap);
    notifyListeners();
  }

  void gitBolumDetay(BuildContext context, BolumModel bolum){
    MaterialPageRoute pageRoute = MaterialPageRoute(builder: (context){
      return ChangeNotifierProvider(
        create: (context) => DetayBolumViewModel(bolum),
        child: Detaybolum(),
      );
    });
    Navigator.push(context, pageRoute);
  }

}