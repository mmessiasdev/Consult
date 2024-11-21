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
                      height: 50,
                    ),
                    SecundaryText(
                        text: "Cliente Aprovado!",
                        color: nightColor,
                        align: TextAlign.center),
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
              AuthController().finishRequest();
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
  var client = http.Client();
  String screen = "online";
  String? token;
  String? fname;
  String? fullname;

  var id;

  bool public = false;

  @override
  void initState() {
    super.initState();
    getString();
  }

  void getString() async {
    var strToken = await LocalAuthService().getSecureToken("token");
    var strFullname = await LocalAuthService().getFullName("fullname");

    // Verifique se o widget ainda está montado antes de chamar setState
    if (mounted) {
      setState(() {
        token = strToken;
        fullname = strFullname;
      });
    }
  }

  TextEditingController cpf = TextEditingController();

  @override
  void dispose() {
    cpf.dispose();
    super.dispose();
  }

  Widget ManutentionErro() {
    return const Text(
      "Estamos passando por uma manutenção. Entre novamente mais tarde!",
    );
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
                    Image.asset('assets/images/illustrator/illustrator2.png'),
                    const SizedBox(
                      height: 50,
                    ),
                    SecundaryText(
                        text: "Pendente",
                        color: nightColor,
                        align: TextAlign.center),
                    const SizedBox(
                      height: 15,
                    ),
                    Icon(
                      Icons.block,
                      color: nightColor,
                      size: 100,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    FutureBuilder<List<Amount>>(
                      future: RemoteAuthService().getVoalleInvoices(
                        cpf: cpf.text,
                        voalleToken: voalleToken.toString(),
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData) {
                          if (snapshot.data!.isEmpty) {
                            return const Center(
                              child:
                                  Text("Nenhuma loja disponível no momento."),
                            );
                          } else {
                            // Exibe uma lista dos itens com expirationDate
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: snapshot
                                  .data!.length, // Quantidade de itens na lista
                              itemBuilder: (context, index) {
                                var renders = snapshot.data![index];
                                // Aqui você pode acessar os dados do objeto 'renders', como 'status', 'expirationDate', etc.
                                return Padding(
                                  padding: defaultPadding,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Status: ${renders.status}'), // Exibindo o status
                                      Text(
                                          'Vencimento: ${renders.expirationDate}'), // Exibindo a data de vencimento
                                    ],
                                  ),
                                );
                              },
                            );
                          }
                        } else if (snapshot.hasError) {
                          return WidgetLoading();
                        }
                        return SizedBox(
                          height: 300,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: nightColor,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    SecundaryText(
                        text: "Faturas em aberto",
                        color: nightColor,
                        align: TextAlign.center),
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
              AuthController().finishRequest();
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
