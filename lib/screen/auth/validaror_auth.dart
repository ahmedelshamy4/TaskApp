import '../../widgets/toast.dart';

class ValidarorsAuth {
  // * Email Validator
  static String? emailValidator(String value) {
    if (value.isEmpty) {
      showToast(message: 'Email is empty', state: ToastStates.warning);
    } else if (!RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    ).hasMatch(value)) {
      return 'Invalid email';
    }
    if (!value.contains('@')) {
      showToast(
          message: 'The email does not contain @', state: ToastStates.warning);
    }
    if (!value.contains('.')) {
      showToast(
          message: 'The email does not contain .', state: ToastStates.warning);
    }
  }

  // * password Validator
  static String? passwordValidator(String value) {
    if (value.isEmpty) {
      showToast(message: 'password is empty', state: ToastStates.warning);
    }
    RegExp regexp = RegExp(r"^.{6,}$");
    if (!regexp.hasMatch(value)) {
      return 'Password should contain at least 6 characters';
    }
  }
}
