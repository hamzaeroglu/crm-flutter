import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';

class EmailVerificationDialog extends StatefulWidget {
  const EmailVerificationDialog({Key? key}) : super(key: key);

  @override
  State<EmailVerificationDialog> createState() => _EmailVerificationDialogState();
}

class _EmailVerificationDialogState extends State<EmailVerificationDialog> {
  Timer? _timer;
  Timer? _pollingTimer;
  int _remainingSeconds = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _startPolling();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
        
        // Son 5 saniye kala tekrar gönder butonu aktif olsun
        if (_remainingSeconds <= 5 && !_canResend) {
          setState(() {
            _canResend = true;
          });
        }
      } else {
        _timer?.cancel();
        setState(() {
          _canResend = true;
        });
      }
    });
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final authProvider = context.read<AuthProvider>();
      await authProvider.reloadUser();
      
      if (authProvider.user?.emailVerified == true) {
        timer.cancel();
        _timer?.cancel();
        if (mounted) {
          Navigator.of(context).pop(true); // true = doğrulandı
        }
      }
    });
  }

  Future<void> _handleResend() async {
    final authProvider = context.read<AuthProvider>();
    try {
      await authProvider.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bağlantı tekrar gönderildi')),
      );
      setState(() {
        _remainingSeconds = 60;
        _canResend = false;
      });
      _startTimer(); // Timer'ı yeniden başlat
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Geri tuşunu engelle
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.mark_email_unread_rounded, color: AppTheme.primaryColor),
            SizedBox(width: 12),
            Text('E-posta Doğrulama'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Hesabınız oluşturuldu! Lütfen e-posta adresinize gönderilen bağlantıya tıklayarak hesabınızı doğrulayın.',
              style: TextStyle(height: 1.5),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '$_remainingSeconds',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('saniye kaldı', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (_canResend)
              TextButton.icon(
                onPressed: _handleResend,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Bağlantıyı Tekrar Gönder'),
              )
            else
              const Text(
                'Bağlantı ulaşmazsa süre sonunda tekrar isteyebilirsiniz.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        actions: [
          // İptal butonu (Vazgeçip çıkmak isteyenler için)
          TextButton(
            onPressed: () {
               context.read<AuthProvider>().signOut();
               Navigator.of(context).pop(false);
            },
            child: const Text('Vazgeç', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
