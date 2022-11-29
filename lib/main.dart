import 'package:flutter/material.dart';
import 'package:bruno/bruno.dart';
import 'package:sshello/utils/util.dart';
import 'package:sshello/pages/Tabs.dart';
void main() {
  BrnInitializer.register(allThemeConfig:MyConfigUtils.defaultAllConfig);
  runApp(const MyAPP());
}

