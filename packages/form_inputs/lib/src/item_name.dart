import 'package:formz/formz.dart';

enum NameValidationError { tooShort }

class ItemName extends FormzInput<String, NameValidationError> {
  const ItemName.pure() : super.pure('');
  const ItemName.dirty([String value = '']) : super.dirty(value);
  static const _minLength = 2;

  @override
  NameValidationError? validator(String? value) {
    return ((value?.length ?? 0) >= _minLength)
        ? null
        : NameValidationError.tooShort;
  }
}
