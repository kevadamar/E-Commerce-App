import 'package:flutter/material.dart';
import 'package:globalshop/models/ProdukModel.dart';
import 'package:globalshop/models/api.dart';
import 'package:globalshop/utils/constans.dart';
import 'package:globalshop/views/RiwayatTansaksi/DetailRiwayat.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:globalshop/models/KeranjangModel.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DetailProduk extends StatefulWidget {
  final ProdukModel listProduk;

  DetailProduk({@required this.listProduk});

  @override
  _DetailProdukState createState() => _DetailProdukState();
}

class _DetailProdukState extends State<DetailProduk> {
  int _currentImage = 0;
  final money = NumberFormat("#,##0", "en_US");
  var loading = false;
  String idUsers;

  _getUserid() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      idUsers = preferences.getInt("userid").toString();
    });
    _countCart();
  }

  List<Widget> buildPageIndicator() {
    List<Widget> list = [];

    for (var i = 0; i < widget.listProduk.image.length; i++) {
      list.add(
          i == _currentImage ? buildIndicator(true) : buildIndicator(false));
    }
    return list;
  }

  Widget buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 6.0),
      height: 8.0,
      width: isActive ? 20.0 : 8.0,
      decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.grey[400],
          borderRadius: BorderRadius.all(Radius.circular(12))),
    );
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
    setState(() {
      loading = true;
    });
    ex.clear();

    final response = await http.get(BaseURL.apiCountCart + idUsers);
    final data = jsonDecode(response.body);

    final dataApi = data['data'];

    dataApi.forEach((api) {
      final exp = new KeranjangModel(api['jumlah']);
      ex.add(exp);
      setState(() {
        jumlahnya = exp.jumlah;
      });
    });

    setState(() {
      _countCart();
      loading = false;
    });
  }

  // end add to cart

  @override
  void initState() {
    super.initState();
    _getUserid();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Text(
                "Detail " + widget.listProduk.namaBarang,
                style: TextStyle(color: Colors.black, fontSize: 20.0),
              ),
            )
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.keyboard_arrow_left,
            size: 32,
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          Stack(
            children: <Widget>[
              IconButton(
                  icon: Icon(
                    Icons.shopping_cart,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    // count in cart
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => new Cart()));
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
      body: Container(
        decoration: BoxDecoration(gradient: kGradient),
        child: SafeArea(
            child: Column(
          children: <Widget>[
            Expanded(
                child: PageView(
              physics: BouncingScrollPhysics(),
              onPageChanged: (int page) {
                setState(() {
                  _currentImage = page;
                });
              },
              children: <Widget>[
                Container(
                  child: Hero(
                      tag: widget.listProduk.namaBarang,
                      child: Image.network(
                        BaseURL.paths + "/" + widget.listProduk.image,
                        width: 100,
                        fit: BoxFit.contain,
                      )),
                )
              ],
            )),
            Container(
              height: size.height * 0.4,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40))),
              child: Column(
                children: <Widget>[
                  Container(
                    height: size.height * 0.3,
                    padding: EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          widget.listProduk.namaBarang,
                          style: TextStyle(
                              fontSize: 26,
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              "Rp. " +
                                  money.format(
                                      int.parse(widget.listProduk.harga)),
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.deepOrange,
                                  fontWeight: FontWeight.bold),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  "Price Ratings",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey[400]),
                                ),
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.star,
                                      size: 16,
                                      color: kStarsColor,
                                    ),
                                    Icon(
                                      Icons.star,
                                      size: 16,
                                      color: kStarsColor,
                                    ),
                                    Icon(
                                      Icons.star,
                                      size: 16,
                                      color: kStarsColor,
                                    ),
                                    Icon(
                                      Icons.star,
                                      size: 16,
                                      color: kStarsColor,
                                    ),
                                    Icon(
                                      Icons.star,
                                      size: 16,
                                      color: kStarsColor,
                                    ),
                                  ],
                                )
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
              height: size.height * 0.1,
              decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40))),
              child: GestureDetector(
                onTap: () {
                  // add to cart
                  tambahKeranjang(
                      widget.listProduk.id, widget.listProduk.harga);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Add To Cart",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Icon(
                      Icons.shopping_basket,
                      color: Colors.white,
                      size: 30,
                    )
                  ],
                ),
              ),
            )
          ],
        )),
      ),
    );
  }
}
