
import 'dart:io';

import 'package:process_control/repositories/process_params.dart';

enum ChaningMode {mdForward, mdBacward}

abstract class AbstractSourceRepository{
  Future<DataParams> init(Function func);
  Future<int> getCounter();

  Future<void> calibrate(Function func);
  Future<void> setMode(ChaningMode md);
  Future<void> getSettings();


}