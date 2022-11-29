import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PersonPage extends StatefulWidget {
  const PersonPage({super.key});

  @override
  State<PersonPage> createState() => _nameState();
}

class _nameState extends State<PersonPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      children: [

        ElevatedButton(
            onPressed: () {

              Get.toNamed("/other1", arguments: {"title": "命名路由跳转模式:这是个人页面跳转来的"});
            },
            child: const Text("命令路由跳转方式")),
       
      ],
    ));
  }
}
