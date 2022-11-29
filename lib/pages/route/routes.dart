import 'package:sshello/pages/Tabs.dart';
import '../page/1.dart';
import 'package:get/get.dart';
import './middleware.dart';

class MyRoute {
  static final routes = [
    GetPage(name: "/", page: () => const MyScaffold()),

    GetPage(
        name: "/other1",
        page: () => const OtherPage(),
        middlewares: [FirstMiddleware()]),
  ];
}
