import 'dart:convert';
import 'dart:math';
import 'package:Consult/model/openvoalleinvoices.dart';
import 'package:Consult/model/serasamodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:http/http.dart' as http;

// const $cmsBaseUrl = String.fromEnvironment('BASEURL', defaultValue: '');

class RemoteAuthService {
  final cmsBaseUrl = dotenv.env["CMSBASEURL"];

  final voalleBaseUrl = dotenv.env["VOALLEBASEURL"];
  final voalleSynData = dotenv.env["SYNDATA"];
  final clientIdVoalle = dotenv.env["CLIENTIDVOALLE"];
  final clientSecretVoalle = dotenv.env["CLIENTSECRETVOALLE"];

  final serasaBaseUrl = dotenv.env["SERASABASEURL"];
  final usernameSerasa = dotenv.env["USERNAMESERASA"];
  final passwordSerasa = dotenv.env["PASSWORDSERASA"];

  var client = http.Client();
  final storage = FlutterSecureStorage();

  Future<dynamic> signUp(
      {required String email,
      required String password,
      required String username}) async {
    var body = {"username": username, "email": email, "password": password};
    var response = await client.post(
      Uri.parse('$cmsBaseUrl/auth/local/register'),
      headers: {
        "Content-Type": "application/json",
        'ngrok-skip-browser-warning': "true"
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
      Uri.parse('$cmsBaseUrl/auth/local'),
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
      Uri.parse('$cmsBaseUrl/profiles/me'),
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
      Uri.parse('$cmsBaseUrl/profiles/me'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
        'ngrok-skip-browser-warning': "true"
      },
    );
  }

  Future addRequests({
    required String? colaboratorname,
    required String? cpf,
    required String? token,
  }) async {
    final body = {
      "colaboratorname": colaboratorname,
      "cpf": cpf,
      "result": "Result",
    };
    var response = await client.post(
      Uri.parse('$cmsBaseUrl/requests'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
        'ngrok-skip-browser-warning': "true"
      },
      body: jsonEncode(body),
    );
    return response;
  }

  Future putRequests({
    required String? token,
    required String? result,
    required String? id,
  }) async {
    final body = {
      "result": result,
    };
    var response = await client.put(
      Uri.parse('$cmsBaseUrl/requests/$id'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
        'ngrok-skip-browser-warning': "true"
      },
      body: jsonEncode(body),
    );
    return response;
  }

  Future putAddRequests({
    required String? id,
    required String? result,
    required String? token,
  }) async {
    final body = {
      "result": result,
    };
    var response = await client.put(
      Uri.parse('$cmsBaseUrl/requests/$id'),
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
    required String? colaboratorId,
  }) async {
    List<Amount> listItens = [];
    try {
      // Realiza a requisição GET
      var response = await client.get(
        Uri.parse(
          '${voalleBaseUrl}:45715/external/integrations/thirdparty/getopentitlesbytxid/$cpf',
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
        var succes = body['success'];

        if (messages == null) {
          EasyLoading.show(
            status: 'Consultando Serasa...',
            dismissOnTap: false,
          );
          // Chama o método para obter o token do Serasa e imprime o token no console
          String tokenSerasa = await getTokenSerasa(
            username: '${usernameSerasa}',
            password: '${passwordSerasa}',
          );
          await getSerasaData(tokenSerasa: tokenSerasa, cpf: cpf);
          print(
              'Fazendo consulta, cliente possui conexão com faturas vencidas');
        } else if (messages != null) {
          // Verifica as mensagens específicas
          for (var message in messages) {
            if (message['message'] == "Cliente não possui títulos em aberto.") {
              int? clientId =
                  await getClientCredentials(cpf: cpf, token: voalleToken);
              addSolicitationInvoiceVoalle(
                clientId: clientId.toString(),
                colaboratorId: colaboratorId,
                desc: "sem pendências até a data da consulta.",
                token: voalleToken,
              );
              Navigator.of(Get.overlayContext!)
                  .pushReplacementNamed('/resultapprovedvoalle');
              print(
                'Cliente sem faturas em aberto, paga em dias - Redirecionando para tela aprovado',
              );
              return listItens; // Retorna a lista (pode estar vazia) e interrompe a execução
            } else if (message['message'] == "Registro não encontrado.") {
              EasyLoading.show(
                status: 'Possui Lead criado no Voalle',
                dismissOnTap: false,
              );
              EasyLoading.show(
                status: 'Consultando Serasa...',
                dismissOnTap: false,
              );
              // Chama o método para obter o token do Serasa e imprime o token no console
              String tokenSerasa = await getTokenSerasa(
                username: '${usernameSerasa}',
                password: '${passwordSerasa}',
              );
              await getSerasaData(tokenSerasa: tokenSerasa, cpf: cpf);
              print(
                  'Fazendo consulta, cliente não possui registro de faturas geradas');
              print(
                  'Cliente não encontrado na base. Acessando Serasa');
            } // Se a resposta contiver itens válidos
            if (itemCountResponse != null && itemCountResponse.isNotEmpty) {
              for (var i = 0; i < itemCountResponse.length; i++) {
                var item = itemCountResponse[i];
                var status =
                    item['billet']['status']; // Obtém o status do boleto

                // Verifica o status e redireciona para a tela apropriada
                if (status == "Vencida") {
                  int? clientId =
                      await getClientCredentials(cpf: cpf, token: voalleToken);
                  addSolicitationInvoiceVoalle(
                      clientId: clientId.toString(),
                      colaboratorId: colaboratorId,
                      desc: "com debito em vencimento.",
                      token: voalleToken);
                  Navigator.of(Get.overlayContext!)
                      .pushReplacementNamed('/resultnotapprovedvoalle');
                  print(
                      'Status Vencido - Redirecionando para tela não aprovado');
                  break; // Para a execução se o status for "Vencida"
                } else if (status == "Em aberto") {
                  int? clientId =
                      await getClientCredentials(cpf: cpf, token: voalleToken);
                  addSolicitationInvoiceVoalle(
                    clientId: clientId.toString(),
                    colaboratorId: colaboratorId,
                    desc: "com debito em vencimento.",
                    token: voalleToken,
                  );
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
            }
          }
        }
      } else {
        EasyLoading.showError(
            'Servidor do Voalle com instabilidade no momento. Contate seu supervisor e aguarde um momento.');

        // Se a resposta não for 200 (sucesso), lança uma exceção
        throw Exception('Erro ao obter dados: ${response.statusCode}');
      }
    } catch (e) {
      // Trata qualquer erro na requisição ou no processo
      EasyLoading.showError(
          'Erro ao processar dados. Verifique se os dados estão corretos. O sistema não encontrou essa credencial.');
    }

    // Retorna a lista (pode estar vazia)
    return listItens;
  }

  Future<String> getTokenVoalle() async {
    // $cmsBaseUrl da API
    final url = Uri.parse('${voalleBaseUrl}:45700/connect/token');

    // Dados do corpo da requisição
    final body = {
      'grant_type': 'client_credentials',
      'scope': 'syngw',
      'client_id': '${clientIdVoalle}',
      'client_secret': '${clientSecretVoalle}',
      'syndata': '${voalleSynData}',
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

  Future<int?> getClientCredentials({
    required String? cpf,
    required String? token,
  }) async {
    var response = await client.get(
      Uri.parse(
          '${voalleBaseUrl}:45715/external/integrations/thirdparty/people/txid/$cpf'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      print('Cliente encontrado');
      var body = jsonDecode(response.body);
      var itemResponse = body['response'];
      int clientId = itemResponse['id']; // Aqui estamos pegando o 'id'
      return clientId; // Retorna o clientId para ser usado na próxima requisição
    } else {
      print('Erro na pesquisa do cliente');
      return null; // Retorna null em caso de erro
    }
  }

  Future addSolicitationInvoiceVoalle({
    required String? clientId, // clientId recebido
    required String? desc,
    required String? token,
    required String? colaboratorId,
  }) async {
    final body = {
      "incidentStatusId": "4",
      "personId": clientId, // Aqui você usa o clientId
      "clientId": clientId, // E aqui também
      "incidentTypeId": 1702,
      "contractServiceTagId": 180391,
      "catalogServiceId": 201,
      "serviceLevelAgreementId": 11,
      "catalogServiceItemId": 1,
      "catalogServiceItemClassId": 1,
      "assignment": {
        "title": "Consulta de dados financeiros",
        "description":
            "Solicitação aberta automaticamente via Connect Consult APP. Cliente se encontra $desc",
        "priority": 1,
        "beginningDate": "",
        "finalDate": "",
        "report": {
          "beginningDate": "",
          "finalDate": "",
          "description":
              "Solicitação aberta automaticamente via Connect Consult APP. Cliente se encontra $desc",
        },
        "companyPlaceId": 1
      }
    };

    try {
      // Fazendo a requisição POST
      var response = await client.post(
        Uri.parse(
            '${voalleBaseUrl}:45715/external/integrations/thirdparty/opendetailedsolicitation'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('Get adicionado ao Voalle');
        var body = jsonDecode(response.body);
        var itemResponse = body['response'];
        return response; // Retorna a resposta da requisição
      } else {
        print('Erro no Voalle, Status Code: ${response.statusCode}');
        return null; // Retorna null em caso de erro
      }
    } catch (e) {
      print('Erro na requisição ao Voalle: $e');
      return null; // Retorna null caso ocorra uma exceção
    }
  }

  Future<String> getTokenSerasa({
    required String username,
    required String password,
  }) async {
    // Codificar o username:password em Base64
    final credentials = '${usernameSerasa}:${passwordSerasa}';
    final encodedCredentials = base64Encode(utf8.encode(credentials));

    // Fazer a requisição POST com o cabeçalho de Autenticação Básica
    var response = await http.post(
      Uri.parse('${serasaBaseUrl}/security/iam/v1/client-identities/login'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Basic $encodedCredentials",
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

  Future<SerasaModel> getSerasaData({
    required String? tokenSerasa,
    required String? cpf,
  }) async {
    List<Reports> listReports = [];
    var response = await client.get(
      Uri.parse(
          '${serasaBaseUrl}/credit-services/person-information-report/v1/creditreport?reportName=RELATORIO_BASICO_PF_PME'), // $cmsBaseUrl da API
      headers: {
        'Authorization': 'Bearer $tokenSerasa',
        'X-Document-id': '$cpf', // Substitua com o ID do documento
        'Content-Type': 'application/json',
      },
    );

    // Verifica se a resposta foi bem-sucedida
    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      var reportsData = responseBody['reports'];

      if (reportsData != null && reportsData.isNotEmpty) {
        for (var report in reportsData) {
          var reportData = Reports.fromJson(report);

          // Obtém o valor do score
          var score = reportData.score?.score;

          var pefinResponse = report['negativeData']['pefin']['pefinResponse'];
          var refinResponse = report['negativeData']['refin']['refinResponse'];
          var notaryResponse =
              report['negativeData']['notary']['notaryResponse'];
          var checkResponse = report['negativeData']['check']['checkResponse'];
          var collectionRecordsResponse = report['negativeData']
              ['collectionRecords']['collectionRecordsResponse'];

          // Função auxiliar para verificar se a lista contém dados significativos
          bool hasData(List? response) {
            // Verifica se a lista não é nula e tem pelo menos um item com dados
            return response != null &&
                response.isNotEmpty &&
                response.any((e) => e != null);
          }

          // Verifica se todas as variáveis são nulas ou vazias
          bool allNullOrEmpty =
              (pefinResponse == null || pefinResponse.isEmpty) &&
                  (refinResponse == null ||
                      refinResponse.isEmpty ||
                      refinResponse.every((e) => e == null)) &&
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
            print(score);
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
}
