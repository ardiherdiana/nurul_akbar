class Acara {
  int idAcara;
  int idAdmin;
  String? fotoAcara;  // Added field
  String namaAcara;
  String tanggal;
  String waktu;
  String tempat;
  String panitia;
  String catatan;

  Acara({
    required this.idAcara,
    required this.idAdmin,
    this.fotoAcara,    // Added optional parameter
    required this.namaAcara,
    required this.tanggal,
    required this.waktu,
    required this.tempat,
    required this.panitia,
    required this.catatan,
  });

  factory Acara.fromJson(Map<String, dynamic> json) {
    return Acara(
      idAcara: int.tryParse(json['id_acara']?.toString() ?? '') ?? 0,
      idAdmin: int.tryParse(json['id_admin']?.toString() ?? '') ?? 0,
      fotoAcara: json['foto_acara']?.toString(),  // Added field
      namaAcara: json['nama_acara']?.toString() ?? '',
      tanggal: json['tanggal']?.toString() ?? '',
      waktu: json['waktu']?.toString() ?? '',
      tempat: json['tempat']?.toString() ?? '',
      panitia: json['panitia']?.toString() ?? '',
      catatan: json['catatan']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_acara': idAcara,
      'id_admin': idAdmin,
      'foto_acara': fotoAcara,  // Added field
      'nama_acara': namaAcara,
      'tanggal': tanggal,
      'waktu': waktu,
      'tempat': tempat,
      'panitia': panitia,
      'catatan': catatan,
    };
  }
}
