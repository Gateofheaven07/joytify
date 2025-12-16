import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:joytify/services/auth_service.dart';
import 'package:joytify/screens/home_screen.dart';
import 'package:joytify/utils/theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  // Login form
  final _loginFormKey = GlobalKey<FormState>();
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  
  // Register form
  final _registerFormKey = GlobalKey<FormState>();
  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPasswordController = TextEditingController();
  
  bool _loginLoading = false;
  bool _registerLoading = false;

  // Password visibility
  bool _isLoginPasswordVisible = false;
  bool _isRegisterPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor.withOpacity(0.8),
                AppTheme.secondaryColor.withOpacity(0.6),
                AppTheme.accentColor.withOpacity(0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  width: 400,
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: Colors.white.withOpacity(0.1),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 0,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo
                          Container(
                            width: 100,
                            height: 100,
                            child: Image.asset(
                              'assets/images/joytify_logo_3.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                print('Logo loading error: $error');
                                return Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.music_note,
                                    color: Colors.white,
                                    size: 50,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Welcome Text
                          Text(
                            'Selamat Datang',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Masuk ke akun Anda untuk melanjutkan',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.8),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          
                          // Simple Tab Bar
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _tabController.animateTo(0),
                                    child: AnimatedBuilder(
                                      animation: _tabController,
                                      builder: (context, child) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          decoration: BoxDecoration(
                                            color: _tabController.index == 0 
                                                ? AppTheme.primaryColor 
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            'Masuk',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: _tabController.index == 0 
                                                  ? Colors.white 
                                                  : Colors.white.withOpacity(0.7),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _tabController.animateTo(1),
                                    child: AnimatedBuilder(
                                      animation: _tabController,
                                      builder: (context, child) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          decoration: BoxDecoration(
                                            color: _tabController.index == 1 
                                                ? AppTheme.primaryColor 
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            'Daftar',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: _tabController.index == 1 
                                                  ? Colors.white 
                                                  : Colors.white.withOpacity(0.7),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Form Content
                          AnimatedBuilder(
                            animation: _tabController,
                            builder: (context, child) {
                              if (_tabController.index == 0) {
                                return _buildSimpleLoginForm();
                              } else {
                                return _buildSimpleRegisterForm();
                              }
                            },
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
      ),
      );
    } catch (e, stackTrace) {
      print('Error building AuthScreen: $e');
      print('Stack trace: $stackTrace');
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor.withOpacity(0.8),
                AppTheme.secondaryColor.withOpacity(0.6),
                AppTheme.accentColor.withOpacity(0.8),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading page',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please check console for details',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildSimpleLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Email Field
          TextFormField(
            controller: _loginEmailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
              hintText: 'Masukkan email Anda',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              prefixIcon: Icon(Icons.email, color: AppTheme.primaryColor),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
            ),
            validator: _validateEmail,
          ),
          const SizedBox(height: 16),
          
          // Password Field
          TextFormField(
            controller: _loginPasswordController,
            obscureText: !_isLoginPasswordVisible,
            textInputAction: TextInputAction.done,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
              hintText: 'Masukkan password Anda',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              prefixIcon: Icon(Icons.lock, color: AppTheme.primaryColor),
              suffixIcon: IconButton(
                icon: Icon(
                  _isLoginPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white.withOpacity(0.6),
                ),
                onPressed: () {
                  setState(() {
                    _isLoginPasswordVisible = !_isLoginPasswordVisible;
                  });
                },
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
            ),
            validator: _validatePassword,
            onFieldSubmitted: (_) => _handleLogin(),
          ),
          const SizedBox(height: 24),
          
          // Login Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _loginLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _loginLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Masuk',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleRegisterForm() {
    return Form(
      key: _registerFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Name Field
          TextFormField(
            controller: _registerNameController,
            textInputAction: TextInputAction.next,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Nama Lengkap',
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
              hintText: 'Masukkan nama lengkap Anda',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              prefixIcon: Icon(Icons.person, color: AppTheme.primaryColor),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
            ),
            validator: _validateName,
          ),
          const SizedBox(height: 16),
          
          // Email Field
          TextFormField(
            controller: _registerEmailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
              hintText: 'Masukkan email Anda',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              prefixIcon: Icon(Icons.email, color: AppTheme.primaryColor),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
            ),
            validator: _validateEmail,
          ),
          const SizedBox(height: 16),
          
          // Password Field
          TextFormField(
            controller: _registerPasswordController,
            obscureText: !_isRegisterPasswordVisible,
            textInputAction: TextInputAction.next,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
              hintText: 'Masukkan password Anda',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              prefixIcon: Icon(Icons.lock, color: AppTheme.primaryColor),
              suffixIcon: IconButton(
                icon: Icon(
                  _isRegisterPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white.withOpacity(0.6),
                ),
                onPressed: () {
                  setState(() {
                    _isRegisterPasswordVisible = !_isRegisterPasswordVisible;
                  });
                },
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
            ),
            validator: _validatePassword,
          ),
          const SizedBox(height: 16),
          
          // Confirm Password Field
          TextFormField(
            controller: _registerConfirmPasswordController,
            obscureText: !_isConfirmPasswordVisible,
            textInputAction: TextInputAction.done,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Konfirmasi Password',
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
              hintText: 'Konfirmasi password Anda',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              prefixIcon: Icon(Icons.lock_outline, color: AppTheme.primaryColor),
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white.withOpacity(0.6),
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
            ),
            validator: _validateConfirmPassword,
            onFieldSubmitted: (_) => _handleRegister(),
          ),
          const SizedBox(height: 24),
          
          // Register Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _registerLoading ? null : _handleRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _registerLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Daftar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // Validation methods
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    if (value.length < 2) {
      return 'Nama minimal 2 karakter';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    if (value != _registerPasswordController.text) {
      return 'Password tidak cocok';
    }
    return null;
  }

  // Auth methods
  void _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;

    setState(() {
      _loginLoading = true;
    });

    try {
      final result = await AuthService.login(
        email: _loginEmailController.text.trim(),
        password: _loginPasswordController.text,
      );

      if (result.isSuccess) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result.message)),
          );
        }
      }
    } catch (e) {
      print('Login error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terjadi kesalahan saat login')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loginLoading = false;
        });
      }
    }
  }

  void _handleRegister() async {
    if (!_registerFormKey.currentState!.validate()) return;

    setState(() {
      _registerLoading = true;
    });

    try {
      final email = _registerEmailController.text.trim();
      final result = await AuthService.register(
        displayName: _registerNameController.text.trim(),
        email: email,
        password: _registerPasswordController.text,
      );

      if (result.isSuccess) {
        if (mounted) {
          // Clear register form
          _registerNameController.clear();
          _registerPasswordController.clear();
          _registerConfirmPasswordController.clear();
          
          // Show success dialog
          await _showSuccessDialog();
          
          // Switch to login tab and pre-fill email
          _tabController.animateTo(0);
          _loginEmailController.text = email;
          
          // Clear register email after copying to login
          _registerEmailController.clear();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Register error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Terjadi kesalahan saat mendaftar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _registerLoading = false;
        });
      }
    }
  }

  Future<void> _showSuccessDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.white.withOpacity(0.15),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 0,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Success Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.green.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Title
                    Text(
                      'Akun Berhasil Dibuat!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    
                    // Message
                    Text(
                      'Akun Anda telah berhasil dibuat.\nSilakan login untuk melanjutkan.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    
                    // OK Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'OK',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}