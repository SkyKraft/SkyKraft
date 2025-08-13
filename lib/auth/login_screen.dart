import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth_controller.dart';
import '../shared/widgets/app_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _obscurePassword = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _logoAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _logoAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    setState(() { _loading = true; _error = null; });
    try {
      final user = await AuthController.to.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (!mounted) return;
      if (user == null) {
        setState(() { _error = 'Login failed'; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed. Please check your credentials.')),
        );
      } else {
        Get.offAllNamed('/main');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login error: $e')),
      );
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF101C2C), const Color(0xFF22304A)]
                : [const Color(0xFF1976D2), const Color(0xFF00B8D9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
        child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: _fadeAnim,
                  child: ScaleTransition(
                    scale: _logoAnim,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.black.withAlpha(80) : Colors.black.withAlpha(30),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                                              child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            color: isDark ? Colors.white : Colors.black,
                            child: Center(
                                                          child: SkykraftSmallLogo(
                              size: 40,
                            ),
                            ),
                          ),
                        ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Card(
                      elevation: 10,
                      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      color: isDark ? theme.colorScheme.surface : Colors.white,
                child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                            Text(
                              'Welcome Back',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sign in to continue',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: isDark ? Colors.grey[300] : Colors.grey[600],
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 32),
                            TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                                prefixIcon: const Icon(Icons.email_outlined),
                          ),
                          keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.email],
                      ),
                      const SizedBox(height: 20),
                            TextField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                          ),
                              obscureText: _obscurePassword,
                              autofillHints: const [AutofillHints.password],
                      ),
                            const SizedBox(height: 16),
                      if (_error != null) ...[
                              Text(_error!, style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 12),
                      ],
                            SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 3,
                            ),
                                child: _loading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text('Login'),
                        ),
                      ),
                            const SizedBox(height: 28),
                            TextButton(
                          onPressed: () => Get.toNamed('/signup'),
                          child: const Text('Don\'t have an account? Sign Up'),
                              style: TextButton.styleFrom(
                                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
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
  }
} 