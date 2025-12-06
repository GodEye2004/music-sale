import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/theme.dart';
import 'package:flutter_application_1/config/constants.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/screens/buyer/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  UserRole _selectedRole = UserRole.buyer;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await AuthService().register(
        email: _emailController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
      );

      if (mounted) {
        // Show email confirmation dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('✉️ تأیید ایمیل'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'یک ایمیل تأیید برای شما ارسال شد.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  'لطفاً ایمیل ${_emailController.text} را چک کنید و روی لینک تأیید کلیک کنید.',
                ),
                const SizedBox(height: 12),
                const Text(
                  'بعد از تأیید، می‌تونید وارد بشید.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Go back to login
                },
                child: const Text('متوجه شدم'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Registration error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در ثبت نام: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ثبت نام')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.backgroundColor, AppTheme.surfaceColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textDirection: TextDirection.ltr,
                    decoration: const InputDecoration(
                      labelText: 'ایمیل',
                      prefixIcon: Icon(Icons.email_outlined),
                      hintText: 'example@email.com',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'لطفا ایمیل را وارد کنید';
                      }
                      if (!value.contains('@')) {
                        return 'ایمیل معتبر نیست';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Username Field
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'نام کاری',
                      prefixIcon: Icon(Icons.person_outlined),
                      hintText: 'نام شما',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'لطفا نام کاربری را وارد کنید';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textDirection: TextDirection.ltr,
                    decoration: InputDecoration(
                      labelText: 'رمز عبور',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'لطفا رمز عبور را وارد کنید';
                      }
                      if (value.length < AppConstants.minPasswordLength) {
                        return 'رمز عبور باید حداقل ${AppConstants.minPasswordLength} کاراکتر باشد';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Confirm Password Field
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    textDirection: TextDirection.ltr,
                    decoration: InputDecoration(
                      labelText: 'تکرار رمز عبور',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'لطفا تکرار رمز عبور را وارد کنید';
                      }
                      if (value != _passwordController.text) {
                        return 'رمز عبور و تکرار آن یکسان نیستند';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Role Selection
                  Text(
                    'نوع حساب کاربری:',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _RoleCard(
                          title: 'خریدار',
                          subtitle: 'خرید و دانلود بیت',
                          icon: Icons.shopping_bag_outlined,
                          isSelected: _selectedRole == UserRole.buyer,
                          onTap: () {
                            setState(() {
                              _selectedRole = UserRole.buyer;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _RoleCard(
                          title: 'پرودیوسر',
                          subtitle: 'فروش بیت',
                          icon: Icons.music_note_outlined,
                          isSelected: _selectedRole == UserRole.producer,
                          onTap: () {
                            setState(() {
                              _selectedRole = UserRole.producer;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  //Register Button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('ثبت نام'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected ? Colors.white : AppTheme.textSecondaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? Colors.white.withOpacity(0.8)
                    : AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
