import 'package:formz/formz.dart';

enum PasswordValidationError { empty, less }

class UserPassword extends FormzInput<String, PasswordValidationError> {
  const UserPassword.pure() : super.pure('');
  const UserPassword.dirty([String value = '']) : super.dirty(value);

  @override
  PasswordValidationError? validator(String? value) {
    PasswordValidationError? valid;
    valid = value?.isNotEmpty == true ? null : PasswordValidationError.empty;
    if (valid == null) {
      valid = value!.length > 5 ? null : PasswordValidationError.less;
    }
    return valid;
  }

  String getErrorMessage() {
    var _message = '';
    if (this.error != null) {
      switch (this.error) {
        case PasswordValidationError.empty:
          _message = 'กรุณาป้อนรหัสผ่าน';
          break;
        case PasswordValidationError.less:
          _message = 'รหัสผ่านต้องมากกว่า 5 ตัวอักษร';
          break;
        default:
      }
    }
    return _message;
  }
}
