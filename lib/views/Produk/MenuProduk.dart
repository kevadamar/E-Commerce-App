import 'package:flutter/material.dart';
import 'package:globalshop/models/ProdukModel.dart';
import 'package:globalshop/models/api.dart';
import 'package:globalshop/views/Produk/EditProduk.dart';
import 'package:globalshop/views/Produk/TambahProduk.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class MenuProduk extends StatefulWidget {
  @override
  _MenuProdukState createState() => _MenuProdukState();
}

class _MenuProdukState extends State<MenuProduk> {
  final money = NumberFormat("#,##0", "en_US");
  var loading = false;
  var nullData = false;

  final list = new List<ProdukModel>();
  final GlobalKey<RefreshIndicatorState> _refresh =
      GlobalKey<RefreshIndicatorState>();

  getPref() async {
    _lihatData();
  }

  Future<void> _lihatData() async {
    list.clear();
    setState(() {
      loading = true;
    });
    final responseData = await http.get(BaseURL.apiBarang);
    // print(BaseURL.apiBarang);
    // print(responseData.statusCode);
    final data = jsonDecode(responseData.body);
    Map<String, dynamic> resDataString = data;
    if (resDataString['code'] == 200) {
      // print("cek data");
      // print(resDataString['data']);
      if (resDataString['data'] == null) {
        nullData = true;
      } else {
        resDataString['data'].forEach((api) {
          final ab = new ProdukModel(
            api['id'],
            api['id_kategori'],
            api['id_satuan'],
            api['nama_barang'],
            api['harga'],
            api['image'],
            api['tglexpired'],
          );
          list.add(ab);
        });
        nullData = false;
      }
      setState(() {
        loading = false;
      });
    } else {
      final ab = new ProdukModel(
        "1",
        "1",
        "1",
        "error",
        "2",
        "cimory.jpg",
        "2020-03-03",
      );
      list.add(ab);
      setState(() {
        loading = false;
      });
    }
  }

  _prosesHapus(String id) async {
    // print('idni ${id}');
    final response = await http.post(BaseURL.apiDeleteBarang, body: {"id": id});
    final data = jsonDecode(response.body);
    int code = data['code'];
    String pesan = data['message'];
    if (code == 200) {
      setState(() {
        Navigator.pop(context);
        _lihatData();
      });
    } else {
      print(pesan);
    }
  }

  dialogHapus(String id) {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: ListView(
              padding: EdgeInsets.all(16.0),
              shrinkWrap: true,
              children: <Widget>[
                Text("Apakah anda yakin ingin menghapus data ini ?",
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                SizedBox(height: 18.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text("Tidak",
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(width: 25.0),
                    InkWell(
                      onTap: () {
                        _prosesHapus(id);
                      },
                      child: Text("Ya",
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold)),
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
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Text(
                "Data Produk",
                style: TextStyle(color: Colors.white, fontSize: 20.0),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => new TambahProduk(_lihatData)));
        },
        child: Icon(Icons.add),
        backgroundColor: Color.fromRGBO(255, 82, 48, 1),
      ),
      body: RefreshIndicator(
          onRefresh: _lihatData,
          key: _refresh,
          child: loading
              ? Center(child: CircularProgressIndicator())
              : (nullData
                  ? ListView(children: <Widget>[
                      Container(
                          width: MediaQuery.of(context).size.width,
                          color: Colors.white,
                          child: Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Center(
                                child: Text(
                                  "Data Kosong",
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              )))
                    ])
                  : ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, i) {
                        final resData = list[i];
                        return Container(
                            padding: EdgeInsets.only(
                                top: 12.0, left: 12.0, right: 12.0),
                            child: Card(
                              elevation: 2.5,
                              // shadowColor: Colors.deepOrangeAccent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Image.network(
                                      BaseURL.paths + '/' + resData.image,
                                      width: 70.0,
                                      height: 90.0,
                                      fit: BoxFit.cover),
                                  SizedBox(width: 10.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          "No." + (i + 1).toString(),
                                          style: TextStyle(fontSize: 15.0),
                                        ),
                                        Text(resData.namaBarang,
                                            style: TextStyle(
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.bold)),
                                        Text(
                                            "Rp." +
                                                money.format(
                                                  int.parse(resData.harga),
                                                ),
                                            style: TextStyle(
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (contex) =>
                                                      new EditProduk(resData,
                                                          _lihatData)));
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () {
                                          dialogHapus(resData.id);
                                        },
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ));
                      },
                    ))),
    );
  }
}
