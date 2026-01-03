import 'package:flutter/material.dart';
import 'package:noor_energy/core/widgets/app_button.dart';
import 'package:noor_energy/core/widgets/app_text_field.dart';
import 'package:noor_energy/routes/app_routes.dart';
import 'package:noor_energy/l10n/app_localizations.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

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
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.register),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text(
                AppLocalizations.of(context)!.registerTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.joinToday,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              AppTextField(
                label: AppLocalizations.of(context)!.fullName,
                hint: AppLocalizations.of(context)!.enterFullName,
                controller: _nameController,
                prefixIcon: const Icon(Icons.person_outlined),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: AppLocalizations.of(context)!.email,
                hint: AppLocalizations.of(context)!.enterEmail,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: AppLocalizations.of(context)!.password,
                hint: AppLocalizations.of(context)!.enterPassword,
                controller: _passwordController,
                obscureText: true,
                prefixIcon: const Icon(Icons.lock_outlined),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: AppLocalizations.of(context)!.confirmPassword,
                hint: AppLocalizations.of(context)!.enterConfirmPassword,
                controller: _confirmPasswordController,
                obscureText: true,
                prefixIcon: const Icon(Icons.lock_outlined),
              ),
              const SizedBox(height: 24),
              AppButton(
                text: AppLocalizations.of(context)!.register,
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.homeScreen);
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppLocalizations.of(context)!.alreadyHaveAccount),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(AppLocalizations.of(context)!.login),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

