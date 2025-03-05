import 'dart:async';

import 'package:flutter_yazar_sqlite/model/bolum_model.dart';
import 'package:flutter_yazar_sqlite/model/kitap_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class YerelVeriTabani {

  /*
    Bu sınıf, SQLite kullanarak bir yerel veri tabanı yönetimi sağlar.
                SINGLETON tasarım deseni uygulanmıştır.
    Böylece her yerden tek bir veri tabanı bağlantısı ile çalışabiliriz.
  */

  // Özel (private) constructor oluşturuyoruz.
  // Bu sayede bu sınıfın doğrudan bir nesnesi OLUŞTURULAMAZ.
  YerelVeriTabani._privateConstructor();

  // Singleton nesnesi oluşturuyoruz.
  // Tüm uygulama boyunca sadece TEK BİR NESNE kullanılmasını sağlıyoruz.
  static final YerelVeriTabani _nesne = YerelVeriTabani._privateConstructor();

  // factory constructor kullanarak singleton nesneyi döndürüyoruz.
  factory YerelVeriTabani() {
    return _nesne;
  }

  // Veri tabanı bağlantısını tutacak değişken
  Database? _database;

  // Kitap Tablo ve sütun isimlerini sabit değişkenler olarak tanımlıyoruz.
  final String _kitap_tablo_adi = "kitap";  // Tablo adı
  final String _kitap_id = "kitap_id";      // Kitapların benzersiz ID'si
  final String _kitap_ad = "kitap_ad";      // Kitap adı
  final String _kitap_cdate = "kitap_cdate"; // Kitabın oluşturulma tarihi (milisaniye cinsinden)
  final String _kitap_udate = "kitap_udate"; // Kitabın güncellenme tarihi (milisaniye cinsinden)
  final String _kitap_kategori = "kitap_kategori"; // Kitabın kategori tablo adı

  // Bölüm Tablo ve sütun isimlerini sabit değişkenler olarak tanımlıyoruz.
  final String _bolum_tablo_adi = "bolumler";
  final String _bolum_id = "bolum_id";
  final String _bolum_kitap_id = "bolum_kitap_id";
  final String _bolum_ad = "bolum_ad";
  final String _bolum_icerik = "bolum_icerik";
  final String _bolum_cdate = "bolum_cdate";
  final String _bolum_udate = "bolum_udate";

  Future<Database> _getDatabase() async {
    /*
    Veri tabanı bağlantısını açma (veya oluşturma) fonksiyonu

    - Eğer veri tabanı zaten açıksa, onu döndür.
    - Eğer veri tabanı yoksa, `_createTable` fonksiyonu çağrılarak
      yeni bir veri tabanı oluştur.
  */

    if (_database != null) {
      // Eğer veri tabanı zaten açıksa, mevcut nesneyi döndür
      return _database!;
    }

    // Veri tabanının dosya yolunu al
    String filePath = await getDatabasesPath();
    String databasePath = join(filePath, "yazarYeni.db"); // Veri tabanı adı

    // SQLite veri tabanını aç veya oluştur
    _database = await openDatabase(
        // Veri tabanı yolunu veriyoruz
        databasePath,
        // Veri tabanı versiyonu (Eğer yapısal değişiklik olursa artırılmalı)
        version: 2,
        // Eğer veri tabanı yoksa bu fonksiyon çağrılacak
        onCreate: _createTable,
        // Veri tabanı versiyonu değişince bu fonksiyon çalışacak
        onUpgrade: _updateTable
    );

    return _database!;
  }

  Future<void> _createTable(Database db, int version) async {
    /*
    Tabloyu oluşturma fonksiyonu

    - Eğer veri tabanı daha önce oluşturulmadıysa, bu fonksiyon çağrılarak
      'kitaplar' ve 'bolumler' tabloları oluşturulur.

    - `_cdate` ve `_udate` sütunları INTEGER olarak tanımlandı.
      Çünkü tarih bilgileri 'millisecondsSinceEpoch' formatında kaydedilecek.
  */

    await db.execute(
        """
      CREATE TABLE $_kitap_tablo_adi (
        $_kitap_id INTEGER NOT NULL UNIQUE PRIMARY KEY AUTOINCREMENT,  -- Benzersiz kitap ID'si
        $_kitap_ad TEXT NOT NULL,  -- Kitap adı zorunlu
        $_kitap_cdate INTEGER,  -- Kitabın oluşturulma tarihi (millisecondsSinceEpoch formatında)
        $_kitap_udate INTEGER,   -- Kitabın güncellenme tarihi (millisecondsSinceEpoch formatında)
        $_kitap_kategori INTEGER DEFAULT 0
      );
      """
    );

    await db.execute(
        """
      CREATE TABLE $_bolum_tablo_adi (
        -- Benzersiz kitap ID'si
        $_bolum_id INTEGER NOT NULL UNIQUE PRIMARY KEY AUTOINCREMENT,  
        -- Kitap ID bilgisi zorunlu
        $_bolum_kitap_id INTEGER NOT NULL,  
        -- Bölüm adı zorunlu
        $_bolum_ad TEXT NOT NULL,  
        -- Kitap adı zorunlu
        $_bolum_icerik TEXT,  
        -- Bölümün oluşturulma tarihi (millisecondsSinceEpoch formatında)
        $_bolum_cdate INTEGER,  
        -- Bölümün güncellenme tarihi (millisecondsSinceEpoch formatında)
        $_bolum_udate INTEGER,
        FOREIGN KEY($_bolum_kitap_id) REFERENCES $_kitap_tablo_adi($_kitap_id) 
        ON UPDATE CASCADE ON DELETE CASCADE    
      );
      """
    );
  }

  Future<void> _updateTable(
      Database db,
      int oldVersion,
      int newVersion,
  ) async {

    // Eğer veri tabanında güncelleme yapılacaksa komutu listeye ekleyelim.
    List<String> guncellemeler = [
      "ALTER TABLE $_kitap_tablo_adi ADD COLUMN $_kitap_kategori INTEGER DEFAULT 0"
    ];

    for(int i = oldVersion-1; i < newVersion-1; i++){
      await db.execute(guncellemeler[i]);
    }

  }

  // ********************** Kitap Model **********************
  // *********** CRUD (Create, Read, Update, Delete) Operasyonları ***********

  Future<int> ekleKitap(KitapModel kitap) async {
    /*
    - Yeni bir kitap eklemek için kullanılır.
    - "KitapModel" sınıfından bir kitap nesnesi alır ve veritabanına ekler.
    - Eğer işlem başarılı olursa eklenen kaydın ID'sini döndürür.
    - Eğer veritabanı bağlantısı başarısız olursa `-1` döndürerek hata olduğunu belirtir.
  */
    Database? db = await _getDatabase();

    if(db != null){
      // Eğer bağlantı başarılıysa kitabı ekleyelim ve
      // eklenen verinin ID değerini döndürelim
      return await db.insert(_kitap_tablo_adi, kitap.toMap());
    }else{
      // Başarısızsa -1 hata kodu döndürelim.
      return -1;
    }
  }

  Future<List<KitapModel>> getirTumKitaplar(int kategori_id, int sonKitapID) async {
    /*
    - Veritabanında bulunan TÜM kitapları liste halinde getirir.
    - "KitapModel" nesnesine dönüştürerek geri döndürür.
    - Eğer veri yoksa boş liste döndürür.
  */
    Database? db = await _getDatabase();
    List<KitapModel> kitaplar = [];
    if(db != null){
      String filtre = "$_kitap_id > ?";
      List<dynamic> filtreArgs = [sonKitapID];

      if(kategori_id >= 0){
        filtre += " and $_kitap_kategori = ?";
        filtreArgs.add(kategori_id);
      }

      List<Map<String, dynamic>> tumKitaplar = await db.query(
        _kitap_tablo_adi,
        where: filtre,
        whereArgs: filtreArgs,
        orderBy: "$_kitap_id ASC",
        limit: 15
      );

      for(Map<String, dynamic> map in tumKitaplar){
        KitapModel kitap = KitapModel.fromMap(map);
        kitaplar.add(kitap);
      }
    }
    return kitaplar; // Kitap listesi döndürülür
  }

  Future<List<KitapModel>> getirKitap(KitapModel kitapParam) async {
    /*
    - Belirli bir kitap ID'sine sahip kitabı getirir.
    - Eğer kayıt bulunursa "KitapModel" nesnesi olarak döndürülür.
    - Eğer kayıt yoksa boş bir liste döndürülür.
  */
    Database? db = await _getDatabase(); // Veritabanı bağlantısını alalım

    if(db != null){
      List<Map<String, dynamic>> mapList = await db.query(
          _kitap_tablo_adi,
          where: "$_kitap_id = ?",
          whereArgs: [kitapParam.kitap_id] // Sadece belirli ID'deki kitabı getirelim
      );
      if (mapList.isNotEmpty) {
        return [KitapModel.fromMap(mapList[0])]; // İlk bulunan kaydı döndürelim
      } else {
        return [];  // Eğer kayıt yoksa boş liste döndürelim
      }
    }
    return []; // Bağlantı başarısızsa boş liste döndürelim
  }

  Future<int> guncelleKitap(KitapModel kitap) async {
    /*
    - Mevcut bir kitabın bilgilerini günceller.
    - "kitap_id" değerine göre doğru kaydı bulur ve günceller.
    - Eğer güncelleme başarılı olursa GÜNCELLENEN SATIR SAYISINI döndürür.
    - Eğer veritabanına bağlanamazsa veya kayıt bulunamazsa 0 döndürülür.
  */
    Database? db = await _getDatabase();

    if(db != null){
      return await db.update(
        _kitap_tablo_adi,
        kitap.toMap(),
        where: "$_kitap_id = ?", // Güncellenecek kitabı ID ile bulalım
        whereArgs: [kitap.kitap_id],
      );
    }else{
      return 0; // Hiçbir kayıt güncellenmezse 0 döndürelim.
    }
  }

  Future<int> silKitap(KitapModel kitap) async {
    /*
    - Verilen kitap ID'sine sahip kaydı veritabanından siler.
    - Eğer başarılı olursa SİLİNEN SATIR SAYISINI döndürür.
    - Eğer veritabanına bağlanamazsa veya kayıt bulunamazsa 0 döndürülür.
  */
    Database? db = await _getDatabase();

    if(db != null){
      return await db.delete(
        _kitap_tablo_adi,
        where: "$_kitap_id = ?",
        whereArgs: [kitap.kitap_id], // Silinecek kitabın ID'sini verelim
      );
    }
    return 0; // Eğer silme başarısızsa 0 döndürelim
  }

  Future<int> silSecilenKitaplar(List<int> kitapIDList) async {
    /*
    - Verilen kitap ID listesindeki kayıtları veritabanından siler.
    - Eğer başarılı olursa SİLİNEN SATIR SAYISINI döndürür.
    - Eğer veritabanına bağlanamazsa veya kayıt bulunamazsa 0 döndürülür.
  */
    Database? db = await _getDatabase();

    if(db != null && kitapIDList.isNotEmpty){
      // Burada filtremizi oluşturalım
      String filtre = "$_kitap_id IN (";

      // Silinecek her bir eleman için query içine ? ekleyelim.
      for(int i=0; i < kitapIDList.length; i++){
        if(i != kitapIDList.length-1){
          filtre += "?,";
        }else{
          filtre += "?)";   // Eğer son elemansa query'deki parantezi kapatalım.
        }
      }

      return await db.delete(
        _kitap_tablo_adi,
        where: filtre,
        whereArgs: kitapIDList, // Silinecek kitabın ID'sini verelim
      );
    }
    return 0; // Eğer silme başarısızsa 0 döndürelim
  }

  // ********************** Bölüm Model **********************
  // *********** CRUD (Create, Read, Update, Delete) Operasyonları ***********

  Future<int> ekleBolum(BolumModel bolum) async {
    /*
    - Yeni bir kitap eklemek için kullanılır.
    - "KitapModel" sınıfından bir kitap nesnesi alır ve veritabanına ekler.
    - Eğer işlem başarılı olursa eklenen kaydın ID'sini döndürür.
    - Eğer veritabanı bağlantısı başarısız olursa `-1` döndürerek hata olduğunu belirtir.
  */
    Database? db = await _getDatabase();

    // Eğer bağlantı başarılıysa kitabı ekleyelim ve
    // eklenen verinin ID değerini döndürelim
    return await db.insert(_bolum_tablo_adi, bolum.toMap());
  }

  Future<List<BolumModel>> getirKitabinTumBolumleri(KitapModel kitap) async {
    /*
    - Veritabanında bulunan belirli kitaba ait bölümleri liste halinde getirir.
    - "KitapModel" nesnesine dönüştürerek geri döndürür.
    - Eğer veri yoksa boş liste döndürür.
  */
    Database? db = await _getDatabase();
    List<BolumModel> bolumler = [];
    // Tüm kitapları al
    List<Map<String, dynamic>> tumBolumler = await db.query(
      _bolum_tablo_adi,
      where: "$_bolum_kitap_id = ?",
      whereArgs: [kitap.kitap_id]
    );

    for(Map<String, dynamic> map in tumBolumler){
      BolumModel bolum = BolumModel.fromMap(map); // Haritayı modele çevir
      bolumler.add(bolum); // Listeye ekle
    }
    return bolumler; // Kitap listesi döndürülür
  }

  Future<List<BolumModel>> getirBolum(BolumModel bolum) async {
    /*
    - Belirli bir bolum ID'sine sahip bolum getirir.
    - Eğer kayıt bulunursa "BolumModel" nesnesi olarak döndürülür.
    - Eğer kayıt yoksa boş bir liste döndürülür.
  */
    Database? db = await _getDatabase(); // Veritabanı bağlantısını alalım

    List<Map<String, dynamic>> mapList = await db.query(
        _bolum_tablo_adi,
        where: "$_bolum_id = ?",
        whereArgs: [bolum.bolum_id] // Sadece belirli ID'deki kitabı getirelim
    );

    if (mapList.isNotEmpty) {
      return [BolumModel.fromMap(mapList[0])]; // İlk bulunan kaydı döndürelim
    } else {
      return [];  // Eğer kayıt yoksa boş liste döndürelim
    }
  }

  Future<int> guncelleBolum(BolumModel bolum) async {
    /*
    - Mevcut bir bolumun bilgilerini günceller.
    - "bolum_id" değerine göre doğru kaydı bulur ve günceller.
    - Eğer güncelleme başarılı olursa GÜNCELLENEN SATIR SAYISINI döndürür.
    - Eğer veritabanına bağlanamazsa veya kayıt bulunamazsa 0 döndürülür.
  */
    Database? db = await _getDatabase();

    return await db.update(
      _bolum_tablo_adi,
      bolum.toMap(),
      where: "$_bolum_id = ?", // Güncellenecek kitabı ID ile bulalım
      whereArgs: [bolum.bolum_id],
    );
  }

  Future<int> silBolum(BolumModel bolum) async {
    /*
    - Verilen bolum ID'sine sahip kaydı veritabanından siler.
    - Eğer başarılı olursa SİLİNEN SATIR SAYISINI döndürür.
    - Eğer veritabanına bağlanamazsa veya kayıt bulunamazsa 0 döndürülür.
  */
    Database? db = await _getDatabase();

    return await db.delete(
      _bolum_tablo_adi,
      where: "$_bolum_id = ?",
      whereArgs: [bolum.bolum_id], // Silinecek kitabın ID'sini verelim
    );
  }

}
