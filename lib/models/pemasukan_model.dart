class Pemasukan {
  int idPemasukan;
  int idAdmin;
  String namaDonatur;
  String tanggal;
  int jumlah;
  String jenisPemasukan;
  String metodePembayaran;
  String catatan;

  Pemasukan({
    required this.idPemasukan,
    required this.idAdmin,
    required this.namaDonatur,
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
      namaDonatur: json['nama_donatur']?.toString() ?? '',
      tanggal: json['tanggal']?.toString() ?? '',
      jumlah: (double.tryParse(json['jumlah'].toString()) ?? 0).toInt(),
      jenisPemasukan: json['jenis_pemasukan']?.toString() ?? '',
      metodePembayaran: json['metode_pembayaran']?.toString() ?? '',
      catatan: json['catatan']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pemasukan': idPemasukan,
      'id_admin': idAdmin,
      'nama_donatur': namaDonatur,  // Changed from namaDonatur
      'tanggal': tanggal,
      'jumlah': jumlah,
      'jenis_pemasukan': jenisPemasukan,
      'metode_pembayaran': metodePembayaran,
      'catatan': catatan,
    };
  }
}
