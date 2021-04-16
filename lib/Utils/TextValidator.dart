class TextValidator {
  static final RegExp VALIDATOR_START_ALPHANUMERIC = RegExp(r'^([a-zA-Z0-9])(.*)+$');
  static final RegExp VALIDATOR_START_ALPHABETIC = RegExp(r'^([a-zA-Z])(.*)+$');
  static final RegExp VALIDATOR_ALL_ALPHANUMERIC = RegExp(r'^([a-zA-Z0-9])+$');
  static final RegExp VALIDATOR_ALL_NUMERIC = RegExp(r'^([0-9])+$');
  static final VALIDATOR_CONTAINS_EMOJI =
      RegExp(r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])');

  static bool validate(
    String text,
    List<RegExp> validators, {
    List<RegExp> negativeValidators = const [],
    int minLength = 0,
    bool trimText = true,
  }) {
    if (trimText) text = text.trim();
    if (text.length < minLength) return false;

    for (RegExp validator in validators) {
      if (!validator.hasMatch(text)) return false;
    }

    for (RegExp validator in negativeValidators) {
      if (validator.hasMatch(text)) return false;
    }

    return true;
  }
}
