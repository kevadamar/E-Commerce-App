import 'package:flutter/material.dart';
import 'package:globalshop/models/RiwayatTransaksiModel.dart';
import 'package:globalshop/models/api.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Riwayat extends StatefulWidget {
  @override
  _RiwayatState createState() => _RiwayatState();
}

class _RiwayatState extends State<Riwayat> {
  final money = NumberFormat("#,##0", "en_US");
  var loading = false;
  var nullData = false;
  
  var formated = new DateFormat("d MMMM yyyy").format(DateTime.parse("2021-01-01"));

  final list = new List<RiwayatTransaksiModel>();
  final GlobalKey<RefreshIndicatorState> _refresh =
      GlobalKey<RefreshIndicatorState>();

  getPref() async {
    _lihatData();
    print(formated);
  }

  Future<void> _lihatData() async {
    list.clear();
    setState(() {
      loading = true;
    });
    final responseData = await http.get(BaseURL.apiListRiwayat);
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
                          padding: EdgeInsets.all(10.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Image.network(BaseURL.paths + '/' + resData.gambar,
                                  width: 100.0,
                                  height: 120.0,
                                  fit: BoxFit.cover),
                              SizedBox(width: 10.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    // nama barang
                                    Text(resData.namabarang,
                                        style: TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold)),
                                    // tanggal terjual
                                    Text(
                                        '1' + resData.satuan + '/Rp.' +
                                            money.format(
                                              int.parse(resData.hargadetailperbarang),
                                            ),
                                        
                                        style: TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.info_outline),
                                onPressed: () {
                                  // Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //         builder: (contex) =>
                                  //             new EditProduk(resData, _lihatData)));
                                },
                              )
                            ],
                          ),
                        );
                      },
                    ))),
    );
  }
}
