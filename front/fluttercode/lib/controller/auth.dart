import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:Consult/service/local/auth.dart';
import 'package:Consult/service/remote/auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  String? urlEnv = dotenv.env["BASEURL"];
  String? authSerasa = dotenv.env["AUTHSERASA"];

  @override
  void onInit() async {
    super.onInit();
  }

  void signUp({
    required String fullname,
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      // Mostrar loading
      EasyLoading.show(
        status: 'Loading...',
        dismissOnTap: false,
      );

      // Chamar o serviço de autenticação para registrar o usuário
      var result = await RemoteAuthService().signUp(
        email: email,
        username: username,
        password: password,
      );

      // Verificar se a resposta foi bem-sucedida
      if (result.statusCode == 200) {
        // Extrair o token JWT da resposta
        String token = json.decode(result.body)['jwt'];

        // Fazer a requisição para criar o perfil
        var userResult = await RemoteAuthService().createProfile(
          fullname: fullname,
          token: token,
        );

        // Verificar se a criação do perfil foi bem-sucedida
        if (userResult.statusCode == 200) {
          EasyLoading.showSuccess("Conta criada. Confirme suas informações.");
          // Redirecionar para a tela de login
          Navigator.of(Get.overlayContext!).pushReplacementNamed('/login');
        } else {
          // Mostrar erro se a criação do perfil falhou
          EasyLoading.showError('Alguma coisa deu errado. Tente novamente!');
        }
      } else {
        // Mostrar erro se o registro do usuário falhou
        EasyLoading.showError('Alguma coisa deu errado. Tente novamente!');
      }
    } catch (e) {
      // Mostrar erro em caso de exceção
      EasyLoading.showError('Alguma coisa deu errado. Tente novamente!');
    } finally {
      // Fechar o loading
      EasyLoading.dismiss();
    }
  }

  void signIn({required String email, required String password}) async {
    try {
      EasyLoading.show(
        status: 'Loading...',
        dismissOnTap: false,
      );

      // Faz a chamada para signIn
      var result = await RemoteAuthService().signIn(
        email: email,
        password: password,
      );

      if (result.statusCode == 200) {
        // Pega o token do corpo da resposta
        String token = json.decode(result.body)['jwt'];

        // Faz a chamada para getProfile
        var userResult = await RemoteAuthService().getProfile(token: token);

        if (userResult.statusCode == 200) {
          // Decodifica o corpo da resposta (apenas depois de checar o statusCode)
          var userData = jsonDecode(userResult.body);

          var email = userData['email'];
          var id = userData['id'];
          var fullname = userData['fullname'];
          var colaboratorId = userData['personidvoalle'];

          print('MOSTAR ID DO COLABORADOR $colaboratorId');

          await LocalAuthService().storeToken(token);
          await LocalAuthService().storeAccount(
            id: id,
            email: email,
            fullname: fullname,
            colaboratorId: colaboratorId.toString(),
          );

          var tokenStore = LocalAuthService().getSecureToken();

          print(tokenStore);

          EasyLoading.showSuccess("Bem vindo ao Consult");
          Navigator.of(Get.overlayContext!).pushReplacementNamed('/');
        } else {
          EasyLoading.showError(
              'Alguma coisa deu errado. Tente novamente mais tarde...');
        }
      } else {
        EasyLoading.showError('Email ou senha incorreto.');
      }
    } catch (e) {
      debugPrint(e.toString());
      EasyLoading.showError('Alguma coisa deu errado. Tente novamente!');
    } finally {
      EasyLoading.dismiss();
    }
  }

  void requests({
    required String fullname,
    required String cpf,
    required String resultReq,
    required String colaboratorId,
  }) async {
    try {
      EasyLoading.show(
        status: 'Iniciando procura...',
        dismissOnTap: false,
      );

      var token = await LocalAuthService().getSecureToken();
      var result = await RemoteAuthService().addRequests(
        token: token.toString(),
        colaboratorname: fullname.toString(),
        cpf: cpf.toString(),
      );

      print(result);

      if (result.statusCode == 200) {
        var responseBody = jsonDecode(result.body);
        String requestId = responseBody['id'].toString();
        await LocalAuthService().storeRequestId(requestId);
        print("IDDDDD ${requestId}");
      }

      await LocalAuthService().storeCpfClient(cpf);

      var cpfClient = LocalAuthService().getCpfClient();

      print(cpfClient.toString());
      print(result.statusCode);
      print(token);

      if (result.statusCode == 200) {
        // Obtendo o token Voalle
        var voalleToken =
            await RemoteAuthService().getTokenVoalle(); // Corrigido com 'await'
        print('Voalle Token: $voalleToken'); // Exibe o token
        var responseVoalle = await RemoteAuthService().getVoalleInvoices(
            cpf: cpf, voalleToken: voalleToken, colaboratorId: colaboratorId);
      }
    } catch (e) {
      print(e);
      EasyLoading.showError('Estamos passando por uma manutenção.');
    } finally {
      EasyLoading.dismiss();
    }
  }

  void finishRequest({required String result, required String token}) async {
    try {
      EasyLoading.show(
        status: 'Loading...',
        dismissOnTap: false,
      );
      var idRequest = await LocalAuthService().getRequestId();

      RemoteAuthService()
          .putRequests(token: token, result: result, id: idRequest);
      EasyLoading.showSuccess("Finalizando procura");
      Navigator.of(Get.overlayContext!).pushReplacementNamed('/');
    } catch (e) {
      print(e);
      EasyLoading.showError('Alguma coisa deu errado.');
    } finally {
      EasyLoading.dismiss();
    }
  }

  void signOut(BuildContext context) async {
    await LocalAuthService().clear();
    Navigator.of(context).pushReplacementNamed('/login');
  }
}
