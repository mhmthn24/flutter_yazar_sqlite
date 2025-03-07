import 'package:flutter/material.dart';
import 'package:flutter_yazar_sqlite/YerelVeriTabani.dart';
import 'package:flutter_yazar_sqlite/model/bolum_model.dart';

class Detaybolum extends StatefulWidget {
  BolumModel _bolum;

  Detaybolum(this._bolum, {super.key});

  @override
  State<Detaybolum> createState() => _DetaybolumState();
}

class _DetaybolumState extends State<Detaybolum> {
  YerelVeriTabani _yerelVeriTabani = YerelVeriTabani();

  TextEditingController _controllerIcerik = TextEditingController();

  bool degisiklikVar = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controllerIcerik.text = widget._bolum.bolum_icerik;
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  AppBar _buildAppBar(){
    return AppBar(
      title: Text(widget._bolum.bolum_ad),
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed: () async {
          if(degisiklikVar){
            _buildAlertDialog(context);
          }else{
            Navigator.pop(context);
          }
        },
        icon: Icon(Icons.arrow_back),
      ),
      actions: [
        IconButton(
          onPressed: degisiklikVar
            ?(){
              _icerigiKaydet();
            }
            : null,
          icon: Icon(
            Icons.save,
            size: 35,
          ),
        ),
      ],
    );
  }

  Widget _buildBody(){
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _controllerIcerik,
        maxLines: 1000,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12)
          )
        ),
        onChanged: (String? yeniGiris) async {
          if(yeniGiris != null){
            setState(() {
              _controllerIcerik.text = yeniGiris;
              if(yeniGiris != widget._bolum.bolum_icerik){
                degisiklikVar = true;
              }
            });
          }
        },
      ),
    );
  }

  void _icerigiKaydet() async {
    widget._bolum.bolum_icerik = _controllerIcerik.text;
    widget._bolum.bolum_udate = DateTime.now();
    await _yerelVeriTabani.guncelleBolum(widget._bolum);
    setState(() {
      degisiklikVar = false;
    });
  }

  Future<bool?> _buildAlertDialog(BuildContext context){
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
                    _icerigiKaydet();
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
