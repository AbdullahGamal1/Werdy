import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyCategory extends StatelessWidget {
  String? categoryTitle, imagePath;
  Function() onTap;
  MyCategory(
      {super.key,
      required this.categoryTitle,
      required this.imagePath,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
            border: Border.all(color: theme.primaryColor),
            borderRadius: const BorderRadius.all(Radius.circular(25)),
            color: Colors.white),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath!,
              fit: BoxFit.cover,
              height: 50.h,
            ),
            Text(
              categoryTitle!,
              style: theme.textTheme.titleSmall,
            )
          ],
        ),
      ),
    );
  }
}
