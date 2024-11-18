import 'package:Benefeer/component/buttons.dart';
import 'package:Benefeer/component/colors.dart';
import 'package:Benefeer/component/padding.dart';
import 'package:Benefeer/component/texts.dart';
import 'package:Benefeer/controller/auth.dart';
import 'package:flutter/material.dart';

class ResultApproved extends StatelessWidget {
  const ResultApproved({super.key});

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
                    SizedBox(
                      height: 50,
                    ),
                    SecundaryText(
                        text: "Clinte Aprovado!",
                        color: nightColor,
                        align: TextAlign.center),
                    SizedBox(
                      height: 15,
                    ),
                    Icon(
                      Icons.check_circle_outlined,
                      color: SeventhColor,
                      size: 100,
                    ),
                  ],
                ),
                SizedBox(
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

class ResultNotApproved extends StatelessWidget {
  const ResultNotApproved({super.key});

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
                    SizedBox(
                      height: 50,
                    ),
                    SecundaryText(
                        text: "Pendente",
                        color: nightColor,
                        align: TextAlign.center),
                    SizedBox(
                      height: 15,
                    ),
                    Icon(
                      Icons.block,
                      color: nightColor,
                      size: 100,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    SecundaryText(
                        text: "Faturas em aberto",
                        color: nightColor,
                        align: TextAlign.center),
                  ],
                ),
                SizedBox(
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
