import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  bool _isDemoAccount = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue[900]!,
              Colors.blue[600]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // العنوان
                        Text(
                          _isLogin ? 'تسجيل الدخول' : 'إنشاء حساب',
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 32),

                        // حقل البريد الإلكتروني
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'البريد الإلكتروني',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال البريد الإلكتروني';
                            }
                            if (!value.contains('@')) {
                              return 'الرجاء إدخال بريد إلكتروني صحيح';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),

                        // حقل كلمة المرور
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'كلمة المرور',
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال كلمة المرور';
                            }
                            if (value.length < 6) {
                              return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 24),

                        // زر تبديل نوع الحساب
                        if (_isLogin)
                          SwitchListTile(
                            title: Text('حساب تجريبي'),
                            value: _isDemoAccount,
                            onChanged: (value) {
                              setState(() {
                                _isDemoAccount = value;
                              });
                            },
                          ),
                        SizedBox(height: 24),

                        // زر تسجيل الدخول/إنشاء حساب
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitForm,
                            child: _isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    _isLogin ? 'تسجيل الدخول' : 'إنشاء حساب',
                                    style: TextStyle(fontSize: 18),
                                  ),
                          ),
                        ),
                        SizedBox(height: 16),

                        // زر تبديل بين تسجيل الدخول وإنشاء حساب
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isLogin = !_isLogin;
                            });
                          },
                          child: Text(
                            _isLogin
                                ? 'ليس لديك حساب؟ إنشاء حساب جديد'
                                : 'لديك حساب بالفعل؟ تسجيل الدخول',
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
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      bool success;

      if (_isLogin) {
        success = await authProvider.login(
          _emailController.text,
          _passwordController.text,
          _isDemoAccount,
        );
      } else {
        success = await authProvider.register(
          _emailController.text,
          _passwordController.text,
        );
      }

      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
