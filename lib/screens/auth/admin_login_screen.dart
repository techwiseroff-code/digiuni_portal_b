import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/styles.dart';
import '../../widgets/glass_container.dart';
import '../../providers/auth_provider.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: Styles.backgroundGradientFromImage),
        child: SafeArea(
          child: Center(
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(32),
                    borderRadius: 24,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 32),
                        _buildLoginForm(),
                        const SizedBox(height: 24),
                        _buildLoginButton(),
                        const SizedBox(height: 8),
                        _buildErrorDisplay(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: const [
        Icon(Icons.admin_panel_settings, color: Colors.white, size: 64),
        SizedBox(height: 16),
        Text(
          'Admin Login',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Enter email';
              if (!v.contains('@')) return 'Enter valid email';
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () => setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                }),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Enter password';
              if (v.length < 6) return 'Min 6 characters';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: auth.isLoading ? null : _handleLogin,
            icon: const Icon(Icons.login),
            label: Text(auth.isLoading ? 'Signing in…' : 'Sign In'),
          ),
        );
      },
    );
  }

  Widget _buildErrorDisplay() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.error == null) return const SizedBox.shrink();
        return Text(auth.error!, style: const TextStyle(color: Colors.red));
      },
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;
    if (ok && auth.isAdmin) {
      Navigator.pushReplacementNamed(context, '/admin/dashboard');
    } else if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This account is not registered as an admin.'),
          backgroundColor: Colors.red,
        ),
      );
      await auth.signOut();
    }
  }
}


