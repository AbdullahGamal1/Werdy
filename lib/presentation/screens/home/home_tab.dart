import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:werdy/bloc/home/home_cubit.dart';
import '../../../constants/list.dart';
import '../../widgets/custom_category.dart';

class HomeTab extends StatelessWidget {
  static const routeName = 'HomeTab';

  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    var cubit = BlocProvider.of<HomeCubit>(context);

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: GridView.builder(
        itemCount: categoriesList.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 20.w, mainAxisSpacing: 20.h),
        itemBuilder: (context, index) => MyCategory(
            onTap: () {
              cubit.goToNextPage(context, index);
            },
            categoryTitle: categoriesList[index].categoryTitle,
            imagePath: categoriesList[index].imagePath),
      ),
    );
  }
}
