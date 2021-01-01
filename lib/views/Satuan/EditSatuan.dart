import 'package:flutter/material.dart';

import 'package:globalshop/models/api.dart';
import 'dart:convert';
import 'package:globalshop/models/SatuanModel.dart';
import 'package:http/http.dart' as http;

class EditSatuan extends StatefulWidget {
  final VoidCallback reload;
  final SatuanModel model;
  EditSatuan(this.model, this.reload);
  @override
  _EditSatuanState createState() => _EditSatuanState();
}

class _EditSatuanState extends State<EditSatuan> {
  String namaSatuan, satuan, idSatuan;

  final _key = new GlobalKey<FormState>();

  TextEditingController txtIdSatuan, txtNamaSatuan, txtSatuan;
  setup() async {
    txtIdSatuan = TextEditingController(text: widget.model.id);
    txtNamaSatuan = TextEditingController(text: widget.model.namaSatuan);
    txtSatuan = TextEditingController(text: widget.model.satuan);
  }

  check() {
    final form = _key.currentState;
    if (form.validate()) {
      form.save();
      simpanBarang();
    }
  }

  simpanBarang() async {
    try {
    // print(idSatuan);
    // print(namaSatuan);
    // print(satuan);
      final response = await http.post(BaseURL.apiEditSatuan,
          body: {"id": (idSatuan == null ? widget.model.id : idSatuan), "nama_satuan": namaSatuan, "satuan": satuan});
      final data = jsonDecode(response.body);
      int code = data['code'];
      String pesan = data['message'];
      if (code == 200) {
        setState(() {
          Navigator.pop(context);
          widget.reload();
        });
      } else {
        print(pesan);
        _dialogMessageNotif(pesan, code);
      }
    } catch (e) {
      print("prinerror");
      print(e);
    }
  }

  // dialog message
  _dialogMessageNotif(String msg, int code) {
    String msgText = msg + "\ncode : " +code.toString();
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: ListView(
              padding: EdgeInsets.all(16.0),
              shrinkWrap: true,
              children: <Widget>[
                Text(
                  msgText,
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 18.0),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text("OK",textAlign: TextAlign.right,),
                )
              ],
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    setup();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(244, 244, 244, 1),
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                child: Text(
                  "Edit Satuan",
                  style: TextStyle(color: Colors.white, fontSize: 20.0),
                ),
              )
            ],
          ),
        ),
        body: Form(
          key: _key,
          child: ListView(
            padding: EdgeInsets.all(16.0),
            children: <Widget>[
              TextFormField(
                controller: txtNamaSatuan,
                validator: (e) {
                  if (e.isEmpty) {
                    return "Silahkan isi Nama Satuan";
                  } else {
                    return null;
                  }
                },
                onSaved: (e) => namaSatuan = e,
                decoration: InputDecoration(labelText: "Nama Satuan"),
              ),
              TextFormField(
                controller: txtSatuan,
                validator: (e) {
                  if (e.isEmpty) {
                    return "Silahkan isi Satuan";
                  } else {
                    return null;
                  }
                },
                onSaved: (e) => satuan = e,
                decoration: InputDecoration(labelText: "Satuan"),
              ),
              MaterialButton(
                onPressed: () {
                  check();
                },
                child: Text("Simpan"),
              )
            ],
          ),
        ));
  }
}
