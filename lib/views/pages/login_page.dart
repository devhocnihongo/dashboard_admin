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

  // keep the simple admin credentials that existed before
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
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // responsive breakpoint: show two-pane layout on wide screens
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWide = constraints.maxWidth >= 900;
          if (isWide) {
            return Row(
              children: [
                // Left: illustration / marketing image (now using asset)
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(48.0),
                        child: FractionallySizedBox(
                          widthFactor: 0.85,
                          child: AspectRatio(
                            aspectRatio: 7 / 4,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                color: Colors.transparent,
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => Center(
                                    child: Icon(Icons.image, size: 80, color: Colors.grey.shade300),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Right: login form
                Expanded(
                  child: Container(
                    color: Colors.white10,
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(28.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Opacity(
                                      opacity: 0.6,
                                      child: Text(
                                        'Powered by Nhom 5',
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Agrimarket - Login',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Continue to Admin Dashboard',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 14, color: Colors.black54),
                                  ),
                                  const SizedBox(height: 20),
                                  Form(
                                    key: _formKey,
                                    child: Column(
                                      children: [
                                        TextFormField(
                                          controller: _usernameController,
                                          decoration: InputDecoration(
                                            hintText: 'Username',
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            filled: true,
                                            fillColor: Colors.white,
                                          ),
                                          validator: (v) => v == null || v.trim().isEmpty ? "Bắt buộc nhập tài khoản" : null,
                                        ),
                                        const SizedBox(height: 12),
                                        TextFormField(
                                          controller: _passwordController,
                                          decoration: InputDecoration(
                                            hintText: 'Password',
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            filled: true,
                                            fillColor: Colors.white,
                                          ),
                                          obscureText: true,
                                          validator: (v) => v == null || v.isEmpty ? "Nhập mật khẩu" : null,
                                        ),
                                        if (_errorMessage != null)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 6),
                                            child: Text(
                                              _errorMessage!,
                                              style: const TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        const SizedBox(height: 8),
                                        SizedBox(
                                          width: double.infinity,
                                          height: 46,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              if (_formKey.currentState!.validate()) {
                                                _login();
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blueAccent,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            child: const Text('Login', style: TextStyle(fontSize: 16)),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'This site is protected by reCAPTCHA and the Google Privacy Policy and Terms of Service apply.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            // Narrow: single column, show form above image (mobile-friendly)
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 220,
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 80),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Column(
                            children: [
                              const Text('Agrimarket - Login', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: _usernameController,
                                      decoration: InputDecoration(hintText: 'Username', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                                      validator: (v) => v == null || v.trim().isEmpty ? "Bắt buộc nhập tài khoản" : null,
                                    ),
                                    const SizedBox(height: 10),
                                    TextFormField(
                                      controller: _passwordController,
                                      decoration: InputDecoration(hintText: 'Password', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                                      obscureText: true,
                                      validator: (v) => v == null || v.isEmpty ? "Nhập mật khẩu" : null,
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          if (_formKey.currentState!.validate()) _login();
                                        },
                                        child: const Text('Login'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}