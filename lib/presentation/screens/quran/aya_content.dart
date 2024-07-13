import 'package:flutter/material.dart';

class AyaContent extends StatelessWidget {
  String content;

  AyaContent({super.key, required this.content});

//طريييقة عرض محتوى الاية
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Text(
        content,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyText1,
      ),
    );
  }
}
