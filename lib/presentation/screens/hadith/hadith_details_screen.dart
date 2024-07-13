import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:werdy/presentation/widgets/my_arrow_back.dart';

import '../../../models/hadith/hadith.dart';

class HadithDetailsScreen extends StatelessWidget {
  static const routeName = 'HadithDetailsScreen1';

  HadithDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var hadeth = ModalRoute.of(context)?.settings.arguments as Hadith;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: MyArrowBack(
            onTap: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            hadeth.title,
            style: Theme.of(context).textTheme.headline5,
          ),
        ),
        body: Column(
          children: [
            Expanded(
                child: Card(
                    margin:
                        EdgeInsets.symmetric(vertical: 48.w, horizontal: 12.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                    child: hadeth.content.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            child: Text(
                              hadeth.content,
                              style: Theme.of(context).textTheme.bodyText1,
                              textAlign: TextAlign.center,
                            ),
                          )))
          ],
        ));
  }
}
