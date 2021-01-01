class ProdukModel {
  String id;
  String idKategori;
  String userid;
  String idSatuan;
  String namaBarang;
  String harga;
  String image;
  String tglexpired;

  ProdukModel(this.id, this.idKategori,this.idSatuan, this.namaBarang, this.harga, this.image,
      this.tglexpired);

  ProdukModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    idKategori = json['id_kategori'];
    idSatuan = json['id_satuan'];
    namaBarang = json['nama_barang'];
    harga = json['harga'];
    image = json['image'];
    tglexpired = json['tglexpired'];
    userid = json['userid'];
  }
}
