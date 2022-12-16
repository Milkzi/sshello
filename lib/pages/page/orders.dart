import 'dart:convert';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:sshello/utils/sharedPreferences.dart';

//其他页面跳转到Form页面进行命名路由传值
class OrderList extends StatefulWidget {
  const OrderList({super.key});

  @override
  State<OrderList> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderList> {
  List<Widget> orders = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(Get.arguments);
    print(
        "sucessfulOrders-=--------------------------------19512151612--------------------------------------------");
    var sucessfulOrders = spget("sucessfulOrders");
    sucessfulOrders.then((values) {
      // List orders_value = jsonDecode(value);

      values.forEach((element) {
        Map order = jsonDecode(element);
        setState(() {
          print(order);
          orders.insert(0, const MyRowBox());
        });
      });
    });
    print(
        "sucessfulOrders-=----------------------------------------------------------------------------");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("订单详情"),
        ),
        body: Center(
          child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) => orders[index]),
        ));
  }
}

class MyRowBox extends StatefulWidget {
  const MyRowBox({super.key});

  @override
  State<MyRowBox> createState() => _MyRowboxState();
}

class _MyRowboxState extends State<MyRowBox> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Expanded(flex: 1, child: Text("日期")),
            Expanded(flex: 1, child: Text("内容")),
            Expanded(flex: 1, child: Text("详情按钮")),
          ],
        ));
  }
}
