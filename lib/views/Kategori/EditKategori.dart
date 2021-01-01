import 'package:flutter/material.dart';

import 'package:globalshop/models/api.dart';
import 'dart:convert';
import 'package:globalshop/models/KategoriModel.dart';
import 'package:http/http.dart' as http;

class EditKategori extends StatefulWidget {
  final VoidCallback reload;
  final KategoriModel model;
  EditKategori(this.model, this.reload);
  @override
  _EditKategoriState createState() => _EditKategoriState();
}

class _EditKategoriState extends State<EditKategori> {
  String namaKategori, idKategori;

  final _key = new GlobalKey<FormState>();

  TextEditingController txtIdKategori, txtNamaKategori, txtKategori;
  setup() async {
    txtIdKategori = TextEditingController(text: widget.model.id);
    txtNamaKategori = TextEditingController(text: widget.model.namaKategori);
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
    // print(idKategori);
    // print(namaKategori);
    // print(Kategori);
      final response = await http.post(BaseURL.apiEditKategori,
          body: {"id": (idKategori == null ? widget.model.id : idKategori), "nama_kategori": namaKategori});
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
      // debugPrint(e);
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
                "Edit Kategori",
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
                controller: txtNamaKategori,
                validator: (e) {
                  if (e.isEmpty) {
                    return "Silahkan isi Nama Kategori";
                  } else {
                    return null;
                  }
                },
                onSaved: (e) => namaKategori = e,
                decoration: InputDecoration(labelText: "Nama Kategori"),
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
