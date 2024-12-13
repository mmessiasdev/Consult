import 'package:Consult/route/route.dart';
import 'package:Consult/view/account/auth/signin.dart';
import 'package:Consult/view/dashboard/binding.dart';
import 'package:Consult/view/dashboard/screen.dart';
import 'package:Consult/view/result/lowscore.dart';
import 'package:Consult/view/result/negative.dart';
import 'package:Consult/view/result/negativehighcore.dart';
import 'package:Consult/view/result/nonegative.dart';
import 'package:Consult/view/result/resultvoalle.dart';
import 'package:get/get.dart';

class AppPage {
  static var list = [
    GetPage(
      name: AppRoute.dashboard,
      page: () => const DashboardScreen(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoute.loginIn,
      page: () => const SignInScreen(),
    ),
    GetPage(
      name: AppRoute.ApprovedVoalle,
      page: () => const ResultApproved(),
    ),
    GetPage(
      name: AppRoute.NotApprovedVoalle,
      page: () => const ResultNotApprovedOpenInvoices(),
    ),
    GetPage(
      name: AppRoute.LowScore,
      page: () => const LowScoreScreen(),
    ),    GetPage(
      name: AppRoute.NegativeClient,
      page: () => const NegativeScreen(),
    ),
    GetPage(
      name: AppRoute.NoNegative,
      page: () => const NoNegativeScreen(),
    ),
    GetPage(
      name: AppRoute.NegativeHighScore,
      page: () => const NegativeHighScoreScreen(),
    ),
  ];
}
