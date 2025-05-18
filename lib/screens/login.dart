import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'beranda.dart';
import 'package:nurul_akbar/controllers/auth_controllers.dart';
import 'register.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  final AuthController _authController = AuthController();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // Cek apakah pengguna sudah login
  // Remove the duplicate _checkLoginStatus and update the original one
  Future<void> _checkLoginStatus() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      String? username = prefs.getString('username');
      String? adminId = prefs.getString('adminId');

      // Add delay to ensure proper initialization
      await Future.delayed(Duration(milliseconds: 500));

      if (isLoggedIn && username != null && adminId != null) {
        if (mounted) {  // Check if widget is still mounted
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => BerandaScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      print('Error checking login status: $e');
      // If there's an error, ensure user stays on login screen
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();  // Clear any potentially corrupted data
    }
  }

  Future<void> _saveLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('username', _usernameController.text);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => BerandaScreen()),
      (route) => false,
    );
  }

  void _handleLogin() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      _showAlert("Username dan password harus diisi");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final response = await _authController.login(
      _usernameController.text,
      _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (response["status"] == "success") {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('username', response["nama_admin"]);
      await prefs.setString('adminId', response["id_admin"].toString());
      
      _showAlert("Login berhasil!", isSuccess: true);
    } else {
      _showAlert(response["message"] ?? "Login gagal! Periksa kembali username dan kata sandi.");
    }
  }

  void _showAlert(String message, {bool isSuccess = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isSuccess ? 'Berhasil' : 'Gagal'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (isSuccess) {
                _saveLoginStatus();
              }
            },
            child: Text(
              'OK',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    padding: EdgeInsets.all(12),
                    child: Image.asset(
                      'assets/images/mosqmanage_logo.jpg',
                      width: 200,
                      height: 200,
                    ),
                  ),
                ),
                Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 32),
                TextField(
                  controller: _usernameController,
                  cursorColor: Colors.green,
                  decoration: InputDecoration(
                    hintText: 'Username',
                    hintStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                TextField(
                  controller: _passwordController,
                  cursorColor: Colors.green,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    ),
                  ),
                ),
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 56),
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Belum memiliki akun? ",
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RegisterScreen()),
                        );
                      },
                      child: Text(
                        'Daftar',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
