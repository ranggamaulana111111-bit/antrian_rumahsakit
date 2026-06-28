import '../config/app_constants.dart';

class QueueNumberHelper {
  static String getCode(String poliName) => PoliData.getCode(poliName);

  static String generate(String poliName, int lastCounter) {
    final code = getCode(poliName);
    final number = (lastCounter + 1).toString().padLeft(3, '0');
    return '$code$number';
  }

  static int extractNumber(String nomorAntrean) {
    if (nomorAntrean.length < 4) return 0;
    final numberPart = nomorAntrean.substring(1);
    return int.tryParse(numberPart) ?? 0;
  }
}
