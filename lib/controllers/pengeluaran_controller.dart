import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pengeluaran_model.dart';

class PengeluaranController {
  final String apiUrl = "http://192.168.27.105/api_nurul_akbar/pengeluaran.php";

  Future<int> fetchTotalPengeluaran() async {
    try {
      final response = await http.get(Uri.parse("$apiUrl?total=true"));
      print("Response Total Pengeluaran: ${response.body}"); // Debugging

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return data['total'] ?? 0;
      } else {
        throw Exception("Gagal mengambil total pengeluaran");
      }
    } catch (e) {
      throw Exception("Error fetchTotalPengeluaran: $e");
    }
  }

  // READ: Ambil semua data pengeluaran
  Future<List<Pengeluaran>> fetchPengeluaran() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      print("Response Fetch: ${response.body}"); // Debugging

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => Pengeluaran.fromJson(item)).toList();
      } else {
        throw Exception(
            "Gagal mengambil data pengeluaran. Status: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetchPengeluaran: $e");
    }
  }

  // READ: Ambil data pengeluaran dengan paginasi
  Future<List<Pengeluaran>> fetchPengeluaranPaginated(
      int limit, int offset) async {
    try {
      final response =
          await http.get(Uri.parse("$apiUrl?limit=$limit&offset=$offset"));
      print("Response Fetch Paginated: ${response.body}"); // Debugging

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => Pengeluaran.fromJson(item)).toList();
      } else {
        throw Exception(
            "Gagal mengambil data paginasi. Status: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetchPengeluaranPaginated: $e");
    }
  }

  // CREATE: Tambah pengeluaran baru
  Future<bool> addPengeluaran(int idAdmin, String tanggal, int jumlah,
      String tujuan, String metodePembayaran, String catatan) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "id_admin": idAdmin,
          "tanggal": tanggal,
          "jumlah": jumlah,
          "tujuan": tujuan,
          "metode_pembayaran": metodePembayaran,
          "catatan": catatan
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception("Error addPengeluaran: $e");
    }
  }

  // UPDATE: Edit pengeluaran
  Future<bool> updatePengeluaran(
      int idPengeluaran,
      int idAdmin,
      String tanggal,
      int jumlah,
      String tujuan,
      String metodePembayaran,
      String catatan) async {
    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "id_pengeluaran": idPengeluaran,
          "id_admin": idAdmin,
          "tanggal": tanggal,
          "jumlah": jumlah,
          "tujuan": tujuan,
          "metode_pembayaran": metodePembayaran,
          "catatan": catatan
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception("Error updatePengeluaran: $e");
    }
  }

  // DELETE: Hapus pengeluaran
  Future<bool> deletePengeluaran(int idPengeluaran) async {
    try {
      final response = await http.delete(Uri.parse(
          "$apiUrl?id_pengeluaran=$idPengeluaran")); // Gunakan Query Parameter untuk ID
      print("Response Delete: ${response.body}"); // Debugging
      return response.statusCode == 200;
    } catch (e) {
      throw Exception("Error deletePengeluaran: $e");
    }
  }
}
