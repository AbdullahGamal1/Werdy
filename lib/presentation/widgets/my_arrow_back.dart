import 'package:flutter/material.dart';

class MyArrowBack extends StatelessWidget {
  MyArrowBack({required this.onTap, super.key});
  Function() onTap;
  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.topRight,
        child: IconButton(
            onPressed: onTap,
            icon:
                Icon(color: Theme.of(context).primaryColor, Icons.arrow_back)));
  }
}
