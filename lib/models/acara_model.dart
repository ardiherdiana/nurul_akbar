class Acara {
  int idAcara;
  int idAdmin;
  String namaAcara;
  String tanggal;
  String waktu;     // Added field
  String tempat;    // Added field
  String panitia;
  String catatan;

  Acara({
    required this.idAcara,
    required this.idAdmin,
    required this.namaAcara,
    required this.tanggal,
    required this.waktu,    // Added parameter
    required this.tempat,   // Added parameter
    required this.panitia,
    required this.catatan,
  });

  factory Acara.fromJson(Map<String, dynamic> json) {
    return Acara(
      idAcara: int.tryParse(json['id_acara']?.toString() ?? '') ?? 0,
      idAdmin: int.tryParse(json['id_admin']?.toString() ?? '') ?? 0,
      namaAcara: json['nama_acara']?.toString() ?? '',
      tanggal: json['tanggal']?.toString() ?? '',
      waktu: json['waktu']?.toString() ?? '',      // Added field
      tempat: json['tempat']?.toString() ?? '',    // Added field
      panitia: json['panitia']?.toString() ?? '',
      catatan: json['catatan']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_acara': idAcara,
      'id_admin': idAdmin,
      'nama_acara': namaAcara,
      'tanggal': tanggal,
      'waktu': waktu,       // Added field
      'tempat': tempat,     // Added field
      'panitia': panitia,
      'catatan': catatan,
    };
  }
}
