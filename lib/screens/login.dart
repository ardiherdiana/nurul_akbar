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
  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BerandaScreen()),
      );
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
                _saveLoginStatus(); // Simpan status login
              }
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => BerandaScreen()),
    );
  }

  void _handleLogin() async {
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
      _showAlert("Login berhasil!", isSuccess: true);
    } else {
      _showAlert(response["message"]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Login',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 32),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(color: Colors.green),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green, width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Kata Sandi',
                  labelStyle: TextStyle(color: Colors.green),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green, width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.green,
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Login',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  );
                },
                child: Text(
                  'Belum punya akun? Daftar',
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
