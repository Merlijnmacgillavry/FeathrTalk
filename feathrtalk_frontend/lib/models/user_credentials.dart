import 'dart:convert';

import 'package:crypto/crypto.dart';

class UserCredentials {
  late String email;
  late String password;

  UserCredentials(String email, String password) {
    this.email = email;
    this.password = password;
  }

  String get hash {
    List<int> passwordBytes = utf8.encode(this.password);

    // Create a SHA256 hash object
    Digest digest = sha256.convert(passwordBytes);

    // Convert the hash bytes to a hexadecimal string
    String hashedPassword = digest.toString();

    return hashedPassword;
  }
}
