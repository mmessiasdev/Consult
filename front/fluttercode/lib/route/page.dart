import 'package:Benefeer/route/route.dart';
import 'package:Benefeer/view/account/auth/signin.dart';
import 'package:Benefeer/view/dashboard/binding.dart';
import 'package:Benefeer/view/dashboard/screen.dart';
import 'package:Benefeer/view/result/result.dart';
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
      page: () => const ResultNotApproved(),
    ),
    GetPage(
      name: AppRoute.dashboard,
      page: () => const DashboardScreen(),
      binding: DashboardBinding(),
    ),
  ];
}
