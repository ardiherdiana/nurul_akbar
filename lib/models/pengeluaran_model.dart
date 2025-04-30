class Pengeluaran {
  int idPengeluaran;
  int idAdmin;
  String tanggal;
  int jumlah;
  String tujuan;
  String catatan;
  String metodePembayaran; // New field

  Pengeluaran({
    required this.idPengeluaran,
    required this.idAdmin,
    required this.tanggal,
    required this.jumlah,
    required this.tujuan,
    required this.catatan,
    required this.metodePembayaran, // Added parameter
  });

  factory Pengeluaran.fromJson(Map<String, dynamic> json) {
    return Pengeluaran(
      idPengeluaran: int.tryParse(json['id_pengeluaran'].toString()) ?? 0,
      idAdmin: int.tryParse(json['id_admin'].toString()) ?? 0,
      tanggal: json['tanggal']?.toString() ?? '',
      jumlah: (double.tryParse(json['jumlah'].toString()) ?? 0).toInt(),
      tujuan: json['tujuan']?.toString() ?? '',
      catatan: json['catatan']?.toString() ?? '',
      metodePembayaran: json['metode_pembayaran']?.toString() ?? 'Cash', // New field
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pengeluaran': idPengeluaran,
      'id_admin': idAdmin,
      'tanggal': tanggal,
      'jumlah': jumlah,
      'tujuan': tujuan,
      'catatan': catatan,
      'metode_pembayaran': metodePembayaran, // New field
    };
  }
}
