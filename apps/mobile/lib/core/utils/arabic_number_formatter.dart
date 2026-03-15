abstract final class ArabicNumberFormatter {
  static const _arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

  static String convert(int number) {
    return number.toString().split('').map((d) => _arabicDigits[int.parse(d)]).join();
  }
}
