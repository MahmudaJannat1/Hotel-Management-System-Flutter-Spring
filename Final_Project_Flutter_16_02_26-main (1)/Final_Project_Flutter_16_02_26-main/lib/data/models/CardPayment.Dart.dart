
class CardPayment {
  final String cardNumber;
  final String expiryDate;
  final String cvv;
  final String cardHolderName;

  CardPayment({
    required this.cardNumber,
    required this.expiryDate,
    required this.cvv,
    required this.cardHolderName,
  });

  // Get masked card number for display
  String get maskedCardNumber {
    if (cardNumber.length < 4) return cardNumber;
    return '**** **** **** ${cardNumber.substring(cardNumber.length - 4)}';
  }

  // Validate expiry date (MM/YY format)
  static bool isValidExpiry(String expiry) {
    if (expiry.length != 5) return false;
    if (!expiry.contains('/')) return false;

    try {
      final parts = expiry.split('/');
      if (parts.length != 2) return false;

      final month = int.parse(parts[0]);
      final year = int.parse(parts[1]);

      if (month < 1 || month > 12) return false;

      final now = DateTime.now();
      final currentYear = now.year % 100; // Get last 2 digits of year
      final currentMonth = now.month;

      if (year < currentYear) return false;
      if (year == currentYear && month < currentMonth) return false;

      return true;
    } catch (e) {
      return false;
    }
  }

  // Validate card number (Luhn algorithm)
  static bool isValidCardNumber(String number) {
    final cleaned = number.replaceAll(' ', '');
    if (cleaned.length < 13 || cleaned.length > 19) return false;
    if (!RegExp(r'^\d+$').hasMatch(cleaned)) return false;

    // Luhn algorithm
    int sum = 0;
    bool alternate = false;
    for (int i = cleaned.length - 1; i >= 0; i--) {
      int n = int.parse(cleaned[i]);
      if (alternate) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }
}