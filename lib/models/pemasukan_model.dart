class Pemasukan {
  int idPemasukan;
  int idAdmin;
  String nama;
  String tanggal;
  int jumlah;
  String jenisPemasukan;
  String metodePembayaran;
  String catatan;

  Pemasukan({
    required this.idPemasukan,
    required this.idAdmin,
    required this.nama,
    required this.tanggal,
    required this.jumlah,
    required this.jenisPemasukan,
    required this.metodePembayaran,
    required this.catatan,
  });

  factory Pemasukan.fromJson(Map<String, dynamic> json) {
    return Pemasukan(
      idPemasukan: int.tryParse(json['id_pemasukan'].toString()) ?? 0,
      idAdmin: int.tryParse(json['id_admin'].toString()) ?? 0,
      nama: json['nama'].toString(),
      tanggal: json['tanggal'].toString(),
      jumlah: int.tryParse(json['jumlah'].toString()) ?? 0,
      jenisPemasukan: json['jenis_pemasukan'].toString(),
      metodePembayaran: json['metode_pembayaran'].toString(),
      catatan: json['catatan'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pemasukan': idPemasukan,
      'id_admin': idAdmin,
      'nama': nama,
      'tanggal': tanggal,
      'jumlah': jumlah,
      'jenis_pemasukan': jenisPemasukan,
      'metode_pembayaran': metodePembayaran,
      'catatan': catatan,
    };
  }
}
