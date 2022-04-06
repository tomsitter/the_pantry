import 'package:formz/formz.dart';

enum TOUValidationError { invalid }

class TOUCheckbox extends FormzInput<bool, TOUValidationError> {
  const TOUCheckbox.pure() : super.pure(false);
  const TOUCheckbox.dirty([bool value = false]) : super.dirty(value);

  @override
  TOUValidationError? validator(bool? value) {
    return value ?? false == true ? null : TOUValidationError.invalid;
  }
}
