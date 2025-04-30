class Pengurus {
  final int idPengurus;
  final int idAdmin;
  final String fotoPengurus;  // Will store base64 string of the image
  final String namaPengurus;
  final String jabatan;
  final String jobdesk;
  final String catatan;

  Pengurus({
    required this.idPengurus,
    required this.idAdmin,
    required this.fotoPengurus,
    required this.namaPengurus,
    required this.jabatan,
    required this.jobdesk,
    required this.catatan,
  });

  factory Pengurus.fromJson(Map<String, dynamic> json) {
    return Pengurus(
      idPengurus: json['id_pengurus'] is String 
          ? int.parse(json['id_pengurus']) 
          : json['id_pengurus'] ?? 0,
      idAdmin: json['id_admin'] is String 
          ? int.parse(json['id_admin']) 
          : json['id_admin'] ?? 0,
      fotoPengurus: json['foto_pengurus']?.toString() ?? '',
      namaPengurus: json['nama_pengurus'] ?? '',
      jabatan: json['jabatan'] ?? '',
      jobdesk: json['jobdesk'] ?? '',
      catatan: json['catatan'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pengurus': idPengurus,
      'id_admin': idAdmin,
      'foto_pengurus': fotoPengurus,
      'nama_pengurus': namaPengurus,
      'jabatan': jabatan,
      'jobdesk': jobdesk,
      'catatan': catatan,
    };
  }
}