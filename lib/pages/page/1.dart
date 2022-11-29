import 'package:get/get.dart';
import 'package:flutter/material.dart';

//其他页面跳转到Form页面进行命名路由传值
class OtherPage extends StatefulWidget {
  const OtherPage({super.key});

  @override
  State<OtherPage> createState() => _FormPageState();
}

class _FormPageState extends State<OtherPage> {
  @override
  void initState() {
    super.initState();
    print(Get.arguments);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("其他页面"),
      ),
      body:  Center(
        child: Text("${Get.arguments["title"]}", style: TextStyle(fontSize: 50)),
      ),
    );
  }
}
