


import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:process_control/repositories/process_params.dart';

import 'abstract_source_repository.dart';

const double diap = 100.0;

class SinusGenerator  extends AbstractSourceRepository {
  SinusGenerator() {
    final int period = 1000 ~/ _freq;
    Timer.periodic(Duration(milliseconds: period),
            (timer) {
          if (ChaningMode.mdForward == _mode) {
            _r = _r + 2 * pi / _freq;
          } else if (ChaningMode.mdBacward == _mode) {
            _r = _r - 2 * pi / _freq;
          }
          _ax = (diap * sin(_r)).toInt();
          _ay = (diap * cos(_r)).toInt();
          _az = (diap * sin(_r) * cos(_r)).toInt();
          _func(_ax, _ay, _az);
        }
    );
  }


  double _r = 0;
  final int _freq = 100;
  final double _min = -diap;
  final double _max = diap;
  int _ax = 0;
  int _ay = 0;
  int _az = 0;
  ChaningMode _mode = ChaningMode.mdForward;
  late Function _func;

  @override
  Future<DataParams> init(Function func) async {
    _func = func;
    DataParams pi = DataParams(freq: _freq, min: _min, max: _max);
    return pi;
  }

  @override
  Future<int> getCounter() async {
    return _ax;
  }

  @override
  Future<void> calibrate(Function func) async {

  }

  @override
  Future<void> setMode(ChaningMode md) async {
    _mode = md;
  }

  @override
  Future<void> getSettings() async {

  }
  }