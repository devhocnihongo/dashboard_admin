import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginPage({Key? key, required this.onLoginSuccess}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _errorMessage;

  final String adminUsername = "admin";
  final String adminPassword = "admin123";

  void _login() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username == adminUsername && password == adminPassword) {
      widget.onLoginSuccess();
    } else {
      setState(() {
        _errorMessage = "Tài khoản hoặc mật khẩu không đúng!";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          elevation: 8,
          margin: const EdgeInsets.symmetric(horizontal: 40),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: SizedBox(
              width: 350,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Đăng nhập Admin",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(labelText: "Tài khoản"),
                      validator: (value) =>
                      value == null || value.isEmpty ? "Nhập tài khoản" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: "Mật khẩu"),
                      obscureText: true,
                      validator: (value) =>
                      value == null || value.isEmpty ? "Nhập mật khẩu" : null,
                    ),
                    const SizedBox(height: 16),
                    if (_errorMessage != null)
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _login();
                          }
                        },
                        child: const Text("Đăng nhập"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}