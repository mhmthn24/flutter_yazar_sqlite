import 'package:flutter/material.dart';
import 'package:flutter_yazar_sqlite/model/bolum_model.dart';
import 'package:flutter_yazar_sqlite/model/kitap_model.dart';
import 'package:flutter_yazar_sqlite/view/detay_bolum.dart';
import 'package:flutter_yazar_sqlite/view_model/listeleme_bolumler_view_model.dart';
import 'package:flutter_yazar_sqlite/view_model/listeleme_kitaplar_view_model.dart';
import 'package:provider/provider.dart';

class Listelemekitapbolumler extends StatefulWidget {


  @override
  State<Listelemekitapbolumler> createState() => _ListelemekitapbolumlerState();
}

class _ListelemekitapbolumlerState extends State<Listelemekitapbolumler> {
  /*
    SQLite veritabanı işlemleri için YerelVeriTabani
    sınıfının bir nesnesi oluşturuldu.
   */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _build_appBar(), // Üst menüyü oluştur
      floatingActionButton: _build_fab(context), // Yeni bolum ekleme butonu
      body: _build_body(context), // Bolum listesini gösteren ana bileşen
    );
  }

  // *************** EKRAN TASARIMI FONKSİYONLARI ***************

  // Uygulamanın üst kısmında bulunan başlık (AppBar)
  AppBar _build_appBar(){
    ListelemeBolumlerViewModel viewModel = Provider.of<ListelemeBolumlerViewModel>(
      context,
      listen: false,
    );
    return AppBar(
      title: Text("${viewModel.kitap.kitap_ad} Bölümleri"), // Sayfa başlığı
    );
  }

  // Yeni bolum eklemek için "+" butonu
  Widget _build_fab(BuildContext context){
    return Consumer<ListelemeBolumlerViewModel>(builder: (context, viewModel, child){
      return FloatingActionButton(
        onPressed: (){
          viewModel.controllerBolumAdi.clear();
          viewModel.ekleBolum(context); // Yeni bolum ekleme fonksiyonunu çağır
        },
        child: Icon(Icons.add), // Buton ikonu
      );
    });
  }

  // FutureBuilder, veriler geldiğinde listeyi oluşturur
  Widget _build_body(BuildContext context){
    return Consumer<ListelemeBolumlerViewModel>(
      builder: (context, viewModel, child){
        return ListView.builder(
          itemCount: viewModel.tumBolumler.length, // Toplam bolum sayısı
          itemBuilder: (context, index){
            return ChangeNotifierProvider.value(
              value: viewModel.tumBolumler[index],
              child: _build_ListView(context, index),
            );
          }, // Her bir kitabı listede göster
        );
      },
    );
  }

  // **ListView içinde tek bir bolum kartını oluşturur**
  Widget _build_ListView(BuildContext context, int index){
    ListelemeBolumlerViewModel viewModel = Provider.of<ListelemeBolumlerViewModel>(
      context,
      listen: false
    );

    return Consumer<BolumModel>(builder: (context, bolum, child){
      return Card(
        color: Colors.cyanAccent, // Kartın arka plan rengini belirleyelim
        child: ListTile(
          title: Text(
            bolum.bolum_ad, // Bolum adını başlık olarak verelim
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          leading: CircleAvatar(
            backgroundColor: Colors.orange,
            child: Text(
              bolum.bolum_id.toString(), // Bolum ID
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),

          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: (){
                  viewModel.silBolum(context, bolum); // Kitabı sil
                },
                icon: Icon(
                  Icons.delete,
                  size: 40,
                  color: Colors.black,
                ),
              ),
              IconButton(
                onPressed: (){
                  viewModel.guncelleBolum(context, index); // Kitabı guncelle
                },
                icon: Icon(
                  Icons.edit,
                  size: 40,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          onTap: (){
            viewModel.gitBolumDetay(context, bolum);
          },
        ),
      );
    });
  }

  // *************** CRUD İŞLEMLERİ ***************





}
