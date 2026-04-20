class Formatters {
  // Format rupiah: 25000 → "Rp 25.000"
  static String currency(int amount) {
    final formatted = amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return 'Rp $formatted';
  }

  // Format poin: 1500 → "1.500 poin"
  static String points(int pts) {
    final formatted = pts.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return '$formatted poin';
  }

  // Format angka dengan koma: 2450 → "2,450"
  static String commas(int n) {
    return n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }
}
