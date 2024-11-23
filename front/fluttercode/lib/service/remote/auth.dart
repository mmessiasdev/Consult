import 'dart:convert';
import 'package:Consult/model/openvoalleinvoices.dart';
import 'package:Consult/model/serasamodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
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
          '$voalleUrl:45715/external/integrations/thirdparty/getopentitlesbytxid/$cpf',
        ),
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
              EasyLoading.show(
                status: 'Consultando Serasa...',
                dismissOnTap: false,
              );
              // Chama o método para obter o token do Serasa e imprime o token no console
              String tokenSerasa = await getTokenSerasa(
                username: '673f76301345a32c97f7c4c4',
                password: '701b3d5a8MTxwj-96e1-423a-a8ff-c2e69f5dbfaa',
              );
              await getSerasaData(tokenSerasa: tokenSerasa, cpf: cpf);

              print(
                  'Mensagem: Cliente não possui títulos em aberto. - Redirecionando para a verificação do Serasa');

              return listItens; // Retorna a lista (pode estar vazia) e interrompe a execução
            } else if (message['message'] == "Registro não encontrado.") {
              EasyLoading.show(
                status: 'Consultando Serasa...',
                dismissOnTap: false,
              );
              // Chama o método para obter o token do Serasa e imprime o token no console
              String tokenSerasa = await getTokenSerasa(
                username: '673f76301345a32c97f7c4c4',
                password: '701b3d5a8MTxwj-96e1-423a-a8ff-c2e69f5dbfaa',
              );
              await getSerasaData(tokenSerasa: tokenSerasa, cpf: cpf);

              print(
                  'Cliente não encontrado na base. Token do Serasa: $tokenSerasa');

              return listItens; // Retorna a lista com dados do Serasa
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
              addSolicitationInvoiceVoalle(
                  clientId: item['contractNumber'],
                  desc: "com debito em vencimento.",
                  token: voalleToken);
              Navigator.of(Get.overlayContext!)
                  .pushReplacementNamed('/resultnotapprovedvoalle');
              print('Status Vencido - Redirecionando para tela não aprovado');
              break; // Para a execução se o status for "Vencida"
            } else if (status == "Em aberto") {
              Navigator.of(Get.overlayContext!)
                  .pushReplacementNamed('/resultapprovedvoalle');
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
              .pushReplacementNamed('/resultapprovedvoalle');
          print('Nenhum item encontrado ou status não especificado');
        }
      } else {
        EasyLoading.showError(
            'Servidor do Vaolle com instabilidade no momento. Contate seu supervisor e aguarde um momento.');

        // Se a resposta não for 200 (sucesso), lança uma exceção
        throw Exception('Erro ao obter dados: ${response.statusCode}');
      }
    } catch (e) {
      // Trata qualquer erro na requisição ou no processo
      EasyLoading.showError(
          'Erro ao processar dados. Verifique se os dados estão corretos. O sistema não encontrou essa credencial.');
      print('Erro na requisição ou ao processar os dados: $e');
    }

    // Retorna a lista (pode estar vazia)
    return listItens;
  }

  Future<SerasaModel> getSerasaData({
    required String? tokenSerasa,
    required String? cpf,
  }) async {
    List<Reports> listReports = [];
    var response = await client.get(
      Uri.parse(
          'https://api.serasaexperian.com.br/credit-services/person-information-report/v1/creditreport?reportName=RELATORIO_BASICO_PF_PME'), // URL da API
      headers: {
        'Authorization': 'Bearer $tokenSerasa',
        'X-Document-id': '$cpf', // Substitua com o ID do documento
        'Content-Type': 'application/json',
      },
    );

    // Verifica se a resposta foi bem-sucedida
    if (response.statusCode == 200) {
      print("Deu certo!");
      var responseBody = jsonDecode(response.body);
      var reportsData = responseBody['reports'];

      // Se houver dados, adicione-os à lista de relatórios
      if (reportsData != null && reportsData.isNotEmpty) {
        for (var report in reportsData) {
          var reportData = Reports.fromJson(report);

          // Obtém o valor do score
          var score = reportData.score?.score;

          // Verifica se o score é 0 e se todas as variáveis são nulas ou vazias
          var pefinResponse = reportData.negativeData?.pefin?.pefinResponse;
          var refinResponse = reportData.negativeData?.refin?.refinResponse;
          var notaryResponse = reportData.negativeData?.notary?.notaryResponse;
          var checkResponse = reportData.negativeData?.check?.checkResponse;
          var collectionRecordsResponse = reportData
              .negativeData?.collectionRecords?.collectionRecordsResponse;

          // Verifica se todas as variáveis são nulas ou vazias
          bool allNullOrEmpty =
              (pefinResponse == null || pefinResponse.isEmpty) &&
                  (refinResponse == null || refinResponse.isEmpty) &&
                  (notaryResponse == null || notaryResponse.isEmpty) &&
                  (checkResponse == null || checkResponse.isEmpty) &&
                  (collectionRecordsResponse == null ||
                      collectionRecordsResponse.isEmpty);

          // Se o score for 0 e todas as variáveis forem nulas ou vazias, retorna true
          if (score == 0 && allNullOrEmpty) {
            Navigator.of(Get.overlayContext!)
                .pushReplacementNamed('/resultapprovedvoalle');
            print('Score é 0 e todas as respostas estão vazias ou nulas');
            return SerasaModel(reports: listReports); // Retorna após aprovação
          }

          // Se o score for abaixo de 300, retorna false
          if (score != null && score < 300) {
            Navigator.of(Get.overlayContext!)
                .pushReplacementNamed('/scorefailed');
            print('Score abaixo de 300, Score do cliente $score');
            return SerasaModel(reports: listReports); // Retorna após reprovação
          }

          // Se o score for acima de 300 e não for allNullOrEmpty, retorna false e imprime mensagem
          if (score != null && score > 300 && !allNullOrEmpty) {
            Navigator.of(Get.overlayContext!)
                .pushReplacementNamed('/negativehighscore');
            print(
                'Negativado e score acima de 300 e a primeira parcela deve ser paga antecipadamente');
            return SerasaModel(reports: listReports); // Retorna após reprovação
          }

          // Se todas as respostas forem nulas ou vazias, aprova
          if (allNullOrEmpty) {
            Navigator.of(Get.overlayContext!)
                .pushReplacementNamed('/nonegativesucess');
            print('Todas as respostas estão vazias ou nulas');
          } else {
            Navigator.of(Get.overlayContext!)
                .pushReplacementNamed('/negativeclient');
            print('Pelo menos uma resposta não está vazia ou nula');
          }

          // Adiciona o relatório à lista de relatórios
          listReports.add(reportData);
        }
      }

      // Retorna o objeto SerasaModel com a lista de relatórios
      return SerasaModel(reports: listReports);
    } else {
      throw Exception(
          'Erro ao consumir a API do Serasa: ${response.statusCode}');
    }
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

  Future addSolicitationInvoiceVoalle({
    required String? clientId,
    required String? desc,
    required String? token,
  }) async {
    final body = {
      "incidentStatusId": "4",
      "personId": clientId,
      "clientId": clientId,
      "incidentTypeId": 1702,
      "contractServiceTagId": 180391,
      "catalogServiceId": 201,
      "serviceLevelAgreementId": 11,
      "catalogServiceItemId": 1,
      "catalogServiceItemClassId": 1,
      "assignment": {
        "title": "Consulta de dados financeiros",
        "description":
            "Solicitação aberta automaticamente via Connect Consult. Cliente se econtra com $desc",
        "priority": 1,
        "beginningDate": "",
        "finalDate": "",
        "report": {
          "beginningDate": "",
          "finalDate": "",
          "description":
              "Solicitação aberta automaticamente via Connect Consult. Cliente se econtra com $desc",
        },
        "companyPlaceId": 1
      }
    };
    var response = await client.post(
      Uri.parse(
          '$voalleUrl:45715/external/integrations/thirdparty/opendetailedsolicitation'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
        'ngrok-skip-browser-warning': "true"
      },
      body: jsonEncode(body),
    );
    return response;
  }

  Future<String> getTokenSerasa({
    required String username,
    required String password,
  }) async {
    final serasaUrl = 'https://api.serasaexperian.com.br';

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
    if (response.statusCode == 200 || response.statusCode == 201) {
      // Decodificar o corpo da resposta JSON
      var responseData = jsonDecode(response.body);

      // Extrair o accessToken
      String accessToken = responseData['accessToken'];

      return accessToken;
    } else {
      // Caso o código de status não seja 200 ou 201, lançar um erro
      throw Exception(
          'Falha ao obter token. Código de status: ${response.statusCode}');
    }
  }
}
