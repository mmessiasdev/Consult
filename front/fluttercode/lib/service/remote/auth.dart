import 'dart:convert';
import 'package:Benefeer/model/categories.dart';
import 'package:Benefeer/model/localstoriesverifiquedbuy.dart';
import 'package:Benefeer/model/plans.dart';
import 'package:Benefeer/model/localstores.dart';

import 'package:Benefeer/model/postsnauth.dart';
import 'package:Benefeer/model/profiles.dart';
import 'package:Benefeer/model/stores.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:Benefeer/model/postFiles.dart';
import 'package:http/http.dart' as http;

// const url = String.fromEnvironment('BASEURL', defaultValue: '');

class RemoteAuthService {
  var client = http.Client();
  final storage = FlutterSecureStorage();
  final url = dotenv.env["BASEURL"];

  Future<dynamic> signUp(
      {required String email,
      required String password,
      required String username}) async {
    var body = {"username": username, "email": email, "password": password};
    var response = await client.post(
      Uri.parse('$url/auth/local/register'),
      headers: {
        "Content-Type": "application/json",
        "ngrok-skip-browser-warning": "true"
      },
      body: jsonEncode(body),
    );
    return response;
  }

  Future<dynamic> signIn({
    required String email,
    required String password,
  }) async {
    var body = {"identifier": email, "password": password};
    var response = await client.post(
      Uri.parse('$url/auth/local'),
      headers: {
        "Content-Type": "application/json",
        'ngrok-skip-browser-warning': "true"
      },
      body: jsonEncode(body),
    );
    return response;
  }

  Future<dynamic> createProfile({
    required String fullname,
    required String token,
  }) async {
    var body = {
      "fullname": fullname,
    };
    var response = await client.post(
      Uri.parse('$url/profiles/me'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
        'ngrok-skip-browser-warning': "true"
      },
      body: jsonEncode(body),
    );
    return response;
  }

  Future<http.Response> getProfile({
    required String token,
  }) async {
    // Faz a chamada GET e retorna o objeto Response diretamente
    return await client.get(
      Uri.parse('$url/profiles/me'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
        'ngrok-skip-browser-warning': "true",
      },
    );
  }

  Future addRequests({
    required String? colaboratorname,
    required String? cpf,
    required String? token,
    required String? resultReq,
  }) async {
    final body = {
      "colaboratorname": colaboratorname,
      "cpf": cpf,
      "result": resultReq,
    };
    var response = await client.post(
      Uri.parse('$url/requests'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
        'ngrok-skip-browser-warning': "true"
      },
      body: jsonEncode(body),
    );
    return response;
  }
}
