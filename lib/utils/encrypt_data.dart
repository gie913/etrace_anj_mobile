import 'package:encrypt/encrypt.dart';

class EncryptData {

  String encryptData(String data) {
    final key = Key.fromUtf8('epms123456789012');
    final iv = IV.fromUtf8('epms123456789012');
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(data, iv: iv);
    return encrypted.base64;
  }

  String decryptData(String data) {
    Encrypted encrypted = Encrypted.from64(data);
    final key = Key.fromUtf8('epms123456789012');
    final iv = IV.fromUtf8('epms123456789012');
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final decrypted = encrypter.decrypt(encrypted, iv: iv);
    return decrypted;
  }
}
