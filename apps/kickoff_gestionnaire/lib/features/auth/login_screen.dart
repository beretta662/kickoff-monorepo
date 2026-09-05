import 'package:flutter/material.dart';
import 'package:kickoff_core/kickoff_core.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import '../../routes.dart';

/// Écran de connexion. Pour l'instant, les boutons ne font rien
/// (pas encore de Supabase branché, pas encore de routes enregistrées).
/// On y reviendra une fois cet écran validé visuellement.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

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
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                // Logo
              Image.asset(
                'assets/images/icon_mark.png',
                width: 64,
                height: 64,
              ),

              Text('Kickoff', style: AppTextStyles.h1),
              const SizedBox(height: 4),
              Text(
                'Connectez-vous à votre espace gestionnaire.',
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: 28),

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
              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // TODO: écran "mot de passe oublié"
                  },
                  child: Text('Mot de passe oublié ?', style: AppTextStyles.caption.copyWith(color: AppColors.accent)),
                ),
              ),
              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: () {
                  // TODO: appel Supabase Auth (signInWithPassword)
                },
                child: const Text('Se connecter'),
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
                  // TODO: connexion Google via Supabase OAuth
                },
                child: const Text('Continuer avec Google'),
              ),
              const SizedBox(height: 20),

                            Center(
                child: RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodySecondary,
                    children: [
                      const TextSpan(text: "Pas encore de compte ? "),
                      TextSpan(
                        text: 'Créer un compte',
                        style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Get.toNamed(AppRoutes.signup),
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