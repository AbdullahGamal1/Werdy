import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SuraItem extends StatelessWidget {
  SuraItem(
      {super.key,
      required this.name,
      required this.numberOfSura,
      required this.numberOfAyat,
      required this.isMakke,
      required this.onTap});

  String? name, numberOfAyat, numberOfSura;
  bool? isMakke;
  Function() onTap;
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(7),
        padding: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
            border: Border.all(color: theme.primaryColor),
            borderRadius: const BorderRadius.all(Radius.circular(25)),
            color: Colors.white),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20.w,
            ),
            Expanded(
              child: Text(
                name!,
                style: theme.textTheme.titleSmall
                    ?.copyWith(color: Theme.of(context).primaryColor),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  const Text('رقم السورة'),
                  Text(
                    numberOfSura!,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  const Text('عدد الايات'),
                  Text(
                    numberOfAyat!,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Text(
                isMakke! ? "مكية " : "مدنية",
                style: theme.textTheme.bodyMedium,
              ),
            )
          ],
        ),
      ),
    );
  }
}

ayaDivider(index) => Text('{ ${index + 1} }');
