import 'paths.dart';

int getIndexFromLocation(String location) {
  if (location.startsWith(Paths.search)) return 1;
  if (location.startsWith(Paths.create)) return 2;
  if (location.startsWith(Paths.notifications)) return 3;
  if (location.startsWith(Paths.profile)) return 4;
  return 0;
}