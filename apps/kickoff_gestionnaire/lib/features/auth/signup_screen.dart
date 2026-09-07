import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:kickoff_core/kickoff_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../routes.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    setState(() => _errorMessage = null);

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Merci de remplir tous les champs.');
      return;
    }
    if (password != confirm) {
      setState(() => _errorMessage = 'Les mots de passe ne correspondent pas.');
      return;
    }
    if (password.length < 6) {
      setState(() => _errorMessage = 'Le mot de passe doit faire au moins 6 caractères.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await SupabaseService.client.auth.signUp(
        email: email,
        password: password,
        data: {'username': name},
      );

      if (!mounted) return;

      if (response.session != null) {
        Get.offAllNamed(AppRoutes.home);
      } else {
        Get.snackbar(
          'Compte créé',
          'Vérifie ta boîte mail pour confirmer ton adresse avant de te connecter.',
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.back();
      }
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/images/icon_mark.png', width: 64, height: 64,  filterQuality: FilterQuality.high),
              const SizedBox(height: 20),

              Text('Créer un compte', style: AppTextStyles.h1(context)),
              const SizedBox(height: 4),
              Text('Vous pourrez créer votre première compétition juste après.', style: AppTextStyles.bodySecondary(context)),
              const SizedBox(height: 28),

              Text("Nom d'utilisateur", style: AppTextStyles.bodySecondary(context)),
              const SizedBox(height: 6),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(hintText: 'Ngono Patrick'),
              ),
              const SizedBox(height: 16),

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
              const SizedBox(height: 16),

              Text('Confirmer le mot de passe', style: AppTextStyles.bodySecondary(context)),
              const SizedBox(height: 6),
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: palette.textMuted,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(_errorMessage!, style: AppTextStyles.caption(context).copyWith(color: AppColors.danger)),
              ],

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSignup,
                child: _isLoading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Créer mon compte'),
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
                  // TODO: inscription Google via Supabase OAuth (plus tard)
                },
                child: const Text("S'inscrire avec Google"),
              ),
              const SizedBox(height: 20),

              Center(
                child: RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodySecondary(context),
                    children: [
                      const TextSpan(text: 'Déjà un compte ? '),
                      TextSpan(
                        text: 'Se connecter',
                        style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600),
                        recognizer: TapGestureRecognizer()..onTap = () => Get.back(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}