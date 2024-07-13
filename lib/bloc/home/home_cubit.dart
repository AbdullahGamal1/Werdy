import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:werdy/presentation/screens/hadith/hadith_name_screen.dart';
import 'package:werdy/presentation/screens/home/home_tab.dart';
import 'package:werdy/presentation/screens/quran/quran_tab.dart';
import 'package:werdy/presentation/screens/tasbeh/tasbeh.dart';

import '../../models/hadith/hadith.dart';
import '../../presentation/screens/home/settings/settings.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());
  List<String> chapterContent = [];
  List<Hadith> allHadithList = [];

  List<Widget> tabs = [const HomeTab(), const SettingsTab()];
  int selectedTab = 0;

  goToNextPage(BuildContext context, int index) {
    if (index == 0) {
      Navigator.of(context).pushNamed(QuranTab.routeName);
    } else if (index == 1) {
      Navigator.of(context).pushNamed(HadithNameScreen.routeName);
    } else if (index == 2) {
      Navigator.of(context).pushNamed(TasbehTab.routeName);
    }
  }

  void readFile(int suraIndex) async {
    String text =
        await rootBundle.loadString('assets/files/quran/${suraIndex + 1}.txt');
    chapterContent = text.split('\n');
    emit(SuccessRaedFile());
  }

  void clearChapterContent() {
    chapterContent = [];
    emit(SuccessRaedFile());
  }

  updateTabWidget(int index) {
    selectedTab = index;
    emit(HomeTabUpdateScreen());
  }

  readHadithFile() async {
    List<Hadith> hadethList = [];
    String fileContent =
        await rootBundle.loadString('assets/files/ahadeth.txt');
    List<String> splittedContent = fileContent.split('#');
    for (int i = 0; i < splittedContent.length; i++) {
      String singleHadethContent = splittedContent[i];
      List<String> lines = singleHadethContent.trim().split('\n');
      String title = lines[0];
      lines.removeAt(0);
      String content = lines.join('\n');
      Hadith hadeth = Hadith(title: title, content: content);
      hadethList.add(hadeth);
    }
    allHadithList = hadethList;
    emit(SuccessRaedFile());
  }
}
