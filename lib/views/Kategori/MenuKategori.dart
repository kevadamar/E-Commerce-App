import 'package:flutter/material.dart';
import 'package:globalshop/models/KategoriModel.dart';
import 'package:globalshop/models/api.dart';
import 'package:globalshop/views/Kategori/EditKategori.dart';
import 'package:globalshop/views/Kategori/TambahKategori.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class MenuKategori extends StatefulWidget {
  @override
  _MenuKategoriState createState() => _MenuKategoriState();
}

class _MenuKategoriState extends State<MenuKategori> {
  final money = NumberFormat("#,##0", "en_US");
  var loading = false;
  var nullData = false;

  final list = new List<KategoriModel>();
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
    final responseData = await http.get(BaseURL.apiListKategori);
    // print(BaseURL.apiBarang);
    // print(responseData.statusCode);
    final data = jsonDecode(responseData.body);
    Map<String, dynamic> resDataString = data;
    if (resDataString['code'] == 200) {
      if (resDataString['data'] == null) {
        nullData = true;
        list.add(null);
      } else {
        resDataString['data'].forEach((api) {
          final ab = new KategoriModel(api['id'], api['nama_kategori']);
          list.add(ab);
        });
        nullData = false;
      }
      setState(() {
        loading = false;
      });
    } else {
      final ab = new KategoriModel(
        null,
        null,
      );
      list.add(ab);
      setState(() {
        loading = false;
      });
    }
  }

  _prosesHapus(String id) async {
    // print('idni ${id}');
    final response =
        await http.post(BaseURL.apiDeleteKategori, body: {"id": id});
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

  _listTableRow() {
    List<TableRow> rows = [];
    int nums = 1;
    rows.add(
      TableRow(children: <Widget>[
        Container(
          alignment: Alignment.center,
          child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Center(
                child: Text(
                  "No.",
                  style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                ),
              )),
        ),
        Padding(
            padding: EdgeInsets.all(10.0),
            child: Center(
              child: Text(
                "Nama Kategori",
                style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
              ),
            )),
        Padding(
            padding: EdgeInsets.all(10.0),
            child: Center(
              child: Text(
                "Actions",
                style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
              ),
            )),
      ]),
    );

    list
        .map((e) => rows.add(
              TableRow(children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    '${nums++}',
                    style: TextStyle(fontSize: 14.0),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      '${e.namaKategori}',
                      style: TextStyle(fontSize: 14.0),
                      textAlign: TextAlign.center,
                    )),
                Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Center(
                        child: Table(
                      children: [
                        TableRow(
                          children: [
                            SizedBox(
                              height: 18.0,
                              width: 18.0,
                              child: IconButton(
                                  icon: Icon(Icons.edit, size: 18.0),
                                  padding: EdgeInsets.all(0.0),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (contex) =>
                                                new EditKategori(
                                                    e, _lihatData)));
                                  }),
                            ),
                            SizedBox(
                              height: 18.0,
                              width: 18.0,
                              child: IconButton(
                                  icon: Icon(Icons.delete, size: 18.0),
                                  padding: EdgeInsets.all(0.0),
                                  onPressed: () {
                                    dialogHapus(e.id);
                                  }),
                            ),
                          ],
                        )
                      ],
                    ))),
              ]),
            ))
        .toList();

    return rows;
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
                "Data Kategori",
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
                  builder: (context) => new TambahKategori(_lihatData)));
        },
        child: Icon(Icons.add),
        backgroundColor: Color.fromRGBO(255, 82, 48, 1),
      ),
      body: RefreshIndicator(
          onRefresh: _lihatData,
          key: _refresh,
          child: loading
              ? Center(child: CircularProgressIndicator())
              : ListView(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                      child: ( nullData
                            ? Padding(padding: EdgeInsets.all(10.0),child: Center(
                              child: Text(
                                    "Data Kosong",
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                            ),)
                            : Table(
                              border: TableBorder.all(color: Colors.black),
                              columnWidths: {
                                0: FlexColumnWidth(1),
                                1: FlexColumnWidth(5),
                                2: FlexColumnWidth(1.5),
                              },
                              children: _listTableRow()
                          )
                      )
                    ),
                  ],
                )),
    );
  }
}
