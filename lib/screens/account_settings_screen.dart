import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';

class AccountSettingsScreen extends StatefulWidget {
  @override
  _AccountSettingsScreenState createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiKeyController = TextEditingController();
  final _apiSecretController = TextEditingController();
  final _demoBalanceController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      _apiKeyController.text = user.apiKey ?? '';
      _apiSecretController.text = user.apiSecret ?? '';
      _demoBalanceController.text = user.demoBalance.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إعدادات الحساب'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.currentUser;
          if (user == null) return Center(child: Text('لم يتم تسجيل الدخول'));

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // نوع الحساب
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'نوع الحساب',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          SizedBox(height: 16),
                          SegmentedButton<AccountType>(
                            segments: [
                              ButtonSegment(
                                value: AccountType.demo,
                                label: Text('حساب تجريبي'),
                                icon: Icon(Icons.school),
                              ),
                              ButtonSegment(
                                value: AccountType.real,
                                label: Text('حساب حقيقي'),
                                icon: Icon(Icons.account_balance),
                              ),
                            ],
                            selected: {user.accountType},
                            onSelectionChanged: (Set<AccountType> selected) {
                              if (selected.isNotEmpty) {
                                user.switchAccountType(selected.first);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // إعدادات الحساب التجريبي
                  if (user.accountType == AccountType.demo)
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'إعدادات الحساب التجريبي',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _demoBalanceController,
                              decoration: InputDecoration(
                                labelText: 'رأس المال التجريبي',
                                prefixIcon: Icon(Icons.attach_money),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء إدخال رأس المال';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'الرجاء إدخال رقم صحيح';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                  // إعدادات API
                  if (user.accountType == AccountType.real)
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'إعدادات API',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _apiKeyController,
                              decoration: InputDecoration(
                                labelText: 'مفتاح API',
                                prefixIcon: Icon(Icons.key),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (user.accountType == AccountType.real &&
                                    (value == null || value.isEmpty)) {
                                  return 'مفتاح API مطلوب للحساب الحقيقي';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _apiSecretController,
                              decoration: InputDecoration(
                                labelText: 'كلمة سر API',
                                prefixIcon: Icon(Icons.security),
                                border: OutlineInputBorder(),
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (user.accountType == AccountType.real &&
                                    (value == null || value.isEmpty)) {
                                  return 'كلمة سر API مطلوبة للحساب الحقيقي';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  SizedBox(height: 24),

                  // زر الحفظ
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveSettings,
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'حفظ الإعدادات',
                              style: TextStyle(fontSize: 18),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.currentUser;
      
      if (user != null) {
        if (user.accountType == AccountType.demo) {
          // تحديث رصيد الحساب التجريبي
          user.updateDemoBalance(double.parse(_demoBalanceController.text));
        } else {
          // تحديث بيانات API
          await authProvider.updateApiCredentials(
            _apiKeyController.text,
            _apiSecretController.text,
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم حفظ الإعدادات بنجاح')),
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
    _apiKeyController.dispose();
    _apiSecretController.dispose();
    _demoBalanceController.dispose();
    super.dispose();
  }
}
