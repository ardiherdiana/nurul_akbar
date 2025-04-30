import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/admin_model.dart';

class AdminController extends GetxController {
  final String baseUrl = "http://192.168.35.105/api_nurul_akbar";
  var isLoading = false.obs;
  var admin = Rx<Admin?>(null);

  Future<bool> checkServerConnection() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health_check.php'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      isLoading(true);
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        body: {
          "username": username,
          "password": password,
        },
      );
      
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
          admin.value = Admin.fromJson(jsonResponse['data']);
        }
        return jsonResponse;
      } else {
        return {
          "status": "error",
          "message": "Server error: ${response.statusCode}",
        };
      }
    } catch (e) {
      return {
        "status": "error",
        "message": "Connection error: $e",
      };
    } finally {
      isLoading(false);
    }
  }

  Future<Map<String, dynamic>> register(String namaAdmin, String password) async {
    try {
      isLoading(true);
      final response = await http.post(
        Uri.parse('$baseUrl/admin_register.php'),
        body: {
          "nama_admin": namaAdmin,
          "password": password,
        },
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          "status": "error",
          "message": "Server error: ${response.statusCode}",
        };
      }
    } catch (e) {
      return {
        "status": "error",
        "message": "Connection error: $e",
      };
    } finally {
      isLoading(false);
    }
  }

  void logout() {
    admin.value = null;
  }
}