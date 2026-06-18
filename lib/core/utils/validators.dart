String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'El correo electrónico es requerido';
  }
  final emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  if (!emailRegex.hasMatch(value.trim())) {
    return 'Ingrese un correo electrónico válido';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'La contraseña es requerida';
  }
  if (value.length < 8) {
    return 'La contraseña debe tener al menos 8 caracteres';
  }
  if (!RegExp(r'[A-Z]').hasMatch(value)) {
    return 'La contraseña debe contener al menos una mayúscula';
  }
  if (!RegExp(r'[a-z]').hasMatch(value)) {
    return 'La contraseña debe contener al menos una minúscula';
  }
  if (!RegExp(r'[0-9]').hasMatch(value)) {
    return 'La contraseña debe contener al menos un número';
  }
  if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>_]').hasMatch(value)) {
    return 'La contraseña debe contener al menos un carácter especial';
  }
  return null;
}

String? validatePhone(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'El teléfono es requerido';
  }
  final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
  if (cleaned.length < 8 || cleaned.length > 15) {
    return 'Ingrese un número de teléfono válido';
  }
  if (!RegExp(r'^[0-9]+$').hasMatch(cleaned)) {
    return 'El teléfono solo debe contener números';
  }
  return null;
}

String? validateName(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'El nombre es requerido';
  }
  if (value.trim().length < 2) {
    return 'El nombre debe tener al menos 2 caracteres';
  }
  if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(value.trim())) {
    return 'El nombre solo debe contener letras';
  }
  return null;
}

String? validateLicensePlate(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'La placa es requerida';
  }
  final cleaned = value.trim().toUpperCase();
  final plateRegex = RegExp(r'^[A-Z]{1,3}[0-9]{3,4}$');
  if (!plateRegex.hasMatch(cleaned.replaceAll(RegExp(r'[\s\-]'), ''))) {
    return 'Ingrese una placa válida (ej: ABC123)';
  }
  return null;
}

String? validateRequired(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Este campo es requerido';
  }
  return null;
}

String? validateNumeric(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Este campo es requerido';
  }
  final cleaned = value.replaceAll(',', '.');
  if (double.tryParse(cleaned) == null) {
    return 'Ingrese un valor numérico válido';
  }
  return null;
}
