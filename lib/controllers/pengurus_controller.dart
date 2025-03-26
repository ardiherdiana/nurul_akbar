import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pengurus_model.dart';

class PengurusController {
  final String apiUrl = "http://192.168.132.105/api_nurul_akbar/pengurus.php"; // Sesuaikan dengan API

  // READ: Ambil semua data pengurus
  Future<List<Pengurus>> fetchPengurus() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      print("Response Fetch: \${response.body}"); // Debugging

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => Pengurus.fromJson(item)).toList();
      } else {
        throw Exception("Gagal mengambil data pengurus. Status: \${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetchPengurus: $e");
    }
  }

  // CREATE: Tambah pengurus baru
  Future<bool> addPengurus(int idAdmin, String namaPengurus, String jabatan, String jobdesk, String catatan) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "id_admin": idAdmin,
          "nama_pengurus": namaPengurus,
          "jabatan": jabatan,
          "jobdesk": jobdesk,
          "catatan": catatan
        }),
      );
      print("Response Add: \${response.body}"); // Debugging
      return response.statusCode == 200;
    } catch (e) {
      throw Exception("Error addPengurus: $e");
    }
  }

  // UPDATE: Edit pengurus
  Future<bool> updatePengurus(int idPengurus, int idAdmin, String namaPengurus, String jabatan, String jobdesk, String catatan) async {
    try {
      final response = await http.put(
        Uri.parse(apiUrl), // API membaca dari body, bukan URL
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "id_pengurus": idPengurus,
          "id_admin": idAdmin,
          "nama_pengurus": namaPengurus,
          "jabatan": jabatan,
          "jobdesk": jobdesk,
          "catatan": catatan
        }),
      );

      print("Response Update: \${response.body}"); // Debugging
      return response.statusCode == 200;
    } catch (e) {
      throw Exception("Error updatePengurus: $e");
    }
  }

  // DELETE: Hapus pengurus
  Future<bool> deletePengurus(int idPengurus) async {
    try {
      final response = await http.delete(Uri.parse("$apiUrl?id_pengurus=$idPengurus")); // Gunakan Query Parameter untuk ID
      print("Response Delete: \${response.body}"); // Debugging
      return response.statusCode == 200;
    } catch (e) {
      throw Exception("Error deletePengurus: $e");
    }
  }
}