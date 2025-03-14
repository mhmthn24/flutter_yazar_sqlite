import 'package:flutter/material.dart';
import 'package:flutter_yazar_sqlite/model/bolum_model.dart';
import 'package:flutter_yazar_sqlite/repository/database_repository.dart';
import 'package:flutter_yazar_sqlite/tools/locator.dart';

class DetayBolumViewModel with ChangeNotifier{

  final DatabaseRepository _databaseRepository = locator<DatabaseRepository>();

  bool _degisiklikVar = false;
  bool get degisiklikVar => _degisiklikVar;
  set degisiklikVar(bool value) {
    _degisiklikVar = value;
    notifyListeners();
  }

  BolumModel _bolum;
  BolumModel get bolum => _bolum;

  TextEditingController _controllerIcerik = TextEditingController();
  TextEditingController get controllerIcerik => _controllerIcerik;

  set controllerIcerik(TextEditingController value) {
    _controllerIcerik = value;
  }

  DetayBolumViewModel(this._bolum){
    _controllerIcerik.text = _bolum.bolum_icerik;
  }

  void icerigiKaydet(String icerik) async {
    _bolum.bolum_icerik = icerik;
    _bolum.bolum_udate = DateTime.now();
    await _databaseRepository.guncelleBolum(_bolum);

    _controllerIcerik.text = icerik; // Güncellenen metni TextField'a geri yaz
    degisiklikVar = false; // Kaydetme tamamlandı
  }

  Future<bool?> buildAlertDialog(BuildContext context){
    return showDialog<bool>(context: context, builder: (context){
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Değişiklikleri kaydetmek ister misiniz?"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text("Hayır"),
                ),
                TextButton(
                  onPressed: (){
                    icerigiKaydet(_controllerIcerik.text);
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text("Evet"),
                ),
              ],
            )
          ],
        ),
      );
    });
  }

}