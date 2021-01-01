import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:globalshop/models/CartModel.dart';
import 'package:globalshop/models/api.dart';
import 'package:globalshop/utils/currency.dart';
import 'package:globalshop/views/Cart/checkout.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Cart extends StatefulWidget {
  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  final _key = new GlobalKey<FormState>();
  final money = NumberFormat("#,##0", "en_US");
  final list = new List<CartModel>();
  final GlobalKey<RefreshIndicatorState> _refresh = GlobalKey<RefreshIndicatorState>();
  var loading = false;
  String idUsers;

  getPref()async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      idUsers = preferences.getInt("userid").toString();
    });
    _countData();
    _lihatData();
  }

  String totalBelanja = "0", nilaiBayar = "0";

  Future<void> _lihatData()async{
    list.clear();
    setState(() {
      loading = true;
    });

    final response = await http.get(BaseURL.apiDetailCart + idUsers);
    final data = jsonDecode(response.body);
    final dataApi = data['data'];
    int code = data['code'];
    String pesan = data['message'];
    if(code == 200) {
      dataApi.forEach((api){
        final ab = new CartModel(api['id_barang'],idUsers,api['nama_barang'],api['gambar'],api['harga'],api['qty']);
        list.add(ab);
      });
      setState(() {
        _countData();
        loading = false;
      });
    } else {
      print("Code : $code");
      print("pesan : $pesan");
      setState(() {
        _countData();
        loading = false;
      });
    }
  }

  Future<void> _countData() async {
    setState(() {
      loading = true;
    });
    final response = await http.get(BaseURL.apiCountCart + idUsers);
    final data = jsonDecode(response.body);

    final dataApi = data['data'];
    int code = data['code'];
    String pesan = data['message'];
    if(code == 200) {
      dataApi.forEach((api){
        totalBelanja = api['totalHarga'];
      });
      setState(() {
        loading = false;
      });
    } else {
      print("Code : $code");
      print("pesan : $pesan");
      setState(() {
        loading = false;
      });
    }
  }

  // dialog checkout proses
  dialogCheckout(String idUser, String grandTotal){
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Form(
            key: _key,
            child: ListView(
              padding: EdgeInsets.all(16.0),
              shrinkWrap: true,
              children: <Widget>[
                Text(
                  "Form Pembayaran"
                ),
                TextFormField(
                  inputFormatters: [
                    WhitelistingTextInputFormatter.digitsOnly,
                    CurrencyFormat()
                  ],
                  validator: (e){
                    if (e.isEmpty) {
                      return "Silahkan isi nilai bayar";
                    }
                  },
                  onSaved: (e)=> nilaiBayar = e,
                  decoration: InputDecoration(
                    labelText: "Nilai Bayar"
                  ),
                ),
                SizedBox(height:18.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    InkWell(
                      onTap: (){
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Batal",
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    SizedBox(width:25.0),
                    InkWell(
                      onTap: (){
                        check(idUser,grandTotal);
                      },
                      child: Text(
                        "Proses",
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      }
    );
  }

  // dialog cart empty checkout
  dialogCart(String txt){
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Form(
            key: _key,
            child: ListView(
              padding: EdgeInsets.all(16.0),
              shrinkWrap: true,
              children: <Widget>[
                Text(
                  txt,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(height:18.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    InkWell(
                      onTap: (){
                        Navigator.pop(context);
                      },
                      child: Text(
                        "OK",
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        );
      }
    );
  }

// dialog delete product in cart
dialogDelProductInCart(String idProduk,String harga,String paramUserId){
  showDialog(
    context: context,
    builder: (context){
      return Dialog(
        child: Form(
          key: _key,
          child: ListView(
            padding: EdgeInsets.all(16.0),
            shrinkWrap: true,
            children: <Widget>[
              Text(
                "Ingin menghapus Produk dari pembelian ?",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(height:18.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    InkWell(
                      onTap: (){
                        minusQtyinCart(idProduk,harga,paramUserId);
                        Navigator.pop(context);
                      },
                      child: Text(
                        "YA",
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    SizedBox(width:18.0),
                    InkWell(
                      onTap: (){
                        Navigator.pop(context);
                      },
                      child: Text(
                        "TIDAK",
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ],
                )
            ],
          ),
        ),
      );
    }
  );
}

// VALIDATE Form
check(String userid,String gt){
  final form = _key.currentState;
  print("cek");
  if (form.validate()) {
    print(userid + " : " + gt);
    form.save();
    _checkout(userid,gt);
  } else {
  }
}

// Checkout Proses
_checkout(String userid,String total) async {
  double dTotal = double.parse(total.replaceAll(",", ""));
  double dNilaiBayar = double.parse(nilaiBayar.replaceAll(",", ""));
  double dNilaiKembali = dNilaiBayar - dTotal;
  if (dNilaiBayar >= dTotal) {
    final response = await http.post(BaseURL.apiCheckout, body: {
      "userid" : userid,
      "grandtotal" : total.replaceAll(",", ""),
      "nilaibayar" : nilaiBayar.replaceAll(",", ""),
      "nilaikembali" : dNilaiKembali.toString()
    });
    final data = jsonDecode(response.body);
    int code = data['code'];
    String pesan = data['message'];

    if (code == 200 || code == 201) {
      setState(() {
        Navigator.pop(context);
        // link kehalaman berhasil checkout
        Navigator.push(context, MaterialPageRoute(builder: (context)=> new Checkout()));
      });
    } else {
      Navigator.pop(context);
      print("Code : $code");
      print("pesan : $pesan");
    }
  } else {
    dialogCart("Pembayaran Kurang");
  }
}

// proses add qty in cart
_addQtyinCart(String idProduk, String harga, String paramUserId)async{
  final response = await http.post(BaseURL.apiAddCart,body: {
    "userid": paramUserId,
    "id_barang": idProduk,
    "harga":harga
  });
  final data = jsonDecode(response.body);
      int code = data['code'];
      String pesan = data['message'];

      if (code == 200 || code == 201) {
        setState(() {
          getPref();
        });
      } else {
        print("diluar 200");
        print(pesan);
        throw StateError("Failed to update data");
      }
}

// proses minus qty in cart
minusQtyinCart(String idProduk, String harga, String paramUserId)async{
  final response = await http.post(BaseURL.apiMinCart,body: {
    "userid": paramUserId,
    "id_barang": idProduk,
    "harga":harga
  });
  final data = jsonDecode(response.body);
      int code = data['code'];
      String pesan = data['message'];

      if (code == 200 || code == 201) {
        setState(() {
          getPref();
        });
      } else {
        print("diluar 200");
        print(pesan);
        throw StateError("Failed to update data");
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
        elevation: 0.1,
        backgroundColor: Colors.orange,
        title: Text(
          "Detail Belanja"
        ),
        actions: <Widget>[
          new IconButton(
            icon: Icon(Icons.search),
            color: Colors.white,
            onPressed: (){},
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _lihatData,
        child: loading 
        ? Center(child:CircularProgressIndicator())
        : ListView.builder(
          itemCount: list.length,
          itemBuilder: (context,i){
            final x = list[i];
            int _currentAmount = int.parse(x.qty);
            int _idbrg = x.idBarang == null ? 0 : int.parse(x.idBarang);
            return Container(
              margin: EdgeInsets.only(bottom:5),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.white
                      ),
                      child: Image.network(
                        BaseURL.paths + "/" + x.gambar,
                        width: 100.0,
                        height: 160.0,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  SizedBox(width:10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "${x.namaBarang}",
                          style: Theme.of(context).textTheme.title,
                        ),
                        Text(
                          "Rp. " + "${money.format(int.parse(x.harga))}"
                        ),
                        SizedBox(height:15),
                        Row(
                          children: <Widget>[
                            GestureDetector(
                              child: Container(
                                padding: const EdgeInsets.all(5.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.orange
                                ),
                                child: Icon(
                                  Icons.remove,
                                  color: Colors.white
                                ),
                              ),
                              onTap: (){
                                if (_currentAmount == 1) {
                                  _currentAmount = 0;
                                  dialogDelProductInCart(x.idBarang, x.harga, x.userid);
                                } else {
                                  minusQtyinCart(x.idBarang, x.harga, x.userid);
                                }
                              },
                            ),
                            SizedBox(width:15),
                            Text(
                              "$_currentAmount",
                              style: Theme.of(context).textTheme.title,
                            ),
                            SizedBox(width:15),
                            GestureDetector(
                              child: Container(
                                padding: const EdgeInsets.all(5.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.orange
                                ),
                                child: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                              ),
                              onTap: (){
                                _addQtyinCart(x.idBarang, x.harga, x.userid);
                              },
                            )
                          ],
                        )
                      ],
                    )
                  ),
                ],
              ),
            );
          }
        ),
      ),
      bottomNavigationBar: new Container(
        color: Colors.white,
        child: new Row(
          children: <Widget>[
            Expanded(
              child: ListTile(
                title: new Text("Total : "),
                subtitle: new Text("Rp. " + money.format(int.parse(totalBelanja))),
              )
            ),
            Expanded(
              child: new MaterialButton(
                onPressed: (){
                  totalBelanja != "0" 
                  ? dialogCheckout(idUsers, totalBelanja)
                  : dialogCart("Tidak ada transaksi");
                },
                child: new Text(
                  "Checkout",
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.orange,
              )
            )
          ],
        )
      ),
    );
  }
}