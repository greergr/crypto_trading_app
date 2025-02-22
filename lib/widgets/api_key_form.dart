import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class APIKeyForm extends StatefulWidget {
  @override
  _APIKeyFormState createState() => _APIKeyFormState();
}

class _APIKeyFormState extends State<APIKeyForm> {
  bool _obscureSecret = true;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Form(
          key: _formKey,
          child: Column(
            children: [
              // API Key
              TextFormField(
                initialValue: auth.apiKey,
                decoration: InputDecoration(
                  labelText: 'API Key',
                  helperText: 'مفتاح API من منصة التداول',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال مفتاح API';
                  }
                  return null;
                },
                onChanged: (value) {
                  auth.setApiKey(value);
                },
              ),
              SizedBox(height: 16),

              // API Secret
              TextFormField(
                initialValue: auth.apiSecret,
                obscureText: _obscureSecret,
                decoration: InputDecoration(
                  labelText: 'API Secret',
                  helperText: 'كلمة السر الخاصة بمفتاح API',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureSecret ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureSecret = !_obscureSecret;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال كلمة السر';
                  }
                  return null;
                },
                onChanged: (value) {
                  auth.setApiSecret(value);
                },
              ),
              SizedBox(height: 16),

              // زر الحفظ
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    auth.saveApiCredentials().then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('تم حفظ إعدادات API بنجاح'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }).catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('حدث خطأ أثناء حفظ الإعدادات'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    });
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text('حفظ إعدادات API'),
                  ),
                ),
              ),

              // معلومات إضافية
              SizedBox(height: 16),
              Text(
                'ملاحظة: مفاتيح API مطلوبة فقط للحساب الحقيقي. '
                'تأكد من تفعيل صلاحيات التداول في إعدادات API على منصة التداول.',
                style: Theme.of(context).textTheme.caption,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
