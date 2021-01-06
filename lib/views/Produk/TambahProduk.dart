import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class TambahProduk extends StatefulWidget {
  final VoidCallback reload;
  TambahProduk(this.reload);
  @override
  _TambahProdukState createState() => _TambahProdukState();
}

class _TambahProdukState extends State<TambahProduk> {
  String namaBarang, harga, userid, idKategori, tglexpired, idSatuan;

  final _key = new GlobalKey<FormState>();

  File _imageFile;

  KategoriModel _currentKategori;
  SatuanModel _currentSatuan;

  final String linkKategori = BaseURL.apiListKategori;
  final String linkSatuan = BaseURL.apiListSatuan;

  Future<List<KategoriModel>> _fetchKategoriList() async {
    var responseData = await http.get(linkKategori);
    var resData = jsonDecode(responseData.body);
    Map<String, dynamic> data = resData;
    // print("dari data");
    // print(data);

    if (responseData.statusCode == 200 && data['code'] == 200) {
      final items = data['data'];
      List<KategoriModel> listOfKategori = items.map<KategoriModel>((json) {
        // print(json);
        return KategoriModel.fromJson(json);
      }).toList();
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
        // print(json);
        // return json;
        return SatuanModel.fromJson(json);
      }).toList();
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
      if (_imageFile == null) {
        _dialogMessageNotif("Foto tidak boleh kosong", 404);
        return;
      }

      if (idKategori == null) {
        _dialogMessageNotif("Kategori tidak boleh kosong", 404);
        return;
      }

      if (idSatuan == null) {
        _dialogMessageNotif("Satuan tidak boleh kosong", 404);
        return;
      }

      var stream =
          http.ByteStream(DelegatingStream.typed(_imageFile.openRead()));
      var length = await _imageFile.length();
      var uri = Uri.parse(BaseURL.apiPostBarang);
      var request = http.MultipartRequest("POST", uri);
      request.fields['nama_barang'] = namaBarang;
      request.fields['harga'] = harga.replaceAll(",", "");
      request.fields['id_kategori'] = idKategori;
      request.fields['tglexpired'] = "$tgl";
      request.fields['userid'] = "1";
      request.fields['id_satuan'] = idSatuan;
      request.files.add(http.MultipartFile("image", stream, length,
          filename: path.basename(_imageFile.path)));

      final responseServe = await request.send();

      Map<String, dynamic> respStr =
          jsonDecode(await responseServe.stream.bytesToString());

      if (responseServe.statusCode == 201 || responseServe.statusCode == 200) {

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
      print(e);
    }
  }

  String pilihTanggal, labelText;
  DateTime tgl = new DateTime.now();
  final TextStyle valueStyle = TextStyle(fontSize: 16.0);
  Future<Null> _selectedDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: tgl,
        firstDate: DateTime(1992),
        lastDate: DateTime(2099));
    if (picked != null && picked != tgl) {
      setState(() {
        tgl = picked;
        pilihTanggal = new DateFormat.yMd().format(tgl);
      });
    } else {}
  }

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

  @override
  void initState() {
    super.initState();
    // getPref();
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
                  "Tambah Produk",
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
                  height: 140.0,
                  child: InkWell(
                      onTap: () {
                        dialogFileFoto();
                      },
                      child: _imageFile == null
                          ? placeholder
                          : Image.file(_imageFile, fit: BoxFit.fill))),
              SizedBox(
                height: 15.0,
              ),
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
                      hint: Text(idKategori == null
                          ? "Select"
                          : _currentKategori.namaKategori),
                    );
                  }),
              SizedBox(
                height: 15.0,
              ),
              Text("Satuan Produk"),
              FutureBuilder<List<SatuanModel>>(
                  future: _fetchSatuanList(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<SatuanModel>> snapshot) {
                    if (!snapshot.hasData) return CircularProgressIndicator();
                    return DropdownButton<SatuanModel>(
                      items: snapshot.data
                          .map((listsatuan) => DropdownMenuItem<SatuanModel>(
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
                          idSatuan == null ? "Select" : _currentSatuan.satuan),
                    );
                  }),
              TextFormField(
                validator: (e) {
                  if (e.isEmpty) {
                    return "Silahkan isi nama produk";
                  }
                },
                onSaved: (e) => namaBarang = e,
                decoration: InputDecoration(labelText: "Nama Produk"),
              ),
              SizedBox(
                height: 10.0,
              ),
              TextFormField(
                inputFormatters: [
                  WhitelistingTextInputFormatter.digitsOnly,
                  CurrencyFormat()
                ],
                validator: (e) {
                  if (e.isEmpty) {
                    return "Silahkan isi harga produk";
                  }
                },
                onSaved: (e) => harga = e,
                decoration: InputDecoration(labelText: "Harga Produk"),
              ),
              SizedBox(
                height: 25.0,
              ),
              Text("Tgl Expired"),
              DateDropDown(
                labelText: labelText,
                valueText: new DateFormat.yMd().format(tgl),
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
