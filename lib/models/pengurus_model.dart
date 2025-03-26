class Pengurus {
  int idPengurus;
  int idAdmin;
  String namaPengurus;
  String jabatan;
  String jobdesk;
  String catatan;

  Pengurus({
    required this.idPengurus,
    required this.idAdmin,
    required this.namaPengurus,
    required this.jabatan,
    required this.jobdesk,
    required this.catatan,
  });

  factory Pengurus.fromJson(Map<String, dynamic> json) {
    return Pengurus(
      idPengurus: int.tryParse(json['id_pengurus'].toString()) ?? 0,
      idAdmin: int.tryParse(json['id_admin'].toString()) ?? 0,
      namaPengurus: json['nama_pengurus'].toString(),
      jabatan: json['jabatan'].toString(),
      jobdesk: json['jobdesk'].toString(),
      catatan: json['catatan'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pengurus': idPengurus,
      'id_admin': idAdmin,
      'nama_pengurus': namaPengurus,
      'jabatan': jabatan,
      'jobdesk': jobdesk,
      'catatan': catatan,
    };
  }
}
