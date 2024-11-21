import 'package:Consult/route/route.dart';
import 'package:Consult/view/account/auth/signin.dart';
import 'package:Consult/view/dashboard/binding.dart';
import 'package:Consult/view/dashboard/screen.dart';
import 'package:Consult/view/result/result.dart';
import 'package:get/get.dart';

class AppPage {
  static var list = [
    GetPage(
      name: AppRoute.loginIn,
      page: () => const SignInScreen(),
    ),
    GetPage(
      name: AppRoute.ResultApproved,
      page: () => const ResultApproved(),
    ),
    GetPage(
      name: AppRoute.ResultNotApproved,
      page: () => const ResultNotApprovedOpenInvoices(),
    ),
    GetPage(
      name: AppRoute.dashboard,
      page: () => const DashboardScreen(),
      binding: DashboardBinding(),
    ),
  ];
}
