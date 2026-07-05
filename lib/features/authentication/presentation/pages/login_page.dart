import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cobox_sv_mobile/app/colors.dart';
import 'package:cobox_sv_mobile/app/providers.dart';
import 'package:cobox_sv_mobile/core/utils/validators.dart';
import 'package:cobox_sv_mobile/features/authentication/presentation/providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _applyDemoCredentials();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authNotifierProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text,
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authState.error ?? 'Error desconocido'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
        break;
      default:
        break;
    }
  }

  Future<void> _loginWithDemo() async {
    _applyDemoCredentials();
    await _onLogin();
  }

  void _applyDemoCredentials() {
    _emailController.text = 'conductor@cobox.com';
    _passwordController.text = 'Demo123!';
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.type == AuthStateType.loading;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 24 + bottomInset),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 390),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.black.withValues(alpha: 0.08),
                                blurRadius: 28,
                                offset: const Offset(0, 18),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _LoginHeader(textTheme: textTheme),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(26, 24, 26, 28),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Acceso para conductores',
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: AppColors.gray500,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF3FAF8),
                                          borderRadius: BorderRadius.circular(18),
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
                                                color: AppColors.white,
                                                size: 22,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Conductor de flota',
                                                    style: textTheme.titleSmall?.copyWith(
                                                      fontWeight: FontWeight.w700,
                                                      color: AppColors.text,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'La app movil opera solo con cuentas de conductor.',
                                                    style: textTheme.bodySmall?.copyWith(
                                                      color: AppColors.gray500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 22),
                                      _LoginField(
                                        label: 'Correo electronico',
                                        hintText: 'conductor@cobox.com',
                                        controller: _emailController,
                                        keyboardType: TextInputType.emailAddress,
                                        textInputAction: TextInputAction.next,
                                        validator: validateEmail,
                                        prefixIcon: Icons.person_outline_rounded,
                                      ),
                                      const SizedBox(height: 14),
                                      _LoginField(
                                        label: 'Contrasena',
                                        hintText: 'Ingresa tu contrasena',
                                        controller: _passwordController,
                                        obscureText: true,
                                        textInputAction: TextInputAction.done,
                                        validator: validatePassword,
                                        prefixIcon: Icons.lock_outline_rounded,
                                        onSubmitted: (_) => _onLogin(),
                                      ),
                                      const SizedBox(height: 18),
                                      _PrimaryActionButton(
                                        label: 'Iniciar sesion',
                                        isLoading: isLoading,
                                        onPressed: _onLogin,
                                      ),
                                      const SizedBox(height: 16),
                                      Center(
                                        child: Wrap(
                                          crossAxisAlignment: WrapCrossAlignment.center,
                                          spacing: 4,
                                          children: [
                                            Text(
                                              'No tienes cuenta?',
                                              style: textTheme.bodyMedium?.copyWith(
                                                color: AppColors.gray500,
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () => context.go('/signup'),
                                              style: TextButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                                minimumSize: Size.zero,
                                                tapTargetSize:
                                                    MaterialTapTargetSize.shrinkWrap,
                                              ),
                                              child: const Text('Crear cuenta'),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      const Divider(
                                        color: Color(0xFFE2E8F0),
                                        thickness: 1,
                                      ),
                                      const SizedBox(height: 18),
                                      Center(
                                        child: Text(
                                          'Acceso rapido de demostracion',
                                          style: textTheme.bodyMedium?.copyWith(
                                            color: AppColors.gray500,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _DemoButton(
                                              label: 'Demo Conductor',
                                              onTap: _loginWithDemo,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          '(c) 2026 CoBox SmartVision. Todos los derechos',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.gray500,
                          ),
                          textAlign: TextAlign.center,
                        ),
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

class _LoginHeader extends StatelessWidget {
  const _LoginHeader({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 30),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.secondary,
            AppColors.primary,
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              color: AppColors.white,
              size: 36,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'CoBox SmartVision',
            style: textTheme.headlineSmall?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Sistema de Gestion Logistica',
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.white.withValues(alpha: 0.92),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LoginField extends StatefulWidget {
  const _LoginField({
    required this.label,
    required this.hintText,
    required this.controller,
    required this.prefixIcon,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.obscureText = false,
    this.onSubmitted,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final bool obscureText;
  final ValueChanged<String>? onSubmitted;

  @override
  State<_LoginField> createState() => _LoginFieldState();
}

class _LoginFieldState extends State<_LoginField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  void didUpdateWidget(covariant _LoginField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscureText != widget.obscureText) {
      _obscure = widget.obscureText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          validator: widget.validator,
          obscureText: _obscure,
          onFieldSubmitted: widget.onSubmitted,
          style: textTheme.bodyLarge?.copyWith(color: AppColors.text),
          decoration: InputDecoration(
            hintText: widget.hintText,
            filled: true,
            fillColor: AppColors.white,
            prefixIcon: Icon(
              widget.prefixIcon,
              color: AppColors.gray400,
              size: 20,
            ),
            suffixIcon: widget.obscureText
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        _obscure = !_obscure;
                      });
                    },
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.gray400,
                      size: 20,
                    ),
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            hintStyle: textTheme.bodyLarge?.copyWith(
              color: AppColors.gray400,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD9E2EC)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.secondary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.danger),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              )
            : const Icon(Icons.arrow_forward_rounded, size: 18),
        label: Text(
          label,
          style: textTheme.titleSmall?.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: AppColors.secondary.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

class _DemoButton extends StatelessWidget {
  const _DemoButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.text,
        backgroundColor: const Color(0xFFF8FAFC),
        side: const BorderSide(color: Color(0xFFD9E2EC)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        label,
        style: textTheme.labelLarge?.copyWith(
          color: AppColors.text,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
