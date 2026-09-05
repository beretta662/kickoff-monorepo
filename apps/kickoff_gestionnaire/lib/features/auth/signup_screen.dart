import 'package:flutter/material.dart';
import 'package:kickoff_core/kickoff_core.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';

/// Écran d'inscription. Ne crée volontairement aucune compétition —
/// juste le compte. La création de compétition vient après, comme
/// première action une fois connecté.
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //logo
              Image.asset('assets/images/icon_mark.png', width: 64, height: 64),
              const SizedBox(height: 20),

              Text('Créer un compte', style: AppTextStyles.h1),
              const SizedBox(height: 4),
              Text(
                'Vous pourrez créer votre première compétition juste après.',
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: 28),

              Text('Nom d\'utilisateur', style: AppTextStyles.bodySecondary),
              const SizedBox(height: 6),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(hintText: 'Ngono Patrick'),
              ),
              const SizedBox(height: 16),

              Text('Email', style: AppTextStyles.bodySecondary),
              const SizedBox(height: 6),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'coach.ngono@mail.com'),
              ),
              const SizedBox(height: 16),

              Text('Mot de passe', style: AppTextStyles.bodySecondary),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text('Confirmer le mot de passe', style: AppTextStyles.bodySecondary),
              const SizedBox(height: 6),
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () {
                  // TODO: validation des champs + Supabase Auth (signUp)
                },
                child: const Text('Créer mon compte'),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text('ou', style: AppTextStyles.caption),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),

              OutlinedButton(
                onPressed: () {
                  // TODO: inscription Google via Supabase OAuth
                },
                child: const Text("S'inscrire avec Google"),
              ),
              const SizedBox(height: 20),

              Center(
                child: RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodySecondary,
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