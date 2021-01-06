import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:globalshop/ListMenu.dart';
import 'package:globalshop/models/KeranjangModel.dart';
import 'package:globalshop/models/ProdukModel.dart';
import 'package:globalshop/models/api.dart';
import 'package:globalshop/utils/constans.dart';
import 'package:globalshop/views/Cart/Cart.dart';
import 'package:globalshop/views/Produk/DetailProduk.dart';
import 'package:globalshop/views/RiwayatTansaksi/Riwayat.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuUser extends StatefulWidget {
  final VoidCallback signOut;

  MenuUser(this.signOut);

  @override
  _MenuUserState createState() => _MenuUserState();
}

class _MenuUserState extends State<MenuUser> {
  signOut() {
    print("lojot");
    setState(() {
      widget.signOut();
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final money = NumberFormat("#,##0", "en_US");
  String idUsers, nama, email;
  var loading = false;
  final listProduk = new List<ProdukModel>(),
      listProdukLaris = new List<ProdukModel>();

  _getUserid() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      idUsers = preferences.getInt("userid").toString();
      nama = preferences.getString("nama").toString();
      email = preferences.getString("email").toString();
    });
    _countCart();
    _lihatDataLaris();
    _lihatData();
  }

  Future<void> _lihatData() async {
    try {
      listProduk.clear();

      setState(() {
        loading = true;
      });

      final response = await http.get(BaseURL.apiBarang);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        Map<String, dynamic> resDataString = data;

        resDataString['data'].forEach((api) {
          final ab = new ProdukModel(
              api['id'],
              api['id_kategori'],
              api['id_satuan'],
              api['nama_barang'],
              api['harga'],
              api['image'],
              api['tglexpired']);
          listProduk.add(ab);
        });
        setState(() {
          loading = false;
        });
      } else {}
    } catch (e) {
      print("error catch : ");
      print(e);
    }
  }

  Future<void> _lihatDataLaris() async {
    try {
      listProdukLaris.clear();

      setState(() {
        loading = true;
      });

      final response =
          await http.get(BaseURL.apiBarang + "?q=true&userid=" + idUsers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        Map<String, dynamic> resDataString = data;

        resDataString['data'].forEach((api) {
          final ab = new ProdukModel(
              api['id'],
              api['id_kategori'],
              api['id_satuan'],
              api['nama_barang'],
              api['harga'],
              api['image'],
              api['tglexpired']);
          listProdukLaris.add(ab);
        });
        setState(() {
          loading = false;
        });
      } else {}
    } catch (e) {
      print("error catch : ");
      print(e);
    }
  }

  //add to cart method

  tambahKeranjang(String idProduk, String harga) async {
    try {
      final response = await http.post(BaseURL.apiAddCart,
          body: {"userid": idUsers, "id_barang": idProduk, "harga": harga});

      final data = jsonDecode(response.body);
      int code = data['code'];
      String pesan = data['message'];

      if (code == 200 || code == 201) {
        _countCart();
      } else {
        print("diluar 200");
        print(pesan);
      }
    } catch (e) {
      print("errorPRinter");
      print(e);
    }
  }

  String jumlahnya = "0";
  final ex = List<KeranjangModel>();

  _countCart() async {
    try {
      setState(() {
        loading = true;
      });
      ex.clear();

      final response = await http.get(BaseURL.apiCountCart + idUsers);
      final data = jsonDecode(response.body);
      final dataApi = data['data'];
      final code = data['code'];
      final pesan = data['pesan'];

      if (code == 200) {
        dataApi.forEach((api) {
          // print("data api");
          // print(api['jumlah']);
          final exp = new KeranjangModel(api['jumlah']);
          ex.add(exp);
          setState(() {
            jumlahnya = exp.jumlah;
          });
        });
      } else {
        print("err server");
        print(pesan);
      }

      setState(() {
        _countCart();
        loading = false;
      });
    } catch (e) {
      print("error catcj");
      print(e);
    }
  }

  // end add to cart

  @override
  void initState() {
    super.initState();
    _getUserid();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: EdgeInsets.only(left: 24),
            child: IconButton(
              icon: Icon(Icons.menu, size: 32, color: Colors.black),
              onPressed: () => {_scaffoldKey.currentState.openDrawer()},
            ),
          ),
          title: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(0.0),
              topRight: Radius.circular(0.0),
            ),
            child: Image.asset("assets/img/logo.jpg"),
          ),
          actions: <Widget>[
            Stack(
              children: <Widget>[
                IconButton(
                    icon: Icon(Icons.shopping_cart, color: Colors.black),
                    onPressed: () => {
                          // count in cart
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => new Cart()))
                        }),
                // counting in cart
                (jumlahnya == "0"
                    ? Container()
                    : Positioned(
                        right: 0.0,
                        child: Stack(
                          children: <Widget>[
                            Icon(Icons.brightness_1,
                                size: 20.0, color: Colors.white),
                            Positioned(
                                top: 3.0,
                                right: 6.0,
                                child: Text(
                                  jumlahnya,
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 11.0),
                                ))
                          ],
                        )))
                //end counting cart
              ],
            )
          ],
        ),
        key: _scaffoldKey,
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Container(
            padding: EdgeInsets.only(
              left: 24,
              top: 16,
              bottom: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(
                  height: 12,
                ),
                Text(
                  'Produk Terlaris',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  height: 300,
                  child: ListView(
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    children: buildItemsLaris(),
                  ),
                ),
                Text(
                  'Produk Terbaru',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  height: 300,
                  child: ListView(
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    children: buildItems(),
                  ),
                )
              ],
            ),
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text(nama != null ? nama : "Keva Damar Galih"),
                accountEmail: Text(
                    email != null ? email : "1118100066@stmikglobal.ac.id"),
                decoration: new BoxDecoration(color: Colors.grey),
                currentAccountPicture: new CircleAvatar(
                  backgroundImage: AssetImage('assets/img/user.png'),
                ),
              ),
              ListTile(
                title: Text("Home"),
                onTap: () {},
              ),
              ListTile(
                title: Text("Master Data"),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (contex) => new ListMenu()));
                },
              ),
              ListTile(
                title: Text("Riwayat Transaksi"),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (contex) => new Riwayat()));
                },
              ),
              ListTile(
                title: Text("Logout"),
                onTap: () {
                  setState(() {
                    signOut();
                  });
                },
              )
            ],
          ),
        ));
  }

  Widget buildItem(ProdukModel listProduk) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailProduk(listProduk: listProduk)));
        // detail page
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
                gradient: kGradient,
                borderRadius: BorderRadius.all(Radius.circular(10)),
                border: Border.all(width: 1, color: Colors.grey[300])),
            margin: EdgeInsets.only(right: 24),
            child: Stack(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                  child: Center(
                    child: Hero(
                        tag: new Text(listProduk.namaBarang.length > 20
                            ? listProduk.namaBarang.substring(0, 15) + " . . . "
                            : listProduk.namaBarang),
                        child: Image.network(
                          BaseURL.paths + '/' + listProduk.image,
                          width: 190,
                          fit: BoxFit.contain,
                        )),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // add to cart
                    tambahKeranjang(listProduk.id, listProduk.harga);
                  },
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(25))),
                      width: 60,
                      height: 60,
                      child: Center(
                          child: Icon(
                        Icons.add_shopping_cart,
                        size: 32,
                        color: Colors.black,
                      )),
                    ),
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Text(
            listProduk.namaBarang.length > 20
                ? listProduk.namaBarang.substring(0, 15) + " . . . "
                : listProduk.namaBarang,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            "Rp. " + money.format(int.parse(listProduk.harga)),
            style: TextStyle(
                fontSize: 16,
                color: Colors.orange,
                fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }

  List<Widget> buildItems() {
    List<Widget> list = [];
    for (var listProduk in listProduk) {
      list.add(buildItem(listProduk));
    }
    return list;
  }

  List<Widget> buildItemsLaris() {
    List<Widget> list = [];
    for (var listProduk in listProdukLaris) {
      list.add(buildItem(listProduk));
    }
    return list;
  }
}
