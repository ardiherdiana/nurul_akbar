import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthController {
  final String baseUrl = "http://192.168.132.105/api_nurul_akbar";

  Future<bool> checkServerConnection() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health_check.php'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> login(String namaAdmin, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login.php'),
      body: {"nama_admin": namaAdmin, "password": password},
    );
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> register(
    String namaAdmin,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin_register.php'),
      body: {"nama_admin": namaAdmin, "password": password},
    );
    return json.decode(response.body);
  }
}