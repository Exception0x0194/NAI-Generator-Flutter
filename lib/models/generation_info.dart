import 'package:flutter/material.dart';

class GenerationInfo {
  Image? img;
  final String type;
  Map<String, dynamic> info;

  GenerationInfo({this.img, required this.info, required this.type});
}
