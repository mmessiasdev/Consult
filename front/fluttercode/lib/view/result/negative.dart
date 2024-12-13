import 'package:Consult/component/buttons.dart';
import 'package:Consult/component/colors.dart';
import 'package:Consult/component/padding.dart';
import 'package:Consult/component/texts.dart';
import 'package:Consult/controller/auth.dart';
import 'package:Consult/service/local/auth.dart';
import 'package:Consult/service/remote/auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NegativeScreen extends StatefulWidget {
  const NegativeScreen({super.key});

  @override
  State<NegativeScreen> createState() => _NegativeScreenState();
}

class _NegativeScreenState extends State<NegativeScreen> {
  Widget ManutentionErro() {
    return const Text(
      "Estamos passando por uma manutenção. Entre novamente mais tarde!",
    );
  }

  var voalleToken = RemoteAuthService().getTokenVoalle();

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
                    Image.asset(
                      'assets/images/illustrator/illustrator2.png',
                      height: 250,
                    ),
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
                    const SizedBox(
                      height: 15,
                    ),
                    SecundaryText(
                        text: "CPF negativado.",
                        color: nightColor,
                        align: TextAlign.center),
                    SizedBox(
                      height: 10,
                    ),
                    SubTextSized(
                        align: TextAlign.center,
                        text: 'Mediante a pagamento da taxa de 400 reais',
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
              AuthController().finishRequest(token: token.toString(), result: "Negative");
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
