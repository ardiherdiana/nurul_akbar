import 'package:flutter/material.dart';
import 'package:nurul_akbar/controllers/register_controller.dart';
import 'login.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  final RegisterController _authController = RegisterController();

  void _showAlert(String message, {bool isSuccess = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isSuccess ? 'Registrasi Berhasil' : 'Registrasi Gagal'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (isSuccess) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              }
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleRegister() async {
    setState(() {
      _isLoading = true;
    });

    final response = await _authController.register(
      _usernameController.text,
      _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (response["status"] == "success") {
      _showAlert("Akun Anda telah berhasil didaftarkan.", isSuccess: true);
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
                'Register',
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
                onPressed: _isLoading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.green,
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Daftar',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                  );
                },
                child: Text(
                  'Sudah punya akun? Login',
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
