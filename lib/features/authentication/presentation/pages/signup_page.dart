import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cobox_sv_mobile/app/colors.dart';
import 'package:cobox_sv_mobile/app/providers.dart';
import 'package:cobox_sv_mobile/core/utils/responsive_layout.dart';
import 'package:cobox_sv_mobile/core/utils/validators.dart';
import 'package:cobox_sv_mobile/core/widgets/app_button.dart';
import 'package:cobox_sv_mobile/core/widgets/app_textfield.dart';
import 'package:cobox_sv_mobile/features/authentication/presentation/providers/auth_provider.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _licenceController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _licenceController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onSignup() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authNotifierProvider.notifier).signup(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          phone: _phoneController.text.trim(),
          licenceNumber: _licenceController.text.trim(),
        );

    final authState = ref.read(authNotifierProvider);
    switch (authState.type) {
      case AuthStateType.authenticated:
        ref.read(authStatusProvider.notifier).state = AuthStatus.authenticated;
        if (mounted) {
          context.go('/home');
        }
        break;
      case AuthStateType.error:
        if (mounted) {
          final errorMessage = authState.error ?? 'Error al registrarse';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: errorMessage.contains('La cuenta fue creada')
                  ? AppColors.secondary
                  : AppColors.danger,
            ),
          );
          if (errorMessage.contains('La cuenta fue creada')) {
            context.go('/login');
          }
        }
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.type == AuthStateType.loading;
    final colorScheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = adaptivePagePadding(constraints.maxWidth);

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primary,
                        Color(0xFF1557B0),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 40),
                        const Icon(
                          Icons.local_shipping_rounded,
                          size: 64,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Crear Cuenta',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Registrate en CoBox SV',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.white70,
                              ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 28,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Registro',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3FAF8),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFFD9E2EC),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: AppColors.secondary,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.local_shipping_outlined,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Las cuentas creadas desde esta app quedan registradas como conductores.',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(color: AppColors.gray500),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 18),
                                AppTextfield(
                                  controller: _nameController,
                                  label: 'Nombre completo',
                                  hint: 'Ingrese su nombre',
                                  prefixIcon: const Icon(Icons.person_outline),
                                  keyboardType: TextInputType.name,
                                  textInputAction: TextInputAction.next,
                                  textCapitalization: TextCapitalization.words,
                                  validator: validateName,
                                ),
                                const SizedBox(height: 14),
                                AppTextfield(
                                  controller: _emailController,
                                  label: 'Correo electronico',
                                  hint: 'ejemplo@correo.com',
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  validator: validateEmail,
                                ),
                                const SizedBox(height: 14),
                                AppTextfield(
                                  controller: _phoneController,
                                  label: 'Telefono',
                                  hint: '+54 11 1234-5678',
                                  prefixIcon: const Icon(Icons.phone_outlined),
                                  keyboardType: TextInputType.phone,
                                  textInputAction: TextInputAction.next,
                                  validator: validatePhone,
                                ),
                                const SizedBox(height: 14),
                                AppTextfield(
                                  controller: _licenceController,
                                  label: 'Numero de licencia',
                                  hint: 'Ej. BTO123456',
                                  prefixIcon: const Icon(Icons.badge_outlined),
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  validator: validateLicenceNumber,
                                ),
                                const SizedBox(height: 14),
                                AppTextfield(
                                  controller: _passwordController,
                                  label: 'Contrasena',
                                  hint: 'Minimo 8 caracteres',
                                  prefixIcon: const Icon(Icons.lock_outlined),
                                  obscureText: true,
                                  textInputAction: TextInputAction.next,
                                  validator: validatePassword,
                                ),
                                const SizedBox(height: 14),
                                AppTextfield(
                                  controller: _confirmPasswordController,
                                  label: 'Confirmar contrasena',
                                  hint: 'Repita la contrasena',
                                  prefixIcon: const Icon(Icons.lock_outlined),
                                  obscureText: true,
                                  textInputAction: TextInputAction.done,
                                  validator: (value) {
                                    if (value != _passwordController.text) {
                                      return 'Las contrasenas no coinciden';
                                    }
                                    return null;
                                  },
                                  onSubmitted: (_) => _onSignup(),
                                ),
                                const SizedBox(height: 20),
                                AppButton(
                                  label: 'Crear Cuenta',
                                  onPressed: _onSignup,
                                  loading: isLoading,
                                  fullWidth: true,
                                  size: AppButtonSize.large,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Ya tienes cuenta? ',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.white70),
                            ),
                            TextButton(
                              onPressed: () => context.go('/login'),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Inicia sesion',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: bottomInset > 0 ? 16 : 24),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
