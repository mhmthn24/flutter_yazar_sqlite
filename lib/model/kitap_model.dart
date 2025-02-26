class KitapModel {

  int? kitap_id;
  String kitap_ad;
  DateTime kitap_cdate;
  DateTime kitap_udate;
  int kitap_kategori;

  KitapModel(
      this.kitap_ad,
      this.kitap_cdate,
      this.kitap_udate,
      this.kitap_kategori,
  );

  KitapModel.fromMap(Map<String, dynamic> map):
      kitap_id = map["kitap_id"],
      kitap_ad = map["kitap_ad"],
      kitap_cdate = DateTime.fromMillisecondsSinceEpoch(map["kitap_cdate"]),
      kitap_udate = DateTime.fromMillisecondsSinceEpoch(map["kitap_udate"]),
      kitap_kategori = map["kitap_kategori"];

  Map<String, dynamic> toMap(){
    return {
      "kitap_id": kitap_id,
      "kitap_ad": kitap_ad,
      "kitap_cdate": kitap_cdate.millisecondsSinceEpoch,
      "kitap_udate": kitap_udate.millisecondsSinceEpoch,
      "kitap_kategori": kitap_kategori
    };
  }

}