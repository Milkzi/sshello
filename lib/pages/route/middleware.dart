import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';

class FirstMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    print("first-route-middleware.....");

    return null;
  }
}
