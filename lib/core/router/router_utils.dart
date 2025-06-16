import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'paths.dart';

class RouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}

int getIndexFromLocation(String location) {
  if (location.startsWith(Paths.search)) return 1;
  if (location.startsWith(Paths.create)) return 2;
  if (location.startsWith(Paths.notifications)) return 3;
  if (location.startsWith(Paths.profile)) return 4;
  if (location.startsWith(Paths.externProfile(location))) return 5;
  return 0;
}