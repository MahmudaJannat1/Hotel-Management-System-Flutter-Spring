class Validators {
  static bool isEmail(String email) {
    return RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(email);
  }

  static bool isPhone(String phone) {
    return RegExp(
      r'^[0-9+\-\s]{10,15}$',
    ).hasMatch(phone);
  }
}