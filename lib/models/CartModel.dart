class CartModel {
  String idBarang;
  String userid;
  String namaBarang;
  String harga;
  String gambar;
  String qty;

  CartModel(this.idBarang,this.userid, this.namaBarang, this.gambar, this.harga, this.qty);

  CartModel.fromJson(Map<String, dynamic> json) {
    idBarang = json['id_barang'];
    namaBarang = json['nama_barang'];
    harga = json['harga'];
    gambar = json['gambar'];
    qty = json['qty'];
    userid = json['userid'];
  }
}
