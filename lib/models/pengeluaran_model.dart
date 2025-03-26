class Pengeluaran {
  int idPengeluaran;
  int idAdmin;
  String tanggal;
  int jumlah;
  String tujuan;
  String catatan;

  Pengeluaran({
    required this.idPengeluaran,
    required this.idAdmin,
    required this.tanggal,
    required this.jumlah,
    required this.tujuan,
    required this.catatan,
  });

  factory Pengeluaran.fromJson(Map<String, dynamic> json) {
    return Pengeluaran(
      idPengeluaran: int.tryParse(json['id_pengeluaran'].toString()) ?? 0,
      idAdmin: int.tryParse(json['id_admin'].toString()) ?? 0,
      tanggal: json['tanggal'].toString(),
      jumlah: int.tryParse(json['jumlah'].toString()) ?? 0,
      tujuan: json['tujuan'].toString(),
      catatan: json['catatan'].toString(),
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
    };
  }
}
