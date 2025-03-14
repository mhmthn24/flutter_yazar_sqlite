import 'package:flutter/material.dart';

class KitapModel with ChangeNotifier{

  int? kitap_id;
  String kitap_ad;
  DateTime kitap_cdate;
  DateTime kitap_udate;
  int kitap_kategori;
  bool _seciliMi = false;

  bool get seciliMi => _seciliMi;

  set seciliMi(bool value) {
    _seciliMi = value;
    notifyListeners();
  }

  KitapModel(
      this.kitap_ad,
      this.kitap_cdate,
      this.kitap_udate,
      this.kitap_kategori,
  );

  KitapModel.fromMap(Map<String, dynamic> map):
      kitap_id = map["kitap_id"],
      kitap_ad = map["kitap_ad"],
      kitap_cdate = map["kitap_cdate"],
      kitap_udate = map["kitap_udate"],
      kitap_kategori = map["kitap_kategori"];

  Map<String, dynamic> toMap(){
    return {
      "kitap_id": kitap_id,
      "kitap_ad": kitap_ad,
      "kitap_cdate": kitap_cdate,
      "kitap_udate": kitap_udate,
      "kitap_kategori": kitap_kategori
    };
  }

  void guncelleKitap(String yeniIsim, int yeniKategori, DateTime udate){
    kitap_ad = yeniIsim;
    kitap_kategori = yeniKategori;
    kitap_udate = udate;
    notifyListeners();
  }

}