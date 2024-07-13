import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/home/home_cubit.dart';

class MyCurvedBottomBar extends StatelessWidget {
  const MyCurvedBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
        animationDuration: const Duration(milliseconds: 200),
        color: Theme.of(context).primaryColor,
        backgroundColor: Colors.transparent,
        onTap: (index) {
          BlocProvider.of<HomeCubit>(context).updateTabWidget(index);
        },
        items: const [
          Icon(Icons.home),
          Icon(Icons.settings),
        ]);
  }
}
