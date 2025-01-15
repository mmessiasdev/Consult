// import 'dart:convert';

// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class LocalAuthService {
//   final FlutterSecureStorage _storage = FlutterSecureStorage();

//   Future<void> storeToken(String token) async {
//     await _storage.write(key: "token", value: token);
//   }

//   Future<String?> getSecureToken() async {
//     return await _storage.read(key: "token");
//   }

//   // Armazenar CPF do cliente
//   Future<void> storeCpfClient(String cpfClient) async {
//     await _storage.write(key: "cpfClient", value: cpfClient);
//   }

//   // Recuperar CPF do cliente
//   Future<String?> getCpfClient() async {
//     return await _storage.read(key: "cpfClient");
//   }

//   // Armazenar requestId
//   Future<void> storeRequestId(String requestId) async {
//     await _storage.write(key: "requestId", value: requestId);
//   }

//   // Recuperar requestId
//   Future<String?> getRequestId() async {
//     return await _storage.read(key: "requestId");
//   }

//   // Armazenar os dados da conta
//   Future<void> storeAccount({
//     required String email,
//     required String fullname,
//     required int id,
//     required String colaboratorId,
//   }) async {
//     await _storage.write(key: "id", value: id.toString());
//     await _storage.write(key: "email", value: email);
//     await _storage.write(key: "fullname", value: fullname);
//     await _storage.write(key: "colaboratorId", value: colaboratorId);
//   }

//   // Recuperar email
//   Future<String?> getEmail() async {
//     return await _storage.read(key: "email");
//   }

//   // Recuperar ID
//   Future<String?> getId() async {
//     return await _storage.read(key: "id");
//   }

//   // Recuperar fullname
//   Future<String?> getFullName() async {
//     return await _storage.read(key: "fullname");
//   }

//   // Recuperar colaboratorId
//   Future<String?> getColaboratorId() async {
//     return await _storage.read(key: "colaboratorId");
//   }

//   Future<void> clear() async {
//     await _storage
//         .deleteAll(); // Limpa o armazenamento seguro em dispositivos móveis
//   }
// }

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:html' as html;

class LocalAuthService {
  bool _isWeb() {
    try {
      return identical(0, 0.0); // Verificação para Web
    } catch (e) {
      return false;
    }
  }

  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<void> storeToken(String token) async {
    if (_isWeb()) {
      html.window.localStorage['token'] = token;
    } else {
      await _storage.write(key: "token", value: token);
    }
  }

  Future<String?> getSecureToken() async {
    if (_isWeb()) {
      return html.window.localStorage['token'];
    } else {
      return await _storage.read(key: "token");
    }
  }

  // Armazenar CPF do cliente
  Future<void> storeCpfClient(String cpfClient) async {
    if (_isWeb()) {
      html.window.localStorage['cpfClient'] = cpfClient;
    } else {
      await _storage.write(key: "cpfClient", value: cpfClient);
    }
  }

  // Recuperar CPF do cliente
  Future<String?> getCpfClient() async {
    if (_isWeb()) {
      return html.window.localStorage['cpfClient'];
    } else {
      return await _storage.read(key: "cpfClient");
    }
  }

  // Armazenar requestId
  Future<void> storeRequestId(String requestId) async {
    if (_isWeb()) {
      html.window.localStorage['requestId'] = requestId;
    } else {
      await _storage.write(key: "requestId", value: requestId);
    }
  }

  // Recuperar requestId
  Future<String?> getRequestId() async {
    if (_isWeb()) {
      return html.window.localStorage['requestId'];
    } else {
      return await _storage.read(key: "requestId");
    }
  }

  // Armazenar os dados da conta
  Future<void> storeAccount({
    required String email,
    required String fullname,
    required int id,
    required String colaboratorId,
  }) async {
    if (_isWeb()) {
      html.window.localStorage['account'] = jsonEncode({
        "id": id.toString(),
        "email": email,
        "fullname": fullname,
        "colaboratorId": colaboratorId,
      });
    } else {
      await _storage.write(key: "id", value: id.toString());
      await _storage.write(key: "email", value: email);
      await _storage.write(key: "fullname", value: fullname);
      await _storage.write(key: "colaboratorId", value: colaboratorId);
    }
  }

  // Recuperar email
  Future<String?> getEmail() async {
    if (_isWeb()) {
      final account = html.window.localStorage['account'];
      if (account != null) {
        return jsonDecode(account)['email'];
      }
      return null;
    } else {
      return await _storage.read(key: "email");
    }
  }

  // Recuperar ID
  Future<String?> getId() async {
    if (_isWeb()) {
      final account = html.window.localStorage['account'];
      if (account != null) {
        return jsonDecode(account)['id'];
      }
      return null;
    } else {
      return await _storage.read(key: "id");
    }
  }

  // Recuperar fullname
  Future<String?> getFullName() async {
    if (_isWeb()) {
      final account = html.window.localStorage['account'];
      if (account != null) {
        return jsonDecode(account)['fullname'];
      }
      return null;
    } else {
      return await _storage.read(key: "fullname");
    }
  }

  // Recuperar colaboratorId
  Future<String?> getColaboratorId() async {
    if (_isWeb()) {
      final account = html.window.localStorage['account'];
      if (account != null) {
        return jsonDecode(account)['colaboratorId'];
      }
      return null;
    } else {
      return await _storage.read(key: "colaboratorId");
    }
  }

  Future<void> clear() async {
    if (_isWeb()) {
      html.window.localStorage
          .clear(); // Limpa o armazenamento local no navegador
    } else {
      await _storage
          .deleteAll(); // Limpa o armazenamento seguro em dispositivos móveis
    }
  }
}
