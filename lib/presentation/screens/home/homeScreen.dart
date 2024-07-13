import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:werdy/bloc/home/home_cubit.dart';
import 'package:werdy/presentation/screens/home/my_nav_bar.dart';

import '../../widgets/top_home.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});
  static const routeName = 'MyHomePage';
  @override
  Widget build(BuildContext context) {
    var cubit = BlocProvider.of<HomeCubit>(context);
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Expanded(child: TopHomeWidget()),
              SizedBox(
                height: 10.h,
              ),
              Expanded(flex: 3, child: cubit.tabs[cubit.selectedTab]),
              SizedBox(
                height: 15.h,
              )
            ],
          ),
          bottomNavigationBar: const MyCurvedBottomBar(),
        );
      },
    );
  }
}
