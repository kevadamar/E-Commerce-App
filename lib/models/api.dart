class BaseURL {
  static String urlBase = "http://192.168.1.4/api-global-flutter/api";
  // static String urlBase = "http://api-global-flutter.develop/api";
  static String paths = "http://192.168.1.4/api-global-flutter/uploads";
  // static String paths = "http://api-global-flutter.develop/upload";

  // get method
  static String apiBarang = '$urlBase/barang/dataBarang.php';
  static String apiListKategori = '$urlBase/kategori/listKategori.php';
  static String apiListSatuan = '$urlBase/satuan/listSatuan.php';

  // post method
  static String apiPostBarang = '$urlBase/barang/postBarang.php';
  static String apiEditBarang = '$urlBase/barang/editBarang.php';
  static String apiDeleteBarang = '$urlBase/barang/deleteBarang.php';

  static String apiPostSatuan = '$urlBase/satuan/addSatuan.php';
  static String apiEditSatuan = '$urlBase/satuan/editSatuan.php';
  static String apiDeleteSatuan = '$urlBase/satuan/deleteSatuan.php';

  static String apiPostKategori = '$urlBase/kategori/addKategori.php';
  static String apiEditKategori = '$urlBase/kategori/editKategori.php';
  static String apiDeleteKategori = '$urlBase/kategori/deleteKategori.php';

  static String apiAddCart = '$urlBase/cart/addCart.php';
  static String apiMinCart = '$urlBase/cart/minusQtyCart.php';
  static String apiCountCart = '$urlBase/cart/countCart.php?userid=';
  static String apiMinusQty = '$urlBase/cart/minusQtyCart.php';
  static String apiDetailCart = '$urlBase/cart/detailCart.php?userid=';
 
  static String apiCheckout = '$urlBase/cart/prosesCheckout.php';

  static String apiLogin = '$urlBase/login.php';

  static String apiListRiwayat = '$urlBase/riwayatTransaksi/index.php';
  static String apiDetailRiwayat = '$apiListRiwayat?';
  
}
