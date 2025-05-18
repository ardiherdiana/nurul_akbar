import 'package:http/http.dart' as http;
import 'dart:convert';

class AcaraController {
  final String baseUrl = 'http://192.168.27.105/api_nurul_akbar';

  Future<List<Map<String, dynamic>>> getAcara() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/acara.php'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return List<Map<String, dynamic>>.from(jsonData);
      } else {
        throw Exception('Failed to load acara: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<bool> addAcara(
    int adminId,
    String namaAcara,
    String tanggal,
    String waktu,
    String tempat,
    String panitia,
    String catatan,
    String? fotoAcara,  // Added parameter
  ) async {
    try {
      final Map<String, dynamic> data = {
        'id_admin': adminId,
        'nama_acara': namaAcara,
        'tanggal': tanggal,
        'waktu': waktu,
        'tempat': tempat, 
        'panitia': panitia,
        'catatan': catatan,
        'foto_acara': fotoAcara,  // Added field
      };
      
      final response = await http.post(
        Uri.parse('$baseUrl/acara.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error in addAcara: $e');
      throw Exception('Failed to add acara: $e');
    }
  }

   Future<bool> updateAcara(
    int idAcara,
    int adminId,
    String namaAcara,
    String tanggal,
    String waktu,
    String tempat,
    String panitia,
    String catatan,
    String? fotoAcara,  // Added parameter
  ) async {
    try {
      final Map<String, dynamic> data = {
        'id_acara': idAcara,
        'id_admin': adminId,
        'nama_acara': namaAcara,
        'tanggal': tanggal,
        'waktu': waktu,
        'tempat': tempat,
        'panitia': panitia,
        'catatan': catatan,
        'foto_acara': fotoAcara,  // Added field
      };
      
      final response = await http.put(
        Uri.parse('$baseUrl/acara.php/$idAcara'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['success'] ?? false;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to update acara: $e');
    }
  }

  Future<bool> deleteAcara(int idAcara) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/acara.php/$idAcara'),
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['success'] ?? false;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to delete acara: $e');
    }
  }
}
