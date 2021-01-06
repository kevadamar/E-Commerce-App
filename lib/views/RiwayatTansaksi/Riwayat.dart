import 'package:flutter/material.dart';
import 'package:globalshop/models/RiwayatTransaksiModel.dart';
import 'package:globalshop/models/api.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Riwayat extends StatefulWidget {
  @override
  _RiwayatState createState() => _RiwayatState();
}

class _RiwayatState extends State<Riwayat> {
  final money = NumberFormat("#,##0", "en_US");
  var loading = false;
  var nullData = false;

  var formated =
      new DateFormat("d MMMM yyyy").format(DateTime.parse("2021-01-01"));
  String idUsers;

  final list = new List<RiwayatTransaksiModel>();
  final GlobalKey<RefreshIndicatorState> _refresh =
      GlobalKey<RefreshIndicatorState>();

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      idUsers = preferences.getInt("userid").toString();
    });
    _lihatData();
    print(formated);
  }

  _formattgl(date) {
    return new DateFormat("d MMM yyyy").format(DateTime.parse(date));
  }

  Future<void> _lihatData() async {
    list.clear();
    setState(() {
      loading = true;
    });
    final responseData =
        await http.post(BaseURL.apiListRiwayat, body: {"userid": idUsers});
    // print(BaseURL.apiBarang);
    // print(responseData.statusCode);
    final data = jsonDecode(responseData.body);

    Map<String, dynamic> resDataString = data;
    if (resDataString['code'] == 200) {
      // print("cek data");
      if (resDataString['data'] == null) {
        nullData = true;
      } else {
        resDataString['data'].forEach((api) {
          print("data api : ");
          print(api['nama_barang']);
          final ab = new RiwayatTransaksiModel(
            api['id_faktur'],
            api['id_barang'],
            api['harga_detail_per_barang'],
            api['nama_barang'],
            api['grandtotal'],
            api['gambar'],
            api['tgl_penjualan'],
            api['qty'],
            api['harga_satuan'],
            api['nama_satuan'],
            api['nilaibayar'],
            api['nilaikembali'],
            api['satuan'],
          );
          list.add(ab);
        });
        nullData = false;
      }
      setState(() {
        loading = false;
      });
    } else {
      final ab = new RiwayatTransaksiModel(
        "1",
        "1",
        "1",
        "error",
        "2",
        "cimory.jpg",
        "2020-03-03",
        "error",
        "error",
        "error",
        "error",
        "error",
        "error",
      );
      list.add(ab);
      setState(() {
        loading = false;
      });
    }
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
                "Riwayat Transaksi",
                style: TextStyle(color: Colors.white, fontSize: 20.0),
              ),
            )
          ],
        ),
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
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      Container(
                                          child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Padding(
                                            padding:
                                                EdgeInsets.only(left: 15.0),
                                            child: IconButton(
                                              icon: Icon(
                                                Icons.shopping_bag,
                                                color: Colors.deepOrangeAccent,
                                                size: 34.0,
                                              ),
                                              onPressed: null,
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(top: 10.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  "Belanja",
                                                  style: TextStyle(
                                                      fontSize: 13.0,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(_formattgl(
                                                    resData.tglpenjualan))
                                              ],
                                            ),
                                          )
                                        ],
                                      )),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      Image.network(
                                          BaseURL.paths + '/' + resData.gambar,
                                          width: 50.0,
                                          height: 60.0,
                                          fit: BoxFit.cover),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Text(
                                          "Total Belanja",
                                          style: TextStyle(
                                            fontSize: 13.0,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 8.0),
                                        child: Text(
                                            'Rp.' +
                                                money.format(
                                                  int.parse(resData
                                                      .hargadetailperbarang),
                                                ),
                                            style: TextStyle(
                                                fontSize: 17.0,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                    ],
                                  )),
                                  Padding(
                                    padding: EdgeInsets.only(top: 15.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        // nama barang
                                        Text(resData.namabarang,
                                            style: TextStyle(
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.bold)),
                                        SizedBox(
                                          height: 5.0,
                                        ),
                                        // qty
                                        Text(
                                            resData.qty +
                                                " " +
                                                resData.namasatuan,
                                            style: TextStyle(fontSize: 12.0)),
                                        SizedBox(
                                          height: 10.0,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ));
                      },
                    ))),
    );
  }
}
