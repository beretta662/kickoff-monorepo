import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:kickoff_core/kickoff_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _errorMessage = null);

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Renseigne ton email et ton mot de passe.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await SupabaseService.client.auth.signInWithPassword(email: email, password: password);
      if (mounted) Get.offAllNamed(AppRoutes.home);
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Une erreur est survenue. Vérifie ta connexion.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Image.asset('assets/images/icon_mark.png', width: 64, height: 64),
              const SizedBox(height: 20),

              Text('Kickoff', style: AppTextStyles.h1(context)),
              const SizedBox(height: 4),
              Text('Connectez-vous à votre espace gestionnaire.', style: AppTextStyles.bodySecondary(context)),
              const SizedBox(height: 28),

              Text('Email', style: AppTextStyles.bodySecondary(context)),
              const SizedBox(height: 6),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'coach.ngono@mail.com'),
              ),
              const SizedBox(height: 16),

              Text('Mot de passe', style: AppTextStyles.bodySecondary(context)),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: palette.textMuted,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(_errorMessage!, style: AppTextStyles.caption(context).copyWith(color: AppColors.danger)),
              ],

              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // TODO: écran "mot de passe oublié"
                  },
                  child: Text('Mot de passe oublié ?', style: AppTextStyles.caption(context).copyWith(color: AppColors.accent)),
                ),
              ),
              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                child: _isLoading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Se connecter'),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text('ou', style: AppTextStyles.caption(context)),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),

              OutlinedButton(
                onPressed: () {
                  // TODO: connexion Google via Supabase OAuth (plus tard)
                },
                child: const Text('Continuer avec Google'),
              ),
              const SizedBox(height: 20),

              Center(
                child: RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodySecondary(context),
                    children: [
                      const TextSpan(text: "Pas encore de compte ? "),
                      TextSpan(
                        text: 'Créer un compte',
                        style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600),
                        recognizer: TapGestureRecognizer()..onTap = () => Get.toNamed(AppRoutes.signup),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}