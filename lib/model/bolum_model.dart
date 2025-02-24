class BolumModel {
  int? bolum_id;
  int? bolum_kitap_id;
  String bolum_ad;
  String bolum_icerik;
  DateTime bolum_cdate;
  DateTime bolum_udate;

  BolumModel(
      this.bolum_ad,
      this.bolum_kitap_id,
      this.bolum_cdate,
      this.bolum_udate,
  ) : bolum_icerik = "";

  BolumModel.fromMap(Map<String, dynamic> map):
    bolum_id = map["bolum_id"],
    bolum_kitap_id = map["bolum_kitap_id"],
    bolum_ad = map["bolum_ad"],
    bolum_icerik = map["bolum_icerik"],
    bolum_cdate = DateTime.fromMillisecondsSinceEpoch(map["bolum_cdate"]),
    bolum_udate = DateTime.fromMillisecondsSinceEpoch(map["bolum_udate"]);

  Map<String, dynamic> toMap(BolumModel bolum){
    return {
      "bolum_id" : bolum_id,
      "bolum_kitap_id" : bolum_kitap_id,
      "bolum_ad" : bolum_ad,
      "bolum_icerik" : bolum_icerik,
      "bolum_cdate" : bolum_cdate,
      "bolum_udate" : bolum_udate,
    };
  }
  
}