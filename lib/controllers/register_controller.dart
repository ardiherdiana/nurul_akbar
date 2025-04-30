import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterController {
  final String baseUrl = "http://192.168.35.105/api_nurul_akbar";

  Future<Map<String, dynamic>> register(String namaAdmin, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register.php'),
      body: {
        "nama_admin": namaAdmin,
        "password": password,
      },
    );
    return json.decode(response.body);
  }
}
