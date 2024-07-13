import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../bloc/tesbeh/tesbeh_cubit.dart';
import '../../../bloc/tesbeh/tesbeh_state.dart';

class TasbehTab extends StatelessWidget {
  static const String routeName = 'TasbehTab';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TesbehCubit, TesbehState>(
      builder: (context, state) {
        final cubit = context.read<TesbehCubit>();

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  size: 35,
                  Icons.arrow_back,
                  color: Theme.of(context).primaryColor,
                )),
          ),
          body: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Added spacing for better UI
                SizedBox(height: 50.h),
                SizedBox(
                  height: 250.h,
                  width: 250.w,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Image.asset('assets/images/head of seb7a.png'),
                      Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.0925),
                        child: Transform.rotate(
                            angle: cubit.angle,
                            child:
                                Image.asset('assets/images/bodyofseb7a.png')),
                      ),
                    ],
                  ),
                ),
                // Added spacing for better UI
                SizedBox(height: 20.h),
                Text(
                  'عدد التسبيحات ',
                  style: Theme.of(context).textTheme.bodyText1,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10.h),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Theme.of(context).primaryColor),
                  child: Text(
                    '${cubit.tasbehCounter}',
                    style: Theme.of(context).textTheme.bodyText1,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 10.h),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Theme.of(context).primaryColor),
                  child: Text(
                    cubit.tasbehList[cubit.index],
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: Container(
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(25)),
            child: IconButton(
              alignment: Alignment.bottomCenter,
              onPressed: () => cubit.onSebhaClicked(),
              icon: const Icon(Icons.add),
            ),
          ),
        );
      },
    );
  }
}
