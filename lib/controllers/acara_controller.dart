import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/acara_model.dart';

class AcaraController {
  final String apiUrl =
      "http://192.168.132.105/api_nurul_akbar/acara.php"; // Sesuaikan dengan API

  // READ: Ambil semua data acara
  Future<List<Acara>> fetchAcara() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      print("Response Fetch: \${response.body}"); // Debugging

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => Acara.fromJson(item)).toList();
      } else {
        throw Exception(
            "Gagal mengambil data acara. Status: \${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetchAcara: $e");
    }
  }

  // CREATE: Tambah acara baru
  Future<bool> addAcara(int idAdmin, String namaAcara, String tanggal,
      String panitia, String catatan) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "id_admin": idAdmin,
          "nama_acara": namaAcara,
          "tanggal": tanggal,
          "panitia": panitia,
          "catatan": catatan
        }),
      );
      print("Response Add: \${response.body}"); // Debugging

      if (response.statusCode == 200) {
        Map<String, dynamic> result = json.decode(response.body);
        return result['success'] == true;
      }
      return false;
    } catch (e) {
      throw Exception("Error addAcara: $e");
    }
  }

  // UPDATE: Edit acara
  Future<bool> updateAcara(int idAcara, int idAdmin, String namaAcara,
      String tanggal, String panitia, String catatan) async {
    try {
      final response = await http.put(
        Uri.parse("$apiUrl?id_acara=$idAcara"), // Pastikan API menangani ini
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "id_admin": idAdmin,
          "nama_acara": namaAcara,
          "tanggal": tanggal,
          "panitia": panitia,
          "catatan": catatan
        }),
      );

      print("Response Update: \${response.body}"); // Debugging

      if (response.statusCode == 200) {
        Map<String, dynamic> result = json.decode(response.body);
        return result['success'] == true;
      }
      return false;
    } catch (e) {
      throw Exception("Error updateAcara: $e");
    }
  }

  // DELETE: Hapus acara
  Future<bool> deleteAcara(int idAcara) async {
    try {
      final response = await http.delete(Uri.parse("$apiUrl?id_acara=$idAcara"));
      print("Response Delete: \${response.body}"); // Debugging

      if (response.statusCode == 200) {
        Map<String, dynamic> result = json.decode(response.body);
        return result['success'] == true;
      }
      return false;
    } catch (e) {
      throw Exception("Error deleteAcara: $e");
    }
  }
}
