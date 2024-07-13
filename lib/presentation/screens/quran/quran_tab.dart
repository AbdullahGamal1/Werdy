import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:werdy/presentation/screens/quran/sura_screen.dart';

import '../../../constants/list.dart';
import '../../../models/quran/sura_agrs.dart';

import '../../widgets/my_arrow_back.dart';
import '../../widgets/sura_item.dart';

class QuranTab extends StatelessWidget {
  static const routeName = 'QuranTab';

  const QuranTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            SizedBox(height: 15.h),
            MyArrowBack(
              onTap: () {
                Navigator.pop(context);
              },
            ),
            Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(30),
                  child: const Image(
                    image: AssetImage('assets/images/koran.png'),
                    fit: BoxFit.fill,
                  ),
                )),
            Expanded(
              flex: 4,
              child: ListView.separated(
                separatorBuilder: (context, index) => Container(),
                itemBuilder: (context, index) => SuraItem(
                    name: completeSurahList[index].name,
                    numberOfSura: '${index + 1}',
                    numberOfAyat:
                        completeSurahList[index].numberOfAyat.toString(),
                    isMakke: completeSurahList[index].isMakke,
                    onTap: () {
                      Navigator.pushNamed(context, SuraScreen.routeName,
                          arguments: SuraDetailsScreenArgs(
                              title: completeSurahList[index].name,
                              index: index));
                    }),
                itemCount: completeSurahList.length,
              ),
            )
          ],
        ),
      ),
    );
  }
}
