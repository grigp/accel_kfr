
import 'package:process_control/features/record_screen/view/record_screen.dart';
import 'package:process_control/features/result_screen/view/result_screen.dart';
import 'package:process_control/features/settings_screen/view/settings_screen.dart';

final routes = {
  '/' : (context) => const RecordScreen(title: 'Запись данных'),
  '/result' : (context) => const ResultScreen(title: 'Результаты'),
  '/settings' : (context) => const SettingsScreen(title: 'Настройки'),
};