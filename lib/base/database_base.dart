import 'package:flutter_yazar_sqlite/model/bolum_model.dart';
import 'package:flutter_yazar_sqlite/model/kitap_model.dart';

abstract class DatabaseBase {

  // Kitap CRUD İşlemleri
  Future<dynamic> ekleKitap(KitapModel kitap);

  Future<List<KitapModel>> getirTumKitaplar(int kategori_id, dynamic sonKitapID);

  Future<List<KitapModel>> getirKitap(KitapModel kitapParam);

  Future<int> guncelleKitap(KitapModel kitap);

  Future<int> silKitap(KitapModel kitap);

  Future<int> silSecilenKitaplar(List<dynamic> kitapIDList);

  // Bölüm CRUD İşlemleri
  Future<dynamic> ekleBolum(BolumModel bolum);

  Future<List<BolumModel>> getirBolum(BolumModel bolum);

  Future<List<BolumModel>> getirKitabinTumBolumleri(KitapModel kitap);

  Future<int> guncelleBolum(BolumModel bolum);

  Future<int> silBolum(BolumModel bolum);

}