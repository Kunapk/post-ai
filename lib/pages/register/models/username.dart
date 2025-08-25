 
import 'package:formz/formz.dart';
import 'package:pos/widgets/ui_helper.dart';

enum UserNameValidationError { empty, invalid }

class UserName extends FormzInput<String, UserNameValidationError> {
  const UserName.pure() : super.pure('');
  const UserName.dirty([String value = '']) : super.dirty(value);

  @override
  UserNameValidationError? validator(String? value) {
    UserNameValidationError? valid;
    valid = value?.isNotEmpty == true ? null : UserNameValidationError.empty;
    if (valid == null) {
      if (!isValidEmail(value!)) {
        valid = UserNameValidationError.invalid;
      }
    }
    return valid;
  }

  String getErrorMessage() {
    var _message = '';
    if (this.error != null) {
      switch (this.error) {
        case UserNameValidationError.empty:
          _message = 'กรุณาป้อน email';
          break;
        case UserNameValidationError.invalid:
          _message = 'รูปแบบ email ไม่ถูกต้อง';
          break;
        default:
      }
    }
    return _message;
  }
}
