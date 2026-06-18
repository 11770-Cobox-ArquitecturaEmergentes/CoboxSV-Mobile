import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cobox_sv_mobile/core/widgets/app_textfield.dart';
import 'package:cobox_sv_mobile/core/utils/validators.dart';
import 'package:cobox_sv_mobile/features/profile/presentation/providers/profile_provider.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecial = false;

  @override
  void initState() {
    super.initState();
    _newController.addListener(_checkRequirements);
  }

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _checkRequirements() {
    final value = _newController.text;
    setState(() {
      _hasMinLength = value.length >= 8;
      _hasUppercase = RegExp(r'[A-Z]').hasMatch(value);
      _hasLowercase = RegExp(r'[a-z]').hasMatch(value);
      _hasNumber = RegExp(r'[0-9]').hasMatch(value);
      _hasSpecial = RegExp(r'[!@#\$%^&*(),.?":{}|<>_]').hasMatch(value);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final error = await ref.read(profileProvider.notifier).changePassword(
          _currentController.text,
          _newController.text,
        );

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña actualizada correctamente')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final state = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cambiar Contraseña')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextfield(
                label: 'Contraseña actual',
                controller: _currentController,
                obscureText: true,
                validator: validatePassword,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              AppTextfield(
                label: 'Nueva contraseña',
                controller: _newController,
                obscureText: true,
                validator: validatePassword,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Requisitos:',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _requirementRow(
                      'Mínimo 8 caracteres',
                      _hasMinLength,
                      colorScheme,
                      textTheme,
                    ),
                    _requirementRow(
                      'Al menos una mayúscula',
                      _hasUppercase,
                      colorScheme,
                      textTheme,
                    ),
                    _requirementRow(
                      'Al menos una minúscula',
                      _hasLowercase,
                      colorScheme,
                      textTheme,
                    ),
                    _requirementRow(
                      'Al menos un número',
                      _hasNumber,
                      colorScheme,
                      textTheme,
                    ),
                    _requirementRow(
                      'Al menos un carácter especial',
                      _hasSpecial,
                      colorScheme,
                      textTheme,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppTextfield(
                label: 'Confirmar nueva contraseña',
                controller: _confirmController,
                obscureText: true,
                validator: (v) {
                  if (v != _newController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _save(),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: state.isSaving ? null : _save,
                  child: state.isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Cambiar Contraseña'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _requirementRow(
    String text,
    bool met,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 16,
            color: met ? colorScheme.primary : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: textTheme.bodySmall?.copyWith(
              color: met ? colorScheme.primary : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
