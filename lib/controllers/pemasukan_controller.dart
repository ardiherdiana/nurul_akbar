import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pemasukan_model.dart';

class PemasukanController {
  final String apiUrl = "http://192.168.27.105/api_nurul_akbar/pemasukan.php";

  Future<int> fetchTotalPemasukan() async {
    try {
      final response = await http.get(Uri.parse("$apiUrl?total=true"));
      print("Response Total Pemasukan: ${response.body}"); // Debugging

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return data['total'] ?? 0;
      } else {
        throw Exception("Gagal mengambil total pemasukan");
      }
    } catch (e) {
      throw Exception("Error fetchTotalPemasukan: $e");
    }
  }

  // READ: Ambil semua data pemasukan
  Future<List<Pemasukan>> fetchPemasukan() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      print("Response Fetch: \${response.body}"); // Debugging

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => Pemasukan.fromJson(item)).toList();
      } else {
        throw Exception(
            "Gagal mengambil data pemasukan. Status: \${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetchPemasukan: $e");
    }
  }

  // READ: Ambil data pemasukan dengan paginasi
  Future<List<Pemasukan>> fetchPemasukanPaginated(int limit, int offset) async {
    try {
      final response =
          await http.get(Uri.parse("$apiUrl?limit=$limit&offset=$offset"));
      print("Response Fetch Paginated: \${response.body}"); // Debugging

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => Pemasukan.fromJson(item)).toList();
      } else {
        throw Exception(
            "Gagal mengambil data paginasi. Status: \${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetchPemasukanPaginated: $e");
    }
  }

  // CREATE: Tambah pemasukan baru
  Future<bool> addPemasukan(
      int idAdmin,
      String namaDonatur,
      String tanggal,
      int jumlah,
      String jenisPemasukan,
      String metodePembayaran,
      String catatan) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "id_admin": idAdmin,
          "nama_donatur": namaDonatur,
          "tanggal": tanggal,
          "jumlah": jumlah,
          "jenis_pemasukan": jenisPemasukan,
          "metode_pembayaran": metodePembayaran,
          "catatan": catatan
        }),
      );
      print("Response Add: ${response.body}"); // Debugging
      return response.statusCode == 200;
    } catch (e) {
      throw Exception("Error addPemasukan: $e");
    }
  }

  // UPDATE: Edit pemasukan
  Future<bool> updatePemasukan(
      int idPemasukan,
      int idAdmin,
      String namaDonatur,
      String tanggal,
      int jumlah,
      String jenisPemasukan,
      String metodePembayaran,
      String catatan) async {
    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "id_pemasukan": idPemasukan,
          "id_admin": idAdmin,
          "nama_donatur": namaDonatur,
          "tanggal": tanggal,
          "jumlah": jumlah,
          "jenis_pemasukan": jenisPemasukan,
          "metode_pembayaran": metodePembayaran,
          "catatan": catatan
        }),
      );

      print("Response Update: \${response.body}"); // Debugging
      return response.statusCode == 200;
    } catch (e) {
      throw Exception("Error updatePemasukan: $e");
    }
  }

  // DELETE: Hapus pemasukan
  Future<bool> deletePemasukan(int idPemasukan) async {
    try {
      final response = await http.delete(Uri.parse(
          "$apiUrl?id_pemasukan=$idPemasukan")); // Gunakan Query Parameter untuk ID
      print("Response Delete: \${response.body}"); // Debugging
      return response.statusCode == 200;
    } catch (e) {
      throw Exception("Error deletePemasukan: $e");
    }
  }
}
