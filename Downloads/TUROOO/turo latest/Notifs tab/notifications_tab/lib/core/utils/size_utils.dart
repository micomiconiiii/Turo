import 'package:flutter/material.dart';

extension SizeUtils on num {
  double get h =>
      this *
      MediaQueryData.fromView(WidgetsBinding.instance.window).size.height /
      100;
  double get w =>
      this *
      MediaQueryData.fromView(WidgetsBinding.instance.window).size.width /
      100;
  double get fSize =>
      this *
      MediaQueryData.fromView(WidgetsBinding.instance.window).size.width /
      100;
}
