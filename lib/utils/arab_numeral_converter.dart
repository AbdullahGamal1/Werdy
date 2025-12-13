class ArabNumeralConverter {
  static String convert(dynamic number) {
    if (number == null) return "";
    String str = number.toString();
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    for (int i = 0; i < english.length; i++) {
      str = str.replaceAll(english[i], arabic[i]);
    }
    return str;
  }
}

extension ArabicNumerals on int {
  String toArabic() {
    return ArabNumeralConverter.convert(this);
  }
}

extension ArabicNumeralsString on String {
  String toArabic() {
    return ArabNumeralConverter.convert(this);
  }
}
