import 'package:Consult/component/buttons.dart';
import 'package:Consult/component/containersLoading.dart';
import 'package:Consult/component/inputdefault.dart';
import 'package:Consult/component/widgets/header.dart';
import 'package:Consult/controller/auth.dart';
import 'package:Consult/view/account/account.dart';
import 'package:flutter/material.dart';
import 'package:Consult/component/colors.dart';
import 'package:Consult/component/padding.dart';
import 'package:Consult/component/texts.dart';
import 'package:Consult/service/local/auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var client = http.Client();

  String screen = "online";
  bool isButtonEnabled = false;

  String? token;
  String? fname;
  String? fullname;
  String? colaboratorId;

  var id;
  bool public = false;

  @override
  void initState() {
    super.initState();
    getString();
  }

  void getString() async {
    var strToken = await LocalAuthService().getSecureToken();
    var strFullname = await LocalAuthService().getFullName();
    var strcolaboratorId = await LocalAuthService().getColaboratorId();

    // var strCpf = await LocalAuthService().getCpf("cpf");

    // Verifique se o widget ainda está montado antes de chamar setState
    if (mounted) {
      setState(() {
        // Caso strCpf seja null, passamos uma string vazia
        // cpf.text = strCpf ?? ''; // Usa uma string vazia se strCpf for null
        token = strToken;
        fullname = strFullname;
        colaboratorId = strcolaboratorId;
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
                                  builder: (context) => AccountScreen(
                                        buttom: true,
                                      )),
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Detecta se é uma tela grande (WEB ou TABLET)
                bool isLargeScreen = constraints.maxWidth > 800;

                return Center(
                  child: SizedBox(
                    width: isLargeScreen
                        ? 600
                        : double
                            .infinity, // Centraliza e limita a largura em telas grandes
                    child: Column(
                      children: [
                        Padding(
                          padding: defaultPaddingHorizon,
                          child: MainHeader(
                            title: "Connect Consult",
                            icon: Icons.menu,
                            onClick: () =>
                                _showDraggableScrollableSheet(context),
                          ),
                        ),
                        const SizedBox(height: 25),
                        Padding(
                          padding: defaultPadding,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    child: Icon(
                                      Icons.people,
                                      color: lightColor,
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  RichDefaultText(
                                    text: 'Olá, \n',
                                    size: 20,
                                    wid: SecundaryText(
                                      text: '${fullname.toString()}!',
                                      color: nightColor,
                                      align: TextAlign.start,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: defaultPadding,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: isLargeScreen
                                      ? 400
                                      : double.infinity, // Ajusta largura
                                  child: InputTextField(
                                    textEditingController: cpf,
                                    title: "Digite um CPF para consultá-lo",
                                    fcolor: nightColor,
                                    fill: true,
                                    textInputType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(13),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 50),
                                GestureDetector(
                                  onTap: () {
                                    if (cpf.text.length >= 11) {
                                      print(cpf.text);
                                      AuthController().requests(
                                        cpf: cpf.text,
                                        colaboratorId: colaboratorId.toString(),
                                        fullname: fullname.toString(),
                                        resultReq: "Wait Result",
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'CPF deve ter no mínimo 11 caracteres'),
                                        ),
                                      );
                                    }
                                  },
                                  child: SizedBox(
                                    width: isLargeScreen
                                        ? 250
                                        : double
                                            .infinity, // Largura do botão em telas grandes
                                    child: DefaultButton(
                                      text: "Consultar",
                                      padding: defaultPadding,
                                      icon: Icons.keyboard_arrow_right_outlined,
                                      color: SeventhColor,
                                      colorText: lightColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
  }
}
