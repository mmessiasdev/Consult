import 'package:Consult/component/buttons.dart';
import 'package:Consult/component/colors.dart';
import 'package:Consult/component/containersLoading.dart';
import 'package:Consult/component/padding.dart';
import 'package:Consult/component/texts.dart';
import 'package:Consult/controller/auth.dart';
import 'package:Consult/model/openvoalleinvoices.dart';
import 'package:Consult/service/local/auth.dart';
import 'package:Consult/service/remote/auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ResultApproved extends StatefulWidget {
  const ResultApproved({super.key});

  @override
  State<ResultApproved> createState() => _ResultApprovedState();
}

class _ResultApprovedState extends State<ResultApproved> {
  String? token;

  bool public = false;

  @override
  void initState() {
    super.initState();
    getString();
  }

  void getString() async {
    var strToken = await LocalAuthService().getSecureToken();

    // Verifique se o widget ainda está montado antes de chamar setState
    if (mounted) {
      setState(() {
        token = strToken;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Padding(
      padding: defaultPadding,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Column(
                  children: [
                    Image.asset('assets/images/illustrator/illustrator1.png'),
                    const SizedBox(
                      height: 20,
                    ),
                    SecundaryText(
                        text: "Cliente Aprovado! Já é da base",
                        color: nightColor,
                        align: TextAlign.center),
                    SizedBox(
                      height: 10,
                    ),
                    SubTextSized(
                        text: 'Não possui faturas vencidas.',
                        size: 20,
                        fontweight: FontWeight.w800),
                    const SizedBox(
                      height: 15,
                    ),
                    Icon(
                      Icons.check_circle_outlined,
                      color: SeventhColor,
                      size: 100,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              AuthController().finishRequest(
                  token: token.toString(), result: "Voalle Approved");
            },
            child: DefaultButton(
              text: "Finalizar",
              padding: defaultPadding,
              color: PrimaryColor,
            ),
          ),
        ],
      ),
    ));
  }
}

class ResultNotApprovedOpenInvoices extends StatefulWidget {
  const ResultNotApprovedOpenInvoices({super.key});

  @override
  State<ResultNotApprovedOpenInvoices> createState() =>
      _ResultNotApprovedOpenInvoicesState();
}

class _ResultNotApprovedOpenInvoicesState
    extends State<ResultNotApprovedOpenInvoices> {
  Widget ManutentionErro() {
    return const Text(
      "Estamos passando por uma manutenção. Entre novamente mais tarde!",
    );
  }

  String? token;

  bool public = false;

  @override
  void initState() {
    super.initState();
    getString();
  }

  void getString() async {
    var strToken = await LocalAuthService().getSecureToken();

    // Verifique se o widget ainda está montado antes de chamar setState
    if (mounted) {
      setState(() {
        token = strToken;
      });
    }
  }

  var voalleToken = RemoteAuthService().getTokenVoalle();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Padding(
      padding: defaultPadding,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Column(
                  children: [
                    Image.asset(
                      'assets/images/illustrator/illustrator2.png',
                      height: 250,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SecundaryText(
                        text: "Pendente",
                        color: nightColor,
                        align: TextAlign.center),
                    const SizedBox(
                      height: 10,
                    ),
                    Icon(
                      Icons.block,
                      color: nightColor,
                      size: 100,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    SecundaryText(
                        text: "Cliente da base. Faturas em vencimento",
                        color: nightColor,
                        align: TextAlign.center),
                    SizedBox(
                      height: 10,
                    ),
                    SubTextSized(
                        align: TextAlign.center,
                        text: 'Necessário pagamento das faturas em aberto.',
                        size: 20,
                        fontweight: FontWeight.w800),
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              AuthController().finishRequest(
                  token: token.toString(), result: "Voalle Rejected");
            },
            child: DefaultButton(
              text: "Finalizar",
              padding: defaultPadding,
              color: FifthColor,
            ),
          ),
        ],
      ),
    ));
  }
}
