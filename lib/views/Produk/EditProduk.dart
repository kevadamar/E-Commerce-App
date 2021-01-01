import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:globalshop/models/ProdukModel.dart';
import 'package:globalshop/models/api.dart';
import 'dart:convert';
import 'dart:io';

import 'package:globalshop/utils/currency.dart';
import 'package:globalshop/utils/datePicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:globalshop/models/KategoriModel.dart';
import 'package:globalshop/models/SatuanModel.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:async/async.dart';
import 'package:path/path.dart' as path;

class EditProduk extends StatefulWidget {
  final VoidCallback reload;
  final ProdukModel model;
  EditProduk(this.model, this.reload);
  @override
  _EditProdukState createState() => _EditProdukState();
}

class _EditProdukState extends State<EditProduk> {
  String namaBarang, harga, userid, idKategori, tglexpired, idSatuan;

  final _key = new GlobalKey<FormState>();

  File _imageFile;

  TextEditingController txtIdBarang, txtNamaBarang, txtHarga;
  setup() async {
    tglexpired = widget.model.tglexpired;
    txtIdBarang = TextEditingController(text: widget.model.id);
    txtNamaBarang = TextEditingController(text: widget.model.namaBarang);
    txtHarga = TextEditingController(text: widget.model.harga);
    idKategori = widget.model.idKategori;
    idSatuan = widget.model.idSatuan;
  }

  KategoriModel _currentKategori;
  SatuanModel _currentSatuan;

  List currentListKategori;
  List currentListSatuan;

  final listKategori = new List<KategoriModel>();
  final listSatuan = new List<SatuanModel>();

  final String linkKategori = BaseURL.apiListKategori;
  final String linkSatuan = BaseURL.apiListSatuan;

  Future<List<KategoriModel>> _fetchKategoriList() async {
    var responseData = await http.get(linkKategori);
    Map<String, dynamic> data = jsonDecode(responseData.body);
    print("dari data json");
    // print(responseData);

    if (responseData.statusCode == 200 && data['code'] == 200) {
      final items = data['data'];

      List<KategoriModel> listOfKategori = items.map<KategoriModel>((json) {
        return KategoriModel.fromJson(json);
      }).toList();
      currentListKategori = items;
      // print(currentListKategori);
      return listOfKategori;
    } else {
      print("errur");
      throw Exception('Internet Tidak Stabil...');
    }
  }

  Future<List<SatuanModel>> _fetchSatuanList() async {
    var responseData = await http.get(linkSatuan);
    Map<String, dynamic> data = jsonDecode(responseData.body);

    if (responseData.statusCode == 200 && data['code'] == 200) {
      final items = data['data'];

      List<SatuanModel> listOfSatuan = items.map<SatuanModel>((json) {
        // return json;
        return SatuanModel.fromJson(json);
      }).toList();
      currentListSatuan = items;
      // print(currentListKategori);
      return listOfSatuan;
    } else {
      throw Exception('Internet Tidak Stabil...');
    }
  }

  _pilihGalerry() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 1920.0, maxWidth: 1080);
    setState(() {
      _imageFile = image;
      Navigator.pop(context);
    });
  }

  _pilihCamera() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 1920.0, maxWidth: 1080);
    setState(() {
      _imageFile = image;
      Navigator.pop(context);
    });
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
      var uri = Uri.parse(BaseURL.apiEditBarang);
      var request = http.MultipartRequest("POST", uri);

      print("post proses");

      request.fields['id_barang'] = widget.model.id;
      request.fields['nama_barang'] = namaBarang;
      request.fields['harga'] = harga.replaceAll(",", "");
      request.fields['id_kategori'] =
          idKategori == null ? widget.model.idKategori : idKategori;
      request.fields['tglexpired'] = "$tglexpired";
      request.fields['userid'] = "1";
      request.fields['id_satuan'] =
          idSatuan == null ? widget.model.idSatuan : idSatuan;
      if (_imageFile != null) {
        var stream =
            http.ByteStream(DelegatingStream.typed(_imageFile.openRead()));
        var length = await _imageFile.length();
        request.files.add(http.MultipartFile("image", stream, length,
            filename: path.basename(_imageFile.path)));
      }

      var responseServe = await request.send();
      Map<String, dynamic> respStr =
          jsonDecode(await responseServe.stream.bytesToString());

      // print("status code");
      // print(responseServe.statusCode);
      if (responseServe.statusCode == 200) {
        print("reload");
        setState(() {
          Navigator.pop(context);
          widget.reload();
        });
        // _dialogMessageNotif(respStr['message'], respStr['code']);
      } else if (responseServe.statusCode == 400) {
        _dialogMessageNotif(respStr['message'], respStr['code']);
        print("failed upload: Bad Request");
      } else if (responseServe.statusCode == 500) {
        _dialogMessageNotif(respStr['message'], respStr['code']);
        print("failed upload: ErrorServer");

        print(respStr['message']);
      } else {
        _dialogMessageNotif("Internal Server Error", 500);
        print("error 2");
      }
    } catch (e) {
      print("prinerror");
      print(e);
      debugPrint(e);
    }
  }

  prosesBiasa() async {
    final response = await http.post(BaseURL.apiEditBarang, body: {
      "nama_barang": namaBarang,
      "harga": harga.replaceAll(",", ""),
      "id_kategori": idKategori == null ? widget.model.idKategori : idKategori,
      "tglexpired": "$tglexpired",
      "userid": "1",
      "id_satuan": idSatuan == null ? widget.model.idSatuan : idSatuan,
      "id_barang": widget.model.id
    });
    final data = jsonDecode(response.body);
    int value = data['code'];
    String pesan = data['message'];

    if (value == 200) {
      setState(() {
        print(pesan);
        widget.reload();
        Navigator.pop(context);
      });
    } else {
      print(pesan);
    }
  }

  String pilihTanggal, labelText;
  DateTime tgl = new DateTime.now();
  var formatTgl = new DateFormat("yyyy-MM-dd");
  final TextStyle valueStyle = TextStyle(fontSize: 16.0);
  Future<Null> _selectedDate(BuildContext context) async {
    tgl = DateTime.parse(widget.model.tglexpired);
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: tgl,
        firstDate: DateTime(1992),
        lastDate: DateTime(2099));
    if (picked != null && picked != tgl) {
      setState(() {
        tgl = picked;
        tglexpired = formatTgl.format(tgl);
      });
    } else {}
  }

  dialogFileFoto() {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: ListView(
              padding: EdgeInsets.all(16.0),
              shrinkWrap: true,
              children: <Widget>[
                Text(
                  "Silahkan pilih file",
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 18.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        _pilihGalerry();
                      },
                      child: Text(
                        "Gallery",
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      width: 25.0,
                    ),
                    InkWell(
                      onTap: () {
                        _pilihCamera();
                      },
                      child: Text(
                        "Camera",
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                )
              ],
            ),
          );
        });
  }

  // dialog message
  _dialogMessageNotif(String msg, int code) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Dialog(
            child: ListView(
              padding: EdgeInsets.all(16.0),
              shrinkWrap: true,
              children: <Widget>[
                Text(
                  msg,
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 18.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                          Navigator.pop(context);
                      },
                      child: Text(
                        "OK",
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                )
              ],
            ),
          );
        });
  }

  // filter kategori name by current id
  loopKategori(List listKategori, String id) {
    print('nama_kategoris');
    for (var item in listKategori) {
      if (item['id'] == id) {
        return item['nama_kategori'];
      }
    }
  }

  // filter Satuan name by current id
  loopSatuan(List listSatuan, String id) {
    for (var item in listSatuan) {
      if (item['id'] == id) {
        print(item['nama_satuan']);
        return item['nama_satuan'];
      }
    }
  }

  @override
  void initState() {
    super.initState();
    setup();
  }

  @override
  Widget build(BuildContext context) {
    var placeholder = Container(
      width: double.infinity,
      height: 150.0,
      child: Image.asset('./assets/img/placeholder.png'),
    );
    return Scaffold(
        backgroundColor: Color.fromRGBO(244, 244, 244, 1),
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                child: Text(
                  "Edit Produk",
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
              Text("Foto Produk"),
              Container(
                  width: double.infinity,
                  height: 150.0,
                  child: InkWell(
                      onTap: () {
                        dialogFileFoto();
                      },
                      child: _imageFile == null
                          ? Image.network(
                              BaseURL.paths + "/" + widget.model.image)
                          : Image.file(_imageFile, fit: BoxFit.fill))),
              Text("Kategori Produk"),
              FutureBuilder<List<KategoriModel>>(
                  future: _fetchKategoriList(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<KategoriModel>> snapshot) {
                    // print(snapshot.data);
                    if (!snapshot.hasData) return CircularProgressIndicator();
                    return DropdownButton<KategoriModel>(
                      items: snapshot.data
                          .map(
                              (listkategori) => DropdownMenuItem<KategoriModel>(
                                    child: Text(listkategori.namaKategori),
                                    value: listkategori,
                                  ))
                          .toList(),
                      onChanged: (KategoriModel value) {
                        setState(() {
                          _currentKategori = value;
                          idKategori = _currentKategori.id;
                        });
                      },
                      isExpanded: false,
                      hint: Text(idKategori == null ||
                              idKategori == widget.model.idKategori
                          ? (loopKategori(
                              currentListKategori, widget.model.idKategori))
                          : _currentKategori.namaKategori),
                    );
                  }),
              Text("Satuan Produk"),
              FutureBuilder<List<SatuanModel>>(
                  future: _fetchSatuanList(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<SatuanModel>> snapshot) {
                    // print("sautan");
                    if (!snapshot.hasData) return CircularProgressIndicator();
                    return DropdownButton<SatuanModel>(
                      items: snapshot.data
                          .map((listsatuan) => DropdownMenuItem(
                                child: Text(listsatuan.namaSatuan),
                                value: listsatuan,
                              ))
                          .toList(),
                      onChanged: (SatuanModel value) {
                        setState(() {
                          _currentSatuan = value;
                          idSatuan = _currentSatuan.id;
                        });
                      },
                      isExpanded: false,
                      hint: Text(
                          idSatuan == null || idSatuan == widget.model.idSatuan
                              ? (loopSatuan(
                                  currentListSatuan, widget.model.idSatuan))
                              : _currentSatuan.namaSatuan),
                    );
                  }),
              TextFormField(
                controller: txtNamaBarang,
                validator: (e) {
                  if (e.isEmpty) {
                    return "Silahkan isi nama produk";
                  } else {
                    return null;
                  }
                },
                onSaved: (e) => namaBarang = e,
                decoration: InputDecoration(labelText: "Nama Produk"),
              ),
              TextFormField(
                inputFormatters: [
                  WhitelistingTextInputFormatter.digitsOnly,
                  CurrencyFormat()
                ],
                controller: txtHarga,
                validator: (e) {
                  if (e.isEmpty) {
                    return "Silahkan isi harga produk";
                  } else {
                    return null;
                  }
                },
                onSaved: (e) => harga = e,
                decoration: InputDecoration(labelText: "Harga Produk"),
              ),
              Text("Tgl Expired"),
              DateDropDown(
                labelText: labelText,
                valueText: tglexpired,
                valueStyle: valueStyle,
                onPressed: () {
                  _selectedDate(context);
                },
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
