import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:werdy/bloc/tesbeh/tesbeh_state.dart';

class TesbehCubit extends Cubit<TesbehState> {
  TesbehCubit() : super(TesbehInitial());

  final List<String> tasbehList = [
    'سبحان الله ',
    'الحمد لله',
    'لا اله الا الله ',
    'الله أكبر'
  ];

  int tasbehCounter = 0;
  double angle = 0;
  int index = 0;

  void onSebhaClicked() {
    angle += 1;
    tasbehCounter++;
    emit(TesbehUpdate()); // Emit a more descriptive state

    if (tasbehCounter % 33 == 0) {
      index++;
      emit(TesbehUpdate()); // Emit for UI update after cycle completion
    }

    if (index == tasbehList.length) {
      index = 0;
      tasbehCounter = 0;
      emit(TesbehReset()); // Emit a state for full reset
    }
  }
}
