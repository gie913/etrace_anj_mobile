String formatThousandSeparator(int number) {
  int num = number;
  if (num > -1000 && num < 1000)
    return number.toString();

  final String digits = num.abs().toString();
  final StringBuffer result = StringBuffer(num < 0 ? '-' : '');
  final int maxDigitIndex = digits.length - 1;
  for (int i = 0; i <= maxDigitIndex; i += 1) {
    result.write(digits[i]);
    if (i < maxDigitIndex && (maxDigitIndex - i) % 3 == 0)
      result.write(',');
  }
  return result.toString();
}