import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/pengurus_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class PengurusController {
  final String apiUrl = kIsWeb
      ? "http://192.168.27.105/api_nurul_akbar/pengurus.php"
      : "http://192.168.27.105/api_nurul_akbar/pengurus.php";

  Future<List<Pengurus>> fetchPengurus() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => Pengurus.fromJson(item)).toList();
      } else {
        throw Exception("Failed to fetch data");
      }
    } catch (e) {
      throw Exception("Error fetchPengurus: $e");
    }
  }

  // CREATE: Add new pengurus
  Future<bool> addPengurus(int idAdmin, dynamic imageData, String namaPengurus,
      String jabatan, String jobdesk, String catatan) async {
    try {
      // Prepare request body
      Map<String, dynamic> requestBody = {
        "action": "add",
        "id_admin": idAdmin,
        "nama_pengurus": namaPengurus,
        "jabatan": jabatan,
        "jobdesk": jobdesk,
        "catatan": catatan
      };

      // Handle image data if provided
      if (imageData != null) {
        String base64Image = '';
        if (imageData is Map<String, dynamic>) {
          base64Image = imageData['data'];
          // Clean up base64 data if needed
          if (base64Image.contains(',')) {
            base64Image = base64Image.split(',').last;
          }
        } else if (imageData is File) {
          List<int> imageBytes = await imageData.readAsBytes();
          base64Image = base64Encode(imageBytes);
        }
        
        // Add the image data to the request body
        requestBody["foto_pengurus"] = base64Image;
      } else {
        // Ensure foto_pengurus is included even if it's empty
        requestBody["foto_pengurus"] = "";
      }

      print("Sending request: ${json.encode(requestBody)}");

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestBody),
      );

      print("Response Add: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data.containsKey('message');
      }
      return false;
    } catch (e) {
      print("Error in addPengurus: $e");
      throw Exception("Error addPengurus: $e");
    }
  }

  // UPDATE: Edit pengurus
  Future<bool> updatePengurus(
      int idPengurus,
      int idAdmin,
      dynamic imageData,
      String currentImageUrl,
      String namaPengurus,
      String jabatan,
      String jobdesk,
      String catatan) async {
    try {
      // Start with the current image
      String imageToUse = currentImageUrl;

      // If new image data is provided, process it
      if (imageData != null) {
        if (imageData is Map<String, dynamic>) {
          String base64Image = imageData['data'];
          if (base64Image.contains(',')) {
            base64Image = base64Image.split(',').last;
          }
          imageToUse = base64Image;
        } else if (imageData is File) {
          List<int> imageBytes = await imageData.readAsBytes();
          imageToUse = base64Encode(imageBytes);
        }
      }

      Map<String, dynamic> requestBody = {
        "action": "update",
        "id_pengurus": idPengurus,
        "id_admin": idAdmin,
        "foto_pengurus": imageToUse,
        "nama_pengurus": namaPengurus,
        "jabatan": jabatan,
        "jobdesk": jobdesk,
        "catatan": catatan
      };

      print("Updating with data: ${json.encode(requestBody)}");

      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestBody),
      );

      print("Response Update: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data.containsKey('message');
      }
      return false;
    } catch (e) {
      print("Error in updatePengurus: $e");
      throw Exception("Error updatePengurus: $e");
    }
  }

  // DELETE: Delete pengurus
  Future<bool> deletePengurus(int idPengurus) async {
    try {
      final response = await http.delete(
        Uri.parse("$apiUrl?id_pengurus=$idPengurus")
      );
      
      print("Response Delete: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data.containsKey('message');
      }
      return false;
    } catch (e) {
      print("Error in deletePengurus: $e");
      throw Exception("Error deletePengurus: $e");
    }
  }
}