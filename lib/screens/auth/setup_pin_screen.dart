import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/pin_input.dart';

class SetupPinScreen extends StatefulWidget {
  const SetupPinScreen({Key? key}) : super(key: key);

  @override
  State<SetupPinScreen> createState() => _SetupPinScreenState();
}

class _SetupPinScreenState extends State<SetupPinScreen> {
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  bool _isFirstPinSet = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _setupPin() async {
    if (_pinController.text.isEmpty) return;

    if (!_isFirstPinSet) {
      setState(() {
        _isFirstPinSet = true;
        _errorMessage = null;
      });
      return;
    }

    if (_pinController.text != _confirmPinController.text) {
      setState(() {
        _errorMessage = 'رمز PIN غير متطابق';
        _confirmPinController.clear();
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.setPin(_pinController.text);

      if (!mounted) return;

      // اختيار المصادقة البيومترية
      final bool? useBiometrics = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('المصادقة البيومترية'),
          content: const Text('هل تريد تفعيل المصادقة البيومترية؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('لا'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('نعم'),
            ),
          ],
        ),
      );

      if (useBiometrics == true) {
        if (!mounted) return;
        final canUseBiometrics = await authProvider.authenticateWithBiometrics();
        if (!canUseBiometrics && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('فشل في تفعيل المصادقة البيومترية')),
          );
        }
      }

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعداد رمز PIN'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isFirstPinSet
                  ? 'تأكيد رمز PIN'
                  : 'أدخل رمز PIN الجديد',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _isFirstPinSet
                  ? 'الرجاء إدخال رمز PIN مرة أخرى للتأكيد'
                  : 'الرجاء إدخال رمز PIN المكون من 6 أرقام',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            PinInput(
              controller: _isFirstPinSet ? _confirmPinController : _pinController,
              onCompleted: (_) => _setupPin(),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 32),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _setupPin,
                child: Text(_isFirstPinSet ? 'تأكيد' : 'التالي'),
              ),
          ],
        ),
      ),
    );
  }
}
