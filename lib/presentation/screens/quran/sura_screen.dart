import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:werdy/bloc/home/home_cubit.dart';
import 'package:werdy/presentation/screens/quran/aya_content.dart';

import '../../../models/quran/sura_agrs.dart';
import '../../widgets/my_arrow_back.dart';

class SuraScreen extends StatelessWidget {
  static const routeName = 'SuraScreen';

  @override
  Widget build(BuildContext context) {
    var args =
        ModalRoute.of(context)?.settings.arguments as SuraDetailsScreenArgs;
    var cubit = BlocProvider.of<HomeCubit>(context);
    if (cubit.chapterContent.isEmpty) {
      cubit.readFile(args.index!);
    } else {
      cubit.clearChapterContent();
      cubit.readFile(args.index!);
    }

    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return Container(
          color: Colors.white,
          child: Column(
            children: [
              AppBar(
                  centerTitle: true,
                  title: Text(args.title!),
                  leading: MyArrowBack(
                    onTap: () {
                      cubit.clearChapterContent();
                      Navigator.pop(context);
                    },
                  )),
              SizedBox(
                height: 10.h,
              ),
              Expanded(
                child: Card(
                  margin:
                      EdgeInsets.symmetric(vertical: 48.w, horizontal: 12.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                  child: cubit.chapterContent.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.separated(
                          itemBuilder: (context, index) =>
                              AyaContent(content: cubit.chapterContent[index]),
                          separatorBuilder: (context, index) => Center(
                                child: Text(
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                            color:
                                                Theme.of(context).primaryColor),
                                    '{${index + 1}}'),
                              ),
                          itemCount: cubit.chapterContent.length),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
