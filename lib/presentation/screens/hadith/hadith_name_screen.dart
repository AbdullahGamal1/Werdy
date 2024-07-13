import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:werdy/presentation/widgets/my_devider.dart';

import '../../../bloc/home/home_cubit.dart';
import '../../widgets/my_arrow_back.dart';
import 'hadith_name_widget.dart';

class HadithNameScreen extends StatelessWidget {
  HadithNameScreen({super.key});

  static const String routeName = 'HadithNameScreen';

  @override
  Widget build(BuildContext context) {
    var cubit = BlocProvider.of<HomeCubit>(context);
    cubit.readHadithFile();

    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 0,
            title: const Text("رقم الحديث"),
            leading: MyArrowBack(
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                height: 1,
                width: double.infinity,
              ),
              Expanded(
                  flex: 5,
                  child: cubit.allHadithList.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : ListView.separated(
                          itemBuilder: (context, index) {
                            return HadithNameWidget(
                              hadith: cubit.allHadithList[index],
                            );
                          },
                          separatorBuilder: (context, index) =>
                              const MyDevider(),
                          itemCount: cubit.allHadithList.length))
            ],
          ),
        );
      },
    );
  }
}
