import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/tools.dart';

class ChapterNotifier extends StateNotifier<List<String>> {
  ChapterNotifier() : super([]) {
    update();
  }

  update() {
    state = tools!.get_Chapter();
  }
}

class ShelfNotifier extends StateNotifier<List<String>> {
  ShelfNotifier() : super([]) {
    state = tools!.get_Shelf();
  }
}

class ShelfIndexNotifier extends StateNotifier<int> {
  ShelfIndexNotifier() : super(_initValue);
  static final _initValue = tools!.getCurrBibleIndex();

  update(int value) {
    tools!.setCurrBible(value);
    state = value;
  }
}
