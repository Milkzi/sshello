import 'package:bruno/bruno.dart';
import 'package:flutter/animation.dart';
class MyConfigUtils {

  static BrnAllThemeConfig defaultAllConfig = BrnAllThemeConfig(
    commonConfig: defaultCommonConfig,
    // 这里添加dialog配置
    dialogConfig: defaultDialogConfig);

  static BrnCommonConfig defaultCommonConfig = BrnCommonConfig(
    brandPrimary: const Color(0xFF3072F6),
  );

  /// Dialog配置
  static BrnDialogConfig defaultDialogConfig = BrnDialogConfig(
    radius: 12.0,
  );
}