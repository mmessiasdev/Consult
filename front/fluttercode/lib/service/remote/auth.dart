import 'dart:convert';
import 'package:Consult/model/openvoalleinvoices.dart';
import 'package:Consult/model/serasamodel.dart';
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
              Navigator.of(Get.overlayContext!)
                  .pushReplacementNamed('/resultapprovedvoalle');
              print(
                  'Mensagem: Cliente não possui títulos em aberto. - Redirecionando para tela de aprovado');

              return listItens; // Retorna a lista (pode estar vazia) e interrompe a execução
            } else if (message['message'] == "Registro não encontrado.") {
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
              Navigator.of(Get.overlayContext!)
                  .pushReplacementNamed('/resultnotapproved');
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
            print('Score abaixo de 300');
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

  // Future<SerasaModel> getSerasaData({
  //   required String? tokenSerasa,
  //   required String? cpf,
  // }) async {
  //   List<Reports> listReports = [];
  //   var response = await client.get(
  //     Uri.parse(
  //         'https://api.serasaexperian.com.br/credit-services/person-information-report/v1/creditreport?reportName=RELATORIO_BASICO_PF_PME'), // URL da API
  //     headers: {
  //       'Authorization': 'Bearer $tokenSerasa',
  //       'X-Document-id': '$cpf', // Substitua com o ID do documento
  //       'Content-Type': 'application/json',
  //     },
  //   );

  //   // Verifica se a resposta foi bem-sucedida
  //   if (response.statusCode == 200) {
  //     print("Deu certo!");
  //     var responseBody = jsonDecode(response.body);
  //     var reportsData = responseBody['reports'];

  //     // Se houver dados, adicione-os à lista de relatórios
  //     if (reportsData != null && reportsData.isNotEmpty) {
  //       for (var report in reportsData) {
  //         var reportData = Reports.fromJson(report);

  //         // Verifica e consome os dados de pefinResponse, refinResponse, etc.
  //         var pefinResponse = reportData.negativeData?.pefin?.pefinResponse;
  //         var refinResponse = reportData.negativeData?.refin?.refinResponse;
  //         var notaryResponse = reportData.negativeData?.notary?.notaryResponse;
  //         var checkResponse = reportData.negativeData?.check?.checkResponse;
  //         var collectionRecordsResponse = reportData
  //             .negativeData?.collectionRecords?.collectionRecordsResponse;

  //         // Verifica se todas as respostas são nulas ou vazias
  //         if (pefinResponse == null || pefinResponse.isEmpty) {
  //           print('pefinResponse está vazio ou nulo');
  //         }
  //         if (refinResponse == null || refinResponse.isEmpty) {
  //           print('refinResponse está vazio ou nulo');
  //         }
  //         if (notaryResponse == null || notaryResponse.isEmpty) {
  //           print('notaryResponse está vazio ou nulo');
  //         }
  //         if (checkResponse == null || checkResponse.isEmpty) {
  //           print('checkResponse está vazio ou nulo');
  //         }
  //         if (collectionRecordsResponse == null ||
  //             collectionRecordsResponse.isEmpty) {
  //           print('collectionRecordsResponse está vazio ou nulo');
  //         }

  //         // Verifica se todas as variáveis são nulas ou vazias
  //         bool allNullOrEmpty =
  //             (pefinResponse == null || pefinResponse.isEmpty) &&
  //                 (refinResponse == null || refinResponse.isEmpty) &&
  //                 (notaryResponse == null || notaryResponse.isEmpty) &&
  //                 (checkResponse == null || checkResponse.isEmpty) &&
  //                 (collectionRecordsResponse == null ||
  //                     collectionRecordsResponse.isEmpty);

  //         // Retorna true se todas forem nulas ou vazias, caso contrário, retorna false
  //         if (allNullOrEmpty) {
  //           Navigator.of(Get.overlayContext!)
  //               .pushReplacementNamed('/resultapprovedvoalle');
  //           print('Todas as respostas estão vazias ou nulas');
  //         } else {
  //           Navigator.of(Get.overlayContext!)
  //               .pushReplacementNamed('/resultnotapproved');
  //           print('Pelo menos uma resposta não está vazia ou nula');
  //         }

  //         // Adiciona o relatório à lista de relatórios
  //         listReports.add(reportData);
  //       }
  //     }

  //     // Retorna o objeto SerasaModel com a lista de relatórios
  //     return SerasaModel(reports: listReports);
  //   } else {
  //     throw Exception(
  //         'Erro ao consumir a API do Serasa: ${response.statusCode}');
  //   }
  // }

  // Future<SerasaModel> getSerasaData({
  //   required String? tokenSerasa,
  //   required String? cpf,
  // }) async {
  //   List<Reports> listReports = [];
  //   var response = await client.get(
  //     Uri.parse(
  //         'https://api.serasaexperian.com.br/credit-services/person-information-report/v1/creditreport?reportName=RELATORIO_BASICO_PF_PME'), // URL da API
  //     headers: {
  //       'Authorization': 'Bearer $tokenSerasa',
  //       'X-Document-id': '$cpf', // Substitua com o ID do documento
  //       'Content-Type': 'application/json',
  //     },
  //   );

  //   // Verifica se a resposta foi bem-sucedida
  //   if (response.statusCode == 200) {
  //     print("Deu certo!");
  //     var responseBody = jsonDecode(response.body);
  //     var reportsData = responseBody['reports'];

  //     // Se houver dados, adicione-os à lista de relatórios
  //     if (reportsData != null && reportsData.isNotEmpty) {
  //       for (var report in reportsData) {
  //         var reportData = Reports.fromJson(report);

  //         // Imprime o valor do score
  //         if (reportData.score != null) {
  //           print('Score do cliente: ${reportData.score!.score}');
  //         }

  //         // Verifica e consome os dados de pefinResponse com segurança
  //         var pefinResponse = reportData.negativeData?.pefin?.pefinResponse;
  //         var refinResponse = reportData.negativeData?.refin?.refinResponse;
  //         var notaryResponse = reportData.negativeData?.notary?.notaryResponse;
  //         var checkResponse = reportData.negativeData?.check?.checkResponse;
  //         var collectionRecordsResponse = reportData
  //             .negativeData?.collectionRecords?.collectionRecordsResponse;

  //         if (pefinResponse != null && pefinResponse.isNotEmpty) {
  //           print('Devendo Pefin');
  //           // for (var pefin in pefinResponse) {
  //           //   print('Data da Ocorrência: ${pefin.occurrenceDate}');
  //           //   print('Credor: ${pefin.creditorName}');
  //           //   print('Valor: ${pefin.amount}');
  //           //   print('Contrato: ${pefin.contractId}');
  //           //   print('Natureza Legal: ${pefin.legalNature}');
  //           //   print('-----------------------------------');
  //           // }
  //         } else {
  //           print('pefinResponse está vazio ou nulo');
  //         }

  //         // Adiciona o relatório à lista de relatórios
  //         listReports.add(reportData);
  //       }
  //     }

  //     // Retorna o objeto SerasaModel com a lista de relatórios
  //     return SerasaModel(reports: listReports);
  //   } else {
  //     throw Exception(
  //         'Erro ao consumir a API do Serasa: ${response.statusCode}');
  //   }
  // }

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



// {
//     "reports": [
//         {
//             "reportName": "RELATORIO_BASICO_PF_PME",
//             "registration": {
//                 "documentNumber": "19160445572",
//                 "consumerName": "LUCINEIDE MARIA SANTOS ALVES PEREIRA",
//                 "motherName": "SEVERINA MARIA DOS SANTOS",
//                 "birthDate": "1960-07-09",
//                 "statusRegistration": "REGULAR",
//                 "statusDate": "2024-07-26"
//             },
//             "negativeData": {
//                 "pefin": {
//                     "pefinResponse": [],
//                     "summary": {
//                         "count": 0,
//                         "balance": 0.0
//                     }
//                 },
//                 "refin": {
//                     "refinResponse": [],
//                     "summary": {
//                         "count": 0,
//                         "balance": 0.0
//                     }
//                 },
//                 "notary": {
//                     "notaryResponse": [],
//                     "summary": {
//                         "count": 0,
//                         "balance": 0.0
//                     }
//                 },
//                 "check": {
//                     "checkResponse": [],
//                     "summary": {
//                         "count": 0,
//                         "balance": 0.0
//                     }
//                 },
//                 "collectionRecords": {
//                     "collectionRecordsResponse": [],
//                     "summary": {
//                         "count": 0,
//                         "balance": 0.0
//                     }
//                 }
//             },
//             "score": {
//                 "score": 943,
//                 "scoreModel": "HRLN",
//                 "range": "A",
//                 "defaultRate": "3,70",
//                 "codeMessage": 99,
//                 "message": "ESPACO RESERVADO PARA MENSAGEM DA INSTITUICAO"
//             },
//             "facts": {
//                 "inquiry": {
//                     "inquiryResponse": [
//                         {
//                             "occurrenceDate": "2024-04-27",
//                             "segmentDescription": "VAREJO DIVERSOS",
//                             "daysQuantity": 1
//                         },
//                         {
//                             "occurrenceDate": "2024-04-02",
//                             "segmentDescription": "ATACADO DURAVEL",
//                             "daysQuantity": 1
//                         },
//                         {
//                             "occurrenceDate": "2024-01-11",
//                             "segmentDescription": "BANCOS GIGANTES",
//                             "daysQuantity": 1
//                         },
//                         {
//                             "occurrenceDate": "2024-01-02",
//                             "segmentDescription": "VAREJO DE SUPERMERCADOS",
//                             "daysQuantity": 1
//                         },
//                         {
//                             "occurrenceDate": "2023-12-18",
//                             "segmentDescription": "PEQUENOS BANCOS",
//                             "daysQuantity": 1
//                         }
//                     ],
//                     "summary": {
//                         "count": 5
//                     }
//                 },
//                 "inquirySummary": {
//                     "inquiryQuantity": {
//                         "actual": 0,
//                         "creditInquiriesQuantity": [
//                             {
//                                 "inquiryDate": "2024-10",
//                                 "occurrences": 0
//                             },
//                             {
//                                 "inquiryDate": "2024-09",
//                                 "occurrences": 0
//                             },
//                             {
//                                 "inquiryDate": "2024-08",
//                                 "occurrences": 0
//                             },
//                             {
//                                 "inquiryDate": "2024-07",
//                                 "occurrences": 0
//                             }
//                         ]
//                     }
//                 },
//                 "stolenDocuments": {
//                     "stolenDocumentsResponse": [],
//                     "summary": {
//                         "count": 0,
//                         "balance": 0.0
//                     }
//                 }
//             },
//             "partner": {
//                 "partnershipResponse": [
//                     {
//                         "businessDocument": "04961171000138",
//                         "companyName": "LUCINEIDE MARIA SANTOS ALVES PEREIRA ME",
//                         "participationPercentage": 100.0,
//                         "companyStatus": "INAPTA",
//                         "companyStatusCode": "0",
//                         "companyState": "BA",
//                         "companyStatusDate": "2024-08-10",
//                         "updateDate": "2024-08-28",
//                         "hasNegative": false
//                     }
//                 ],
//                 "summary": {
//                     "count": 1,
//                     "balance": 0.0
//                 }
//             }
//         }
//     ]
// }






// {
//     "reports": [
//         {
//             "reportName": "RELATORIO_BASICO_PF_PME",
//             "registration": {
//                 "documentNumber": "05112332565",
//                 "consumerName": "MARIA APARECIDA ROCHA",
//                 "motherName": "IRACI MARIA LOPES",
//                 "birthDate": "1979-06-18",
//                 "statusRegistration": "REGULAR",
//                 "statusDate": "2024-08-31"
//             },
//             "negativeData": {
//                 "pefin": {
//                     "pefinResponse": [
//                         {
//                             "occurrenceDate": "2022-03-16",
//                             "legalNatureId": "CD",
//                             "legalNature": "CREDIARIO",
//                             "contractId": "0000079674702P01",
//                             "creditorName": "MAGAZINE LUIZA",
//                             "amount": 416.64,
//                             "principal": true
//                         },
//                         {
//                             "occurrenceDate": "2021-07-25",
//                             "legalNatureId": "OO",
//                             "legalNature": "OUTRAS OPER",
//                             "contractId": "0000000000183168",
//                             "creditorName": "HE NET TELECOMUNICACOES LTDA EPP",
//                             "amount": 418.51,
//                             "principal": true
//                         }
//                     ],
//                     "summary": {
//                         "count": 2,
//                         "balance": 835.15,
//                         "firstOccurrence": "2021-07-25",
//                         "lastOccurrence": "2022-03-16"
//                     }
//                 },
//                 "refin": {
//                     "refinResponse": [],
//                     "summary": {
//                         "count": 0,
//                         "balance": 0.0
//                     }
//                 },
//                 "notary": {
//                     "notaryResponse": [],
//                     "summary": {
//                         "count": 0,
//                         "balance": 0.0
//                     }
//                 },
//                 "check": {
//                     "checkResponse": [],
//                     "summary": {
//                         "count": 0,
//                         "checkCount": 0,
//                         "balance": 0.0
//                     }
//                 },
//                 "collectionRecords": {
//                     "collectionRecordsResponse": [],
//                     "summary": {
//                         "count": 0,
//                         "balance": 0.0
//                     }
//                 }
//             },
//             "score": {
//                 "score": 350,
//                 "scoreModel": "HRLN",
//                 "range": "G",
//                 "defaultRate": "35,90",
//                 "codeMessage": 99,
//                 "message": "ESPACO RESERVADO PARA MENSAGEM DA INSTITUICAO"
//             },
//             "negativeSummary": {},
//             "facts": {
//                 "inquiry": {
//                     "inquiryResponse": [
//                         {
//                             "occurrenceDate": "2024-11-20",
//                             "segmentDescription": "SERVICOS DE TELECOM",
//                             "daysQuantity": 1
//                         }
//                     ],
//                     "summary": {
//                         "count": 1
//                     }
//                 },
//                 "inquirySummary": {
//                     "inquiryQuantity": {
//                         "actual": 1,
//                         "creditInquiriesQuantity": [
//                             {
//                                 "inquiryDate": "2024-10",
//                                 "occurrences": 0
//                             },
//                             {
//                                 "inquiryDate": "2024-09",
//                                 "occurrences": 0
//                             },
//                             {
//                                 "inquiryDate": "2024-08",
//                                 "occurrences": 0
//                             },
//                             {
//                                 "inquiryDate": "2024-07",
//                                 "occurrences": 0
//                             }
//                         ]
//                     }
//                 },
//                 "stolenDocuments": {
//                     "stolenDocumentsResponse": [],
//                     "summary": {
//                         "count": 0,
//                         "balance": 0.0
//                     }
//                 }
//             },
//             "partner": {
//                 "summary": {
//                     "count": 0,
//                     "balance": 0.0
//                 }
//             }
//         }
//     ]
// }