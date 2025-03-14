import 'package:flutter/material.dart';
import 'package:flutter_yazar_sqlite/model/bolum_model.dart';
import 'package:flutter_yazar_sqlite/view_model/detay_bolum_view_model.dart';
import 'package:provider/provider.dart';

class Detaybolum extends StatelessWidget {

  TextEditingController _controllerLocal = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: _buildBody(context),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context){
    DetayBolumViewModel viewModel = Provider.of<DetayBolumViewModel>(
      context,
      listen: false,
    );

    return AppBar(
      title: Text(viewModel.bolum.bolum_ad),
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed: () async {
          if(viewModel.degisiklikVar){
            viewModel.buildAlertDialog(context);
          }else{
            Navigator.pop(context);
          }
        },
        icon: Icon(Icons.arrow_back),
      ),
      actions: [
        IconButton(
          onPressed: (){
              viewModel.icerigiKaydet(viewModel.controllerIcerik.text);
              },
          icon: Icon(
            Icons.save,
            size: 35,
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context){
    DetayBolumViewModel viewModel = Provider.of<DetayBolumViewModel>(
      context,
      listen: false,
    );
    _controllerLocal.text = viewModel.bolum.bolum_icerik;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: viewModel.controllerIcerik,
        maxLines: 1000,
        decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)
            )
        ),
        onChanged: (String? yeniGiris) async {
          if(yeniGiris != null){
            viewModel.controllerIcerik.text = yeniGiris;
            if(yeniGiris != viewModel.bolum.bolum_icerik){
              viewModel.degisiklikVar = true;
            }
          }
        },
      ),
    );
  }


}
