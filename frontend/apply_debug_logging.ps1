# Temporary debug logging so we can see the REAL error in the flutter run console

$path = "C:\Users\ABC\Desktop\AI_Mentor\frontend\lib\presentation\auth\login_screen.dart"
New-Item -ItemType Directory -Force -Path (Split-Path $path) | Out-Null
$content = @'
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/network/auth_api_service.dart';
import '../../core/providers/user_provider.dart';
import '../../core/router/app_routes.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/utils/jwt_decoder.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthApiService();
  final _storage = SecureStorageService();
  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  void _redirectForRole(String? role) {
    switch (role) {
      case 'admin':
        context.go(AppRoutes.adminDashboard);
        break;
      case 'teacher':
        context.go(AppRoutes.teacherDashboard);
        break;
      default:
        context.go(AppRoutes.examSelection);
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      context.read<UserProvider>().setUser(result.user);

      final role = JwtDecoder.role(result.token) ?? 'student';
      await _storage.saveRole(role);

      if (!mounted) return;
      _redirectForRole(role);
    } catch (e, st) {
      debugPrint('LOGIN ERROR: $e');
      debugPrint('$st');
      setState(() => _errorMessage = AuthApiService.extractErrorMessage(e));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Welcome Back', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 4),
                Text(
                  'Login to continue your exam prep',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),
                if (_errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_errorMessage!, style: TextStyle(color: Colors.red[700])),
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Email is required';
                    if (!value.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Password is required';
                    if (value.length < 8) return 'Minimum 8 characters';
                    return null;
                  },
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push(AppRoutes.forgotPassword),
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _login,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Login'),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: wire Google Sign-In (placeholder for Day 1)
                  },
                  icon: const Icon(Icons.g_mobiledata, size: 28),
                  label: const Text('Continue with Google'),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => context.push(AppRoutes.register),
                    child: const Text("Don't have an account? Register"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
'@
[System.IO.File]::WriteAllText($path, $content, (New-Object System.Text.UTF8Encoding($false)))
Write-Host "Written: $path"

$path = "C:\Users\ABC\Desktop\AI_Mentor\frontend\lib\presentation\auth\register_screen.dart"
New-Item -ItemType Directory -Force -Path (Split-Path $path) | Out-Null
$content = @'
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/network/auth_api_service.dart';
import '../../core/providers/user_provider.dart';
import '../../core/router/app_routes.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/utils/jwt_decoder.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthApiService();
  final _storage = SecureStorageService();
  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  void _redirectForRole(String? role) {
    switch (role) {
      case 'admin':
        context.go(AppRoutes.adminDashboard);
        break;
      case 'teacher':
        context.go(AppRoutes.teacherDashboard);
        break;
      default:
        context.go(AppRoutes.examSelection);
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      context.read<UserProvider>().setUser(result.user);

      final role = JwtDecoder.role(result.token) ?? 'student';
      await _storage.saveRole(role);

      if (!mounted) return;
      _redirectForRole(role);
    } catch (e, st) {
      debugPrint('REGISTER ERROR: $e');
      debugPrint('$st');
      setState(() => _errorMessage = AuthApiService.extractErrorMessage(e));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Get Started', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 4),
                Text(
                  'Create an account to begin your 7-day free trial',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                if (_errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_errorMessage!, style: TextStyle(color: Colors.red[700])),
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)),
                  validator: (value) {
                    if (value == null || value.trim().length < 2) return 'Enter your full name';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Email is required';
                    if (!value.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Password is required';
                    if (value.length < 8) return 'Minimum 8 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _register,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Register'),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Already have an account? Login'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
'@
[System.IO.File]::WriteAllText($path, $content, (New-Object System.Text.UTF8Encoding($false)))
Write-Host "Written: $path"
