import 'package:Consult/component/buttons.dart';
import 'package:Consult/component/colors.dart';
import 'package:Consult/component/padding.dart';
import 'package:Consult/component/texts.dart';
import 'package:Consult/controller/auth.dart';
import 'package:Consult/service/local/auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NoNegativeScreen extends StatefulWidget {
  const NoNegativeScreen({super.key});

  @override
  State<NoNegativeScreen> createState() => _NoNegativeScreenState();
}

class _NoNegativeScreenState extends State<NoNegativeScreen> {

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
                        SizedBox(height: 10,),
                    SubTextSized(
                        align: TextAlign.center,
                        text: 'Sem negativação.',
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
              AuthController().finishRequest(token: token.toString(), result: "No Negative");
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
