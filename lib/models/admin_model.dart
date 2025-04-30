class Admin {
  int idAdmin;
  String fotoAdmin;
  String namaAdmin;
  String password;
  String jabatan;

  Admin({
    required this.idAdmin,
    required this.fotoAdmin,
    required this.namaAdmin,
    required this.password,
    required this.jabatan,
  });

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      idAdmin: int.tryParse(json['id_admin']?.toString() ?? '') ?? 0,
      fotoAdmin: json['foto_admin']?.toString() ?? '',
      namaAdmin: json['nama_admin']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      jabatan: json['jabatan']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_admin': idAdmin,
      'foto_admin': fotoAdmin,
      'nama_admin': namaAdmin,
      'password': password,
      'jabatan': jabatan,
    };
  }
}