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

  // Tablo ve sütun isimlerini sabit değişkenler olarak tanımlıyoruz.
  String _kitap_tablo_adi = "kitap";  // Tablo adı
  String _kitap_id = "kitap_id";      // Kitapların benzersiz ID'si
  String _kitap_ad = "kitap_ad";      // Kitap adı
  String _kitap_cdate = "kitap_cdate"; // Kitabın oluşturulma tarihi (milisaniye cinsinden)
  String _kitap_udate = "kitap_udate"; // Kitabın güncellenme tarihi (milisaniye cinsinden)


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
        version: 1,
        // Eğer veri tabanı yoksa bu fonksiyon çağrılacak
        onCreate: _createTable
    );

    return _database!;
  }

  Future<void> _createTable(Database db, int version) async {
    /*
    Tabloyu oluşturma fonksiyonu

    - Eğer veri tabanı daha önce oluşturulmadıysa, bu fonksiyon çağrılarak
      'kitaplar' tablosu oluşturulur.

    - `_kitap_cdate` ve `_kitap_udate` sütunları INTEGER olarak tanımlandı.
      Çünkü tarih bilgileri 'millisecondsSinceEpoch' formatında kaydedilecek.
  */

    await db.execute(
        """
      CREATE TABLE $_kitap_tablo_adi (
        $_kitap_id INTEGER NOT NULL UNIQUE PRIMARY KEY AUTOINCREMENT,  -- Benzersiz kitap ID'si
        $_kitap_ad TEXT NOT NULL,  -- Kitap adı zorunlu
        $_kitap_cdate INTEGER,  -- Kitabın oluşturulma tarihi (millisecondsSinceEpoch formatında)
        $_kitap_udate INTEGER   -- Kitabın güncellenme tarihi (millisecondsSinceEpoch formatında)
      );
      """
    );
  }
}
