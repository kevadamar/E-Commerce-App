class KategoriModel {
  String id;
  String namaKategori;

  KategoriModel(this.id, this.namaKategori);

  KategoriModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    namaKategori = json['nama_kategori'];
  }
}
