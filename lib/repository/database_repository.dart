import 'package:flutter_yazar_sqlite/base/database_base.dart';
import 'package:flutter_yazar_sqlite/model/bolum_model.dart';
import 'package:flutter_yazar_sqlite/model/kitap_model.dart';
import 'package:flutter_yazar_sqlite/service/base/database_service.dart';
import 'package:flutter_yazar_sqlite/service/sqflite/sqflite_database_service.dart';
import 'package:flutter_yazar_sqlite/tools/locator.dart';

class DatabaseRepository implements DatabaseBase{

  final DatabaseService _service = locator<SqfliteDatabaseService>();

  // Kitap Methodları
  @override
  Future ekleKitap(KitapModel kitap) async {
    return await _service.ekleKitap(kitap);
  }

  @override
  Future<List<KitapModel>> getirTumKitaplar(int kategori_id, sonKitapID) async {
    return await _service.getirTumKitaplar(kategori_id, sonKitapID);
  }

  @override
  Future<List<KitapModel>> getirKitap(KitapModel kitapParam) async {
    return await _service.getirKitap(kitapParam);
  }

  @override
  Future<int> guncelleKitap(KitapModel kitap) async {
    return await _service.guncelleKitap(kitap);
  }

  @override
  Future<int> silKitap(KitapModel kitap) async {
    return await _service.silKitap(kitap);
  }

  @override
  Future<int> silSecilenKitaplar(List kitapIDList) async {
    return await _service.silSecilenKitaplar(kitapIDList);
  }

  // Bolum Methodları
  @override
  Future ekleBolum(BolumModel bolum) async {
    return await _service.ekleBolum(bolum);
  }

  @override
  Future<List<BolumModel>> getirBolum(BolumModel bolum) async {
    return await _service.getirBolum(bolum);
  }

  @override
  Future<List<BolumModel>> getirKitabinTumBolumleri(KitapModel kitap) async {
    return await _service.getirKitabinTumBolumleri(kitap);
  }

  @override
  Future<int> guncelleBolum(BolumModel bolum) async {
    return await _service.guncelleBolum(bolum);
  }

  @override
  Future<int> silBolum(BolumModel bolum) async {
    return await _service.silBolum(bolum);
  }


  
}