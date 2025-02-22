import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/providers/auth_provider.dart';
import 'package:crypto_trading_app/screens/login_screen.dart';
import 'package:local_auth/local_auth.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _useBiometric = false;
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (canCheckBiometrics) {
        final availableBiometrics = await _localAuth.getAvailableBiometrics();
        setState(() {
          _useBiometric = availableBiometrics.isNotEmpty;
        });
      }
    } catch (e) {
      print('Error checking biometrics: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'إنشاء حساب جديد',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'الاسم الكامل',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'الرجاء إدخال الاسم الكامل';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'الرجاء إدخال البريد الإلكتروني';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                      return 'الرجاء إدخال بريد إلكتروني صحيح';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'كلمة المرور',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'الرجاء إدخال كلمة المرور';
                    }
                    if (value!.length < 8) {
                      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'تأكيد كلمة المرور',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'كلمات المرور غير متطابقة';
                    }
                    return null;
                  },
                ),
                if (_useBiometric) ...[
                  const SizedBox(height: 20),
                  SwitchListTile(
                    title: const Text('تفعيل المصادقة البيومترية'),
                    subtitle: const Text('استخدم بصمة الإصبع أو بصمة الوجه لتسجيل الدخول'),
                    value: _useBiometric,
                    onChanged: (bool value) {
                      setState(() {
                        _useBiometric = value;
                      });
                    },
                  ),
                ],
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _handleSignup,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Text(
                    'إنشاء حساب',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  child: const Text('لديك حساب بالفعل؟ تسجيل الدخول'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignup() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.signup(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        useBiometric: _useBiometric,
      );

      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}
