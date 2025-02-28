import 'package:get/get.dart';

// class BrowserController extends GetxController {
//   var currentSearchEngine = 'https://www.google.com/search?q='.obs;
//   var history = <String>[].obs;
//   var progress = 0.0.obs;
//
//   void setSearchEngine(String engineUrl) {
//     currentSearchEngine.value = engineUrl;
//   }
//
//   void addToHistory(String url) {
//     if (!history.contains(url)) {
//       history.add(url);
//     }
//   }
//
//   void updateProgress(double newProgress) {
//     progress.value = newProgress;
//   }
// }

import 'package:get/get.dart';

class BrowserController extends GetxController {
  var bookmarks = <String>[].obs;
  var history = <String>[].obs;
  var currentSearchEngine = 'https://www.google.com/search?q='.obs;
  var progress = 0.0.obs;

  void setSearchEngine(String url) {
    currentSearchEngine.value = url;
  }

  void updateProgress(double value) {
    progress.value = value;
  }

  void addToHistory(String url) {
    if (!history.contains(url)) {
      history.add(url);
    }
  }
}




class MenuController extends GetxController {
  var isMenuOpen = false.obs;

  void toggleMenu() {
    isMenuOpen.value = !isMenuOpen.value;
  }
}


class SearchEngineController extends GetxController {
  var selectedSearchEngine = 'Google'.obs;

  void setSearchEngine(String engine) {
    selectedSearchEngine.value = engine;
  }
}
