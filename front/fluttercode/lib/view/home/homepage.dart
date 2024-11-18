import 'package:Benefeer/component/buttons.dart';
import 'package:Benefeer/component/containersLoading.dart';
import 'package:Benefeer/component/inputdefault.dart';
import 'package:Benefeer/component/widgets/header.dart';
import 'package:Benefeer/controller/auth.dart';
import 'package:Benefeer/view/account/account.dart';
import 'package:Benefeer/view/result/result.dart';
import 'package:flutter/material.dart';
import 'package:Benefeer/component/colors.dart';
import 'package:Benefeer/component/padding.dart';
import 'package:Benefeer/component/texts.dart';
import 'package:Benefeer/service/local/auth.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    return ErrorPost(
      text: "Estamos passando por uma manutenção. Entre novamente mais tarde!",
    );
  }

  void _showDraggableScrollableSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return Container(
                color: Colors.white,
                child: Padding(
                  padding: defaultPadding,
                  child: ListView(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: SecudaryColor,
                            borderRadius: BorderRadius.circular(10)),
                        child: GestureDetector(
                          onTap: () {
                            (Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AccountScreen()),
                            ));
                          },
                          child: Padding(
                            padding: defaultPadding,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.person),
                                const SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  children: [
                                    SubText(
                                      text: 'Meu Perfil',
                                      align: TextAlign.start,
                                      color: nightColor,
                                    ),
                                    SubTextSized(
                                      text:
                                          'Verificar informações e sair da conta',
                                      size: 10,
                                      fontweight: FontWeight.w600,
                                      color: OffColor,
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ));
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return token == null
        ? const SizedBox()
        : SafeArea(
            child: Scaffold(
              backgroundColor: lightColor,
              body: Column(
                children: [
                  Padding(
                    padding: defaultPaddingHorizon,
                    child: MainHeader(
                      title: "Connect Consult",
                      icon: Icons.menu,
                      onClick: () => _showDraggableScrollableSheet(context),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: defaultPadding,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InputTextField(
                              textEditingController: cpf,
                              title: "CPF",
                              fcolor: nightColor,
                              fill: true,
                              textInputType: TextInputType.number,
                            ),
                            const SizedBox(
                              height: 25,
                            ),
                            Builder(builder: (context) {
                              return GestureDetector(
                                onTap: () {
                                  print(cpf);
                                  AuthController().requests(  
                                      cpf: cpf.text,
                                      fullname: fullname.toString(),
                                      resultReq: "Teste");
                                },
                                child: DefaultButton(
                                  text: "Procurar",
                                  padding: defaultPadding,
                                  icon: Icons.next_plan,
                                  color: SeventhColor,
                                  colorText: lightColor,
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
