class CurrencyFormatter {
  static String format(double amount) {
    return '৳ ${amount.toStringAsFixed(0)}';
  }

  static String formatWithDecimal(double amount) {
    return '৳ ${amount.toStringAsFixed(2)}';
  }

  static String formatCompact(double amount) {
    if (amount >= 1000000) {
      return '৳ ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '৳ ${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '৳ ${amount.toStringAsFixed(0)}';
  }
}