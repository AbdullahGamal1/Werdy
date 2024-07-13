import 'package:flutter/material.dart';

import '../../../models/hadith/hadith.dart';
import 'hadith_details_screen.dart';

class HadithNameWidget extends StatelessWidget {
  Hadith hadith;

  HadithNameWidget({super.key, required this.hadith});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, HadithDetailsScreen.routeName,
            arguments: hadith);
      },
      child: Container(
        alignment: Alignment.center,
        child: Text(
          hadith.title,
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ),
    );
  }
}
