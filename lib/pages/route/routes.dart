import 'package:sshello/pages/Tabs.dart';
import 'package:sshello/pages/tabs/person.dart';
import '../page/1.dart';
import '../page/orders.dart';
import '../page/orderdetail.dart';
import 'package:get/get.dart';
import './middleware.dart';

class MyRoute {
  static final routes = [
    GetPage(name: "/", page: () => const MyScaffold()),
    GetPage(
        name: "/other1",
        page: () => const OtherPage(),
        middlewares: [FirstMiddleware()]),
    // GetPage(name: "/order/detail", page: () => const OrderDetail()),
    GetPage(name: "/order/list", page: () => const OrderList()),
  ];
}
