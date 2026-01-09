import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import '../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/email_verification_dialog.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  bool _isLogin = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final formKey = _isLogin ? _loginFormKey : _registerFormKey;
    if (!formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    try {
      if (_isLogin) {
        await authProvider.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        await authProvider.registerWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
          '${_nameController.text.trim()} ${_surnameController.text.trim()}',
        );
        
        if (mounted) {
          // Gelişmiş doğrulama dialogunu göster
          final verified = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) => const EmailVerificationDialog(),
          );

          if (verified == true && mounted) {
             // Kullanıcı doğrulandı, giriş için hazırla
             setState(() {
               _isLogin = true;
               _passwordController.clear();
             });
             
             // Temiz bir başlangıç için çıkış yap
             await authProvider.signOut();

             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('E-posta başarıyla doğrulandı! Şimdi giriş yapabilirsiniz.'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        final message = e.toString().replaceFirst('Exception: ', '');
        final isVerificationError = message.contains('doğrulanmamış') || message.contains('email-not-verified');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: Duration(seconds: isVerificationError ? 5 : 4),
            action: isVerificationError 
              ? SnackBarAction(
                  label: 'Tekrar Gönder',
                  textColor: Colors.white,
                  onPressed: () => _resendVerification(),
                )
              : null,
          ),
        );
      }
    }
  }

  Future<void> _resendVerification() async {
    final authProvider = context.read<AuthProvider>();
    try {
      await authProvider.resendVerificationEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Doğrulama bağlantısı tekrar gönderildi. E-postanızı kontrol edin.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor.withOpacity(0.05),
              Colors.white,
              AppTheme.secondaryColor.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Column(
                  children: [
                    // Brand Identity
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.insights_rounded,
                        size: 64,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'CRM',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                    ),
                    Text(
                      'Müşteri İlişkilerinde Yeni Nesil',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                    const SizedBox(height: 48),

                    // Login/Register Card
                    PageTransitionSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
                        return SharedAxisTransition(
                          animation: primaryAnimation,
                          secondaryAnimation: secondaryAnimation,
                          transitionType: SharedAxisTransitionType.horizontal,
                          child: child,
                        );
                      },
                      child: Card(
                        key: ValueKey<bool>(_isLogin),
                        elevation: 0,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                          side: BorderSide(color: Colors.grey.shade100),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Form(
                            key: _isLogin ? _loginFormKey : _registerFormKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  _isLogin ? 'Hoş Geldiniz' : 'Hesap Oluşturun',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _isLogin 
                                    ? 'Devam etmek için giriş yapın.' 
                                    : 'Bilgilerinizi girerek kayıt olun.',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 32),
                                
                                 if (!_isLogin) ...[
                                   Row(
                                     children: [
                                       Expanded(
                                         child: TextFormField(
                                           controller: _nameController,
                                           decoration: const InputDecoration(
                                             labelText: 'İsim',
                                             prefixIcon: Icon(Icons.person_outline_rounded),
                                           ),
                                           validator: (value) =>
                                               value == null || value.isEmpty ? 'Gerekli' : null,
                                         ),
                                       ),
                                       const SizedBox(width: 12),
                                       Expanded(
                                         child: TextFormField(
                                           controller: _surnameController,
                                           decoration: const InputDecoration(
                                             labelText: 'Soyisim',
                                           ),
                                           validator: (value) =>
                                               value == null || value.isEmpty ? 'Gerekli' : null,
                                         ),
                                       ),
                                     ],
                                   ),
                                   const SizedBox(height: 16),
                                 ],
                                
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  autofillHints: const [AutofillHints.email],
                                  decoration: const InputDecoration(
                                    labelText: 'E-posta',
                                    prefixIcon: Icon(Icons.alternate_email_rounded),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return 'E-posta giriniz';
                                    if (!value.contains('@')) return 'Geçerli e-posta giriniz';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  autofillHints: const [AutofillHints.password],
                                  decoration: InputDecoration(
                                    labelText: 'Şifre',
                                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                        size: 20,
                                      ),
                                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return 'Şifre giriniz';
                                    if (value.length < 6) return 'En az 6 karakter';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 32),
                                
                                Consumer<AuthProvider>(
                                  builder: (context, authProvider, _) {
                                    return ElevatedButton(
                                      onPressed: authProvider.isLoading ? null : _handleSubmit,
                                      child: authProvider.isLoading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Text(_isLogin ? 'Giriş Yap' : 'Kayıt Ol'),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                          _loginFormKey.currentState?.reset();
                          _registerFormKey.currentState?.reset();
                        });
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                      ),
                      child: Text(
                        _isLogin
                            ? 'Hesabınız yok mu? Ücretsiz Kaydolun'
                            : 'Zaten hesabınız var mı? Giriş yapın',
                        style: const TextStyle(fontWeight: FontWeight.w600),
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


