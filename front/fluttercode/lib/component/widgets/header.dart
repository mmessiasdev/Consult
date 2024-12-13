import 'package:flutter/material.dart';
import 'package:Consult/component/colors.dart';
import 'package:Consult/component/texts.dart';

class MainHeader extends StatelessWidget {
  MainHeader(
      {Key? key,
      required this.title,
      this.onClick,
      this.icon,
      this.over,
      this.maxl})
      : super(key: key);
  String title;
  final Function? onClick;
  IconData? icon;
  TextOverflow? over;
  int? maxl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 25),
      child: SizedBox(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
                width: 150,
                child: Image.asset('assets/images/logo/image.png')),
            GestureDetector(
              onTap: () => onClick!(),
              child: Icon(
                icon,
                size: 25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
