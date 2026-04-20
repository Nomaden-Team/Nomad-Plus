class Validators {
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Nama tidak boleh kosong';
    if (value.trim().length < 2) return 'Nama minimal 2 karakter';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email tidak boleh kosong';
    if (!value.contains('@') || !value.contains('.')) {
      return 'Format email tidak valid';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Nomor HP tidak boleh kosong';
    final cleaned = value.replaceAll(RegExp(r'\s|-'), '');
    if (!RegExp(r'^(\+62|62|08)\d{8,12}$').hasMatch(cleaned)) {
      return 'Format HP tidak valid (contoh: 08123456789)';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password tidak boleh kosong';
    if (value.length < 8) return 'Password minimal 8 karakter';
    if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(value)) {
      return 'Password harus kombinasi huruf dan angka';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Konfirmasi password tidak boleh kosong';
    if (value != password) return 'Password tidak sama';
    return null;
  }
}