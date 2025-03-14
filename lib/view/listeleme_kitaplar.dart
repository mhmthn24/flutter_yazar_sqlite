import 'package:flutter/material.dart';
import 'package:flutter_yazar_sqlite/model/kitap_model.dart';
import 'package:flutter_yazar_sqlite/tools/sabitler.dart';
import 'package:flutter_yazar_sqlite/view/listeleme_bolumler.dart';
import 'package:flutter_yazar_sqlite/view_model/listeleme_kitaplar_view_model.dart';
import 'package:provider/provider.dart';

/*
  Bu sınıf, SQLite ile saklanan kitapları listelemek ve
  yönetmek için oluşturulmuştur.

  - Tüm kitapları listeleme
  - Yeni kitap ekleme
  - Kitap silme
  - Kitap güncelleme
    işlemlerini yapar.
*/

class Listelemetumkitaplar extends StatelessWidget {

  /*
    SQLite veritabanı işlemleri için YerelVeriTabani
    sınıfının bir nesnesi oluşturuldu.
   */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _build_appBar(context), // Üst menüyü oluştur
      floatingActionButton: _build_fab(context), // Yeni kitap ekleme butonu
      body: _build_body(), // Kitap listesini gösteren ana bileşen
    );
  }

  // *************** EKRAN TASARIMI FONKSİYONLARI ***************

  // Uygulamanın üst kısmında bulunan başlık (AppBar)
  AppBar _build_appBar(BuildContext context){
    return AppBar(
      title: Text("Kitaplar"), // Sayfa başlığı
      actions: [
        IconButton(
          onPressed: (){
             _build_secimleri_sil_alert_dialog(context); // Secilen kitaplari sil
          },
          icon: Icon(
            Icons.delete,
            size: 40,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  // Yeni kitap eklemek için "+" butonu
  Widget _build_fab(BuildContext context){
    return Consumer<ListelemeKitaplarViewModel>(builder: (context, viewModel, child){
      return FloatingActionButton(
        onPressed: (){
          viewModel.controllerKitapAdi.clear();
          viewModel.ekleKitap(context); // Yeni kitap ekleme fonksiyonunu çağır
        },
        child: Icon(Icons.add), // Buton ikonu
      );
    });
  }

  // FutureBuilder, veriler geldiğinde listeyi oluşturur
  Widget _build_body(){

    return Consumer<ListelemeKitaplarViewModel>(builder: (context, viewModel, child){
      return Column(
        children: [
          _build_kategoriler(),
          Expanded(
            child: ListView.builder(
              controller: viewModel.controllerScroll,
              itemCount: viewModel.tumKitaplar.length, // Toplam kitap sayısı
              itemBuilder: (context, index){
                return ChangeNotifierProvider.value(
                  value: viewModel.tumKitaplar[index],
                  child: _build_ListView(context, index),
                );
                // Her bir kitabı listede göster
              }
            ),
          ),
        ],
      );
    });
  }

  // **ListView içinde tek bir kitap kartını oluşturur**
  Widget _build_ListView(BuildContext context, int index) {
    ListelemeKitaplarViewModel viewModel = Provider.of<ListelemeKitaplarViewModel>(
      context,
      listen: false,
    );
    return Consumer<KitapModel>(builder: (context, kitap, child){
      return Card(
        color: Colors.cyanAccent, // Kartın arka plan rengini belirleyelim
        child: ListTile(
          title: Text(
            kitap.kitap_ad, // Kitap adını başlık olarak verelim
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          subtitle: Text(
            Sabitler.kategoriler[kitap.kitap_kategori] ?? "",
          ),
          leading: Checkbox(
            value: kitap.seciliMi,
            onChanged: (bool? yeniDurum){
              if(yeniDurum != null){
                int? cb_id = kitap.kitap_id;
                if (cb_id != null){
                  if (yeniDurum){
                    viewModel.secilenKitapID.add(cb_id);
                    if(viewModel.tumKitaplar.isNotEmpty &&
                        viewModel.secilenKitapID.length == viewModel.tumKitaplar.length)
                    {
                      viewModel.tumKitaplariSec = true;
                    }
                  }else{
                    viewModel.secilenKitapID.remove(cb_id);
                    viewModel.tumKitaplariSec = false;
                  }
                  kitap.seciliMi = yeniDurum;
                }
              }
            },
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: (){
                  viewModel.guncelleKitap(context, index); // Kitabı guncelle
                },
                icon: Icon(
                  Icons.edit,
                  size: 40,
                  color: Colors.black,
                ),
              ),
              IconButton(
                onPressed: (){
                  viewModel.gitBolumler(context, kitap);
                },
                icon: Icon(Icons.arrow_forward_ios),
              ),
            ],
          ),
          onTap: (){
            viewModel.gitBolumler(context, kitap);
          },
        ),
      );
    });
  }

  Widget _build_kategoriler(){
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hepsi", textAlign: TextAlign.center,),
              Consumer<ListelemeKitaplarViewModel>(builder: (context, viewModel, child){
                return Checkbox(
                  value: viewModel.tumKitaplariSec,
                  onChanged: (bool? yeniDurum){
                    if(yeniDurum != null){
                      if (yeniDurum){
                        viewModel.secilenKitapID.clear();
                        viewModel.tumKitaplariSec = true;
                        if(viewModel.tumKitaplar.isNotEmpty){
                          for(int i=0; i < viewModel.tumKitaplar.length; i++){
                            viewModel.secilenKitapID.add(viewModel.tumKitaplar[i].kitap_id ?? -1);
                            viewModel.tumKitaplar[i].seciliMi = true;
                          }
                        }
                      }else{
                        viewModel.secilenKitapID.clear();
                        viewModel.tumKitaplariSec = false;
                        for(int i = 0; i < viewModel.tumKitaplar.length; i++){
                          viewModel.tumKitaplar[i].seciliMi = false;
                        }
                      }
                    }
                  },
                );
              }),
            ],
          ),
          Text(
            "Kategori: ",
            style: TextStyle(
                fontSize: 16
            ),
          ),
          Consumer<ListelemeKitaplarViewModel>(builder: (context, viewModel, child){
            return DropdownButton<int>(
              value: viewModel.secilenKategori,
              items: viewModel.tumKategoriler.map((kategoriID){
                return DropdownMenuItem<int>(
                  value: kategoriID,
                  child: Text(
                    kategoriID == -1
                        ? "Hepsi"
                        : Sabitler.kategoriler[kategoriID] ?? "",
                  ),
                );
              }).toList(),
              onChanged: (int? yeniID){
                if (yeniID != null){
                  viewModel.tumKitaplar.clear();
                  viewModel.secilenKategori = yeniID;
                  viewModel.getirIlkKitaplar();
                }
              },
            );
          }),
        ],
      ),
    );
  }

  Future<bool?> _build_secimleri_sil_alert_dialog(
      BuildContext context
      ){
    ListelemeKitaplarViewModel viewModel = Provider.of<ListelemeKitaplarViewModel>(
      context,
      listen: false,
    );
    return showDialog<bool>(context: context, builder: (BuildContext context){
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Seçilen kitapları silmek istediğinize emin misiniz?"),
          ],
        ),
        actions: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                child: Text("Hayır"),
              ),
              TextButton(
                onPressed: (){
                  Navigator.pop(context);
                  viewModel.secilenKitaplariSil();
                },
                child: Text("Evet"),
              ),
            ],
          )
        ],
      );
    });
  }

}
