import 'package:flutter/material.dart';
import 'package:globalshop/models/api.dart';
// import 'package:globalshop/views/Satuan/MenuSatuan.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TambahSatuan extends StatefulWidget {
  final VoidCallback reload;
  TambahSatuan(this.reload);
  @override
  _TambahSatuanState createState() => _TambahSatuanState();
}

class _TambahSatuanState extends State<TambahSatuan> {
  String namaSatuan, satuan;

  final _key = new GlobalKey<FormState>();

  check() {
    final form = _key.currentState;
    if (form.validate()) {
      form.save();
      simpanBarang();
    }
  }

  simpanBarang() async {
    // print(namaSatuan);
    // print(satuan);
    try {
      // print(idSatuan);
      final response = await http.post(BaseURL.apiPostSatuan,
          body: {"nama_satuan": namaSatuan, "satuan": satuan});
      final data = jsonDecode(response.body);
      int code = data['code'];
      String pesan = data['message'];

      if (code == 201 || code == 200) {
        print("reload");
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
    // getPref();
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
                  "Tambah Satuan",
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
                validator: (e) {
                  if (e.isEmpty) {
                    return "Silahkan isi Nama Satuan";
                  } else {}
                },
                onSaved: (e) => namaSatuan = e,
                decoration: InputDecoration(labelText: "Nama Satuan"),
              ),
              TextFormField(
                validator: (e) {
                  if (e.isEmpty) {
                    return "Silahkan isi Satuan";
                  } else {}
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
