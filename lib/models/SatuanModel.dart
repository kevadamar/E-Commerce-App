class SatuanModel {
  String id;
  String namaSatuan;
  String satuan;

  SatuanModel(this.id, this.namaSatuan, this.satuan);

  SatuanModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    namaSatuan = json['nama_satuan'];
    satuan = json['satuan'];
  }
}
