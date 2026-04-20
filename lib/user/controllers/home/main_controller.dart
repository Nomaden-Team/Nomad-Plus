import 'package:get/get.dart';

class MainController extends GetxController {
  int tabIndex = 0;

  void changeTab(int index) {
    tabIndex = index;
    update();
  }
}
