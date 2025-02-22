import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({Key? key}) : super(key: key);

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _apiKeyController = TextEditingController();
  final _secretKeyController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _apiKeyController.dispose();
    _secretKeyController.dispose();
    super.dispose();
  }

  Future<void> _updateApiKeys() async {
    if (_apiKeyController.text.isEmpty || _secretKeyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال جميع البيانات المطلوبة')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.updateBinanceApiKeys(
        apiKey: _apiKeyController.text,
        secretKey: _secretKeyController.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث مفاتيح API بنجاح')),
      );
      
      // تنظيف الحقول
      _apiKeyController.clear();
      _secretKeyController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _switchAccountType(AccountType type) async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.switchAccountType(type);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            type == AccountType.demo
                ? 'تم التحويل إلى الحساب التجريبي'
                : 'تم التحويل إلى الحساب الحقيقي',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات الحساب'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final isLiveAccount = authProvider.accountType == AccountType.live;
          final hasApiKeys = authProvider.currentUser?.binanceApiKey != null;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // نوع الحساب
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'نوع الحساب',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading || !isLiveAccount
                                  ? null
                                  : () => _switchAccountType(AccountType.demo),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: !isLiveAccount
                                    ? Theme.of(context).primaryColor
                                    : null,
                              ),
                              child: const Text('حساب تجريبي'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading || isLiveAccount || !hasApiKeys
                                  ? null
                                  : () => _switchAccountType(AccountType.live),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isLiveAccount
                                    ? Theme.of(context).primaryColor
                                    : null,
                              ),
                              child: const Text('حساب حقيقي'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // إعدادات API باينانس
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'إعدادات API باينانس',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _apiKeyController,
                        decoration: const InputDecoration(
                          labelText: 'API Key',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _secretKeyController,
                        decoration: const InputDecoration(
                          labelText: 'Secret Key',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _updateApiKeys,
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : const Text('حفظ مفاتيح API'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // معلومات الحساب
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'معلومات الحساب',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        title: const Text('نوع الحساب الحالي'),
                        subtitle: Text(
                          isLiveAccount ? 'حساب حقيقي' : 'حساب تجريبي',
                          style: TextStyle(
                            color: isLiveAccount
                                ? Colors.green
                                : Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (!isLiveAccount) ...[
                        ListTile(
                          title: const Text('الرصيد التجريبي'),
                          subtitle: Text(
                            '\$${authProvider.currentUser?.demoBalance.toStringAsFixed(2) ?? '0.00'}',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      ListTile(
                        title: const Text('حالة API باينانس'),
                        subtitle: Text(
                          hasApiKeys ? 'متصل' : 'غير متصل',
                          style: TextStyle(
                            color: hasApiKeys ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
