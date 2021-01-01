class RiwayatTransaksiModel {
  String idfaktur;
  String idbarang;
  String hargasatuan;
  String hargadetailperbarang;
  String namabarang;
  String grandtotal;
  String gambar;
  String tglpenjualan;
  String nilaibayar;
  String nilaikembali;
  String qty;
  String namasatuan;
  String satuan;

  RiwayatTransaksiModel(this.idfaktur, this.idbarang,this.hargadetailperbarang, this.namabarang, this.grandtotal, this.gambar,
      this.tglpenjualan,this.qty,this.hargasatuan,this.namasatuan,this.nilaibayar,this.nilaikembali,this.satuan);

  RiwayatTransaksiModel.fromJson(Map<String, dynamic> json) {
    idfaktur = json['idfaktur'];
    idbarang = json['id_barang'];
    hargadetailperbarang = json['harga_detail_per_barang'];
    namabarang = json['nama_barang'];
    grandtotal = json['grandtotal'];
    gambar = json['gambar'];
    tglpenjualan = json['tgl_penjualan'];
    hargasatuan = json['harga_satuan'];
    namasatuan = json['nama_satuan'];
    satuan = json['satuan'];
    qty = json['qty'];
    nilaibayar = json['nilaibayar'];
    nilaikembali = json['nilaikembali'];
  }
}
