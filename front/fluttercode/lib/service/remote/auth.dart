import 'dart:convert';
import 'package:Consult/model/openvoalleinvoices.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:http/http.dart' as http;

// const url = String.fromEnvironment('BASEURL', defaultValue: '');

class RemoteAuthService {
  var client = http.Client();
  final storage = FlutterSecureStorage();

  final url = dotenv.env["BASEURL"];

  final voalleUrl = dotenv.env["VOALLEBASEURL"];
  final voalleToken = dotenv.env["VOALLETOKEN"];

  final serasaUrl = dotenv.env["SERASABASEURL"];

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

  Future<List<Amount>> getVoalleInvoices({
    required String? cpf,
    required String? voalleToken,
  }) async {
    List<Amount> listItens = [];
    try {
      // Realiza a requisição GET
      var response = await client.get(
        Uri.parse(
            '$voalleUrl:45715/external/integrations/thirdparty/getopentitlesbytxid/$cpf'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $voalleToken",
          'ngrok-skip-browser-warning': "true"
        },
      );

      // Verifica se a resposta foi bem-sucedida
      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        var itemCountResponse = body['response'];
        var messages = body['messages']; // Extrai as mensagens da resposta

        // Verifica se existe alguma mensagem
        if (messages != null && messages.isNotEmpty) {
          // Verifica as mensagens específicas
          for (var message in messages) {
            if (message['message'] == "Cliente não possui títulos em aberto.") {
              Navigator.of(Get.overlayContext!)
                  .pushReplacementNamed('/resultapproved');
              print(
                  'Mensagem: Cliente não possui títulos em aberto. - Redirecionando para tela de aprovado');
              return listItens; // Retorna a lista (pode estar vazia) e interrompe a execução
            } else if (message['message'] == "Registro não encontrado.") {
              // Chama o método para validação do token
              // await getTokenSerasa(
              //   username: '673f3b7ccc4c7437bf49811b',
              //   password: 'cd6d7cf7ikTK0k-6d95-4a12-b168-aa4142742622',
              // );
              // Navigator.of(Get.overlayContext!)
              //     .pushReplacementNamed('/validacaoToken');
              print(
                  'Mensagem: Registro não encontrado. - Redirecionando para tela de validação de token');
              return listItens; // Retorna a lista e interrompe a execução
            }
          }
        }

        // Se a resposta contiver itens válidos
        if (itemCountResponse != null && itemCountResponse.isNotEmpty) {
          for (var i = 0; i < itemCountResponse.length; i++) {
            var item = itemCountResponse[i];
            var status = item['billet']['status']; // Obtém o status do boleto

            // Verifica o status e redireciona para a tela apropriada
            if (status == "Vencida") {
              Navigator.of(Get.overlayContext!)
                  .pushReplacementNamed('/resultnotapproved');
              print('Status Vencido - Redirecionando para tela não aprovado');
              break; // Para a execução se o status for "Vencido"
            } else if (status == "Em aberto") {
              Navigator.of(Get.overlayContext!)
                  .pushReplacementNamed('/resultapproved');
              print('Status Em aberto - Redirecionando para tela aprovado');
              break; // Para a execução se o status for "Em aberto"
            }

            // Coleta todos os itens com 'expirationDate'
            if (item['billet']['expirationDate'] != null) {
              listItens.add(Amount.fromJson(item));
            }
          }
        } else {
          // Se não houver itens, redireciona para tela de aprovado
          Navigator.of(Get.overlayContext!)
              .pushReplacementNamed('/resultapproved');
          print('Nenhum item encontrado ou status não especificado');
        }
      } else {
        // Se a resposta não for 200 (sucesso), lança uma exceção
        throw Exception('Erro ao obter dados: ${response.statusCode}');
      }
    } catch (e) {
      // Trata qualquer erro na requisição ou no processo
      print('Erro na requisição ou ao processar os dados: $e');
    }

    // Retorna a lista (pode estar vazia)
    return listItens;
  }

  Future<String> getTokenVoalle() async {
    // URL da API
    final url = Uri.parse('$voalleUrl:45700/connect/token');

    // Dados do corpo da requisição
    final body = {
      'grant_type': 'client_credentials',
      'scope': 'syngw',
      'client_id': 'df0ee088-5f41-4baa-ba45-1454f23d0dcd',
      'client_secret': '348af78b-4733-4d17-9912-fe44739bd2b0',
      'syndata':
          'TWpNMU9EYzVaakk1T0dSaU1USmxaalprWldFd00ySTFZV1JsTTJRMFptUT06WlhsS1ZHVlhOVWxpTTA0d1NXcHZhVnBZU25kTVdFNHdXVmRrY0dKdFkzbE1iVTUyWW0wMWJGa3pVbWxaVXpWcVlqSXdkVmx1U1dsTVEwcFVaVmMxUlZscFNUWkpiVkpwV2xjeGQwMUVRVEJPUkZwbVl6TlNhRm95YkhWYWVVbHpTV3RTYVZaSWJIZGFVMGsyU1c1Q2RtTXpVbTVqYlZaNlNXNHdQUT09OlpUaGtNak0xWWprMFl6bGlORE5tWkRnM01EbGtNalkyWXpBeE1HTTNNR1U9',
    };

    try {
      // Enviando a requisição POST
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: body,
      );

      // Verificando se a requisição foi bem-sucedida
      if (response.statusCode == 200) {
        // Se a requisição for bem-sucedida, extrai o token
        final data = jsonDecode(response.body);
        return data['access_token']; // Retorna o token
      } else {
        // Se não for bem-sucedida, lança um erro
        throw Exception('Falha ao obter o token: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao fazer a requisição: $e');
    }
  }

  Future<String> getTokenSerasa({
    required String username,
    required String password,
  }) async {
    final serasaUrl = 'https://uat-api.serasaexperian.com.br';

    // Codificar o username:password em Base64
    final credentials = '$username:$password';
    final encodedCredentials = base64Encode(utf8.encode(credentials));

    // Fazer a requisição POST com o cabeçalho de Autenticação Básica
    var response = await http.post(
      Uri.parse('$serasaUrl/security/iam/v1/client-identities/login'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Basic $encodedCredentials",
        'ngrok-skip-browser-warning': "true",
      },
      body: jsonEncode({}),
    );

    // Verificar o status da resposta
    if (response.statusCode == 200) {
      // Decodificar o corpo da resposta JSON
      var responseData = jsonDecode(response.body);

      // Extrair o accessToken
      String accessToken = responseData['accessToken'];

      return accessToken;
    } else {
      // Caso o código de status não seja 200, lançar um erro
      throw Exception(
          'Falha ao obter token. Código de status: ${response.statusCode}');
    }
  }
}
