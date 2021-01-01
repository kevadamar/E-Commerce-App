// // import 'package:flutter/material.dart';
// import 'package:globalshop/models/SatuanModel.dart';
// import 'package:globalshop/models/api.dart';
// import 'package:globalshop/views/Satuan/EditSatuan.dart';
// import 'package:globalshop/views/Satuan/TambahSatuan.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';

// class MenuSatuan extends StatefulWidget {
//   @override
//   _MenuSatuanState createState() => _MenuSatuanState();
// }

// class _MenuSatuanState extends State<MenuSatuan> {
//   final money = NumberFormat("#,##0", "en_US");
//   var loading = false;

//   final list = new List<SatuanModel>();
//   var listSatuan = <SatuanModel>[
//     SatuanModel("1", "barang", "brg"),
//     SatuanModel("2", "centimeters", "cm")
//   ];
//   final GlobalKey<RefreshIndicatorState> _refresh =
//       GlobalKey<RefreshIndicatorState>();

//   getPref() async {
//     _lihatData();
//   }

//   Future<void> _lihatData() async {
//     list.clear();
//     setState(() {
//       loading = true;
//     });
//     final responseData = await http.get(BaseURL.apiListSatuan);
//     // print(BaseURL.apiBarang);
//     // print(responseData.statusCode);
//     final data = jsonDecode(responseData.body);
//     Map<String, dynamic> resDataString = data;
//     if (resDataString['code'] == 200) {
//       if (resDataString['data'] == null) {
//         list.add(null);
//       } else {
//         resDataString['data'].forEach((api) {
//           final ab =
//               new SatuanModel(api['id'], api['nama_satuan'], api['satuan']);
//           list.add(ab);
//         });
//       }
//       setState(() {
//         loading = false;
//       });
//     } else {
//       final ab = new SatuanModel(
//         null,
//         null,
//         null,
//       );
//       list.add(ab);
//       setState(() {
//         loading = false;
//       });
//     }
//   }

//   _prosesHapus(String id) async {
//     // print('idni ${id}');
//     final response = await http.post(BaseURL.apiDeleteSatuan, body: {"id": id});
//     final data = jsonDecode(response.body);
//     int code = data['code'];
//     String pesan = data['message'];
//     if (code == 200) {
//       setState(() {
//         Navigator.pop(context);
//         _lihatData();
//       });
//     } else {
//       print(pesan);
//     }
//   }

//   dialogHapus(String id) {
//     showDialog(
//         context: context,
//         builder: (context) {
//           return Dialog(
//             child: ListView(
//               padding: EdgeInsets.all(16.0),
//               shrinkWrap: true,
//               children: <Widget>[
//                 Text("Apakah anda yakin ingin menghapus data ini ?",
//                     style:
//                         TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
//                 SizedBox(height: 18.0),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: <Widget>[
//                     InkWell(
//                       onTap: () {
//                         Navigator.pop(context);
//                       },
//                       child: Text("Tidak",
//                           style: TextStyle(
//                               fontSize: 18.0, fontWeight: FontWeight.bold)),
//                     ),
//                     SizedBox(width: 25.0),
//                     InkWell(
//                       onTap: () {
//                         _prosesHapus(id);
//                       },
//                       child: Text("Ya",
//                           style: TextStyle(
//                               fontSize: 18.0, fontWeight: FontWeight.bold)),
//                     )
//                   ],
//                 )
//               ],
//             ),
//           );
//         });
//   }

//   @override
//   void initState() {
//     super.initState();
//     getPref();
//   }

//   @override
//   Widget build(BuildContext context) {
//     int nums = 1;
//     return Scaffold(
//       appBar: AppBar(
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: <Widget>[
//             Container(
//               child: Text(
//                 "Data Satuan",
//                 style: TextStyle(color: Colors.white, fontSize: 20.0),
//               ),
//             )
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.push(
//               context,
//               MaterialPageRoute(
//                   builder: (context) => new TambahSatuan(_lihatData)));
//         },
//         child: Icon(Icons.add),
//         backgroundColor: Color.fromRGBO(255, 82, 48, 1),
//       ),
//       body: RefreshIndicator(
//           onRefresh: _lihatData,
//           key: _refresh,
//           child: loading
//               ? Center(child: CircularProgressIndicator())
//               : Container(
//                   child: DataTable(
//                   columns: const <DataColumn>[
//                     DataColumn(
//                         label: Text("No",
//                             style: TextStyle(
//                                 fontSize: 14.0, fontWeight: FontWeight.bold))),
//                     DataColumn(
//                         label: Text("Nama Satuan",
//                             style: TextStyle(
//                                 fontSize: 14.0, fontWeight: FontWeight.bold))),
//                     DataColumn(
//                         label: Text("Satuan",
//                             style: TextStyle(
//                                 fontSize: 14.0, fontWeight: FontWeight.bold))),
//                     DataColumn(
//                         label: Text("Edit",
//                             style: TextStyle(
//                                 fontSize: 14.0, fontWeight: FontWeight.bold))),
//                     DataColumn(
//                         label: Text("Delete",
//                             style: TextStyle(
//                                 fontSize: 14.0, fontWeight: FontWeight.bold))),
//                   ],
//                   rows: list
//                       .map((e) => DataRow(cells: [
//                             DataCell(Text('${nums++}')),
//                             DataCell(Text(e.namaSatuan)),
//                             DataCell(Text(e.satuan)),
//                             DataCell(Icon(Icons.edit), onTap: () {
//                               Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (contex) =>
//                                           new EditSatuan(e, _lihatData)));
//                             }),
//                             DataCell(Icon(Icons.delete), onTap: () {
//                               dialogHapus(e.id);
//                             }),
//                           ]))
//                       .toList(),
//                 ))),
//     );
//   }
// }