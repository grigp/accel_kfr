
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:process_control/calculators/abstract_calculator.dart';
import 'package:process_control/repositories/process_params.dart';

double _diapsKoef =  0.043599; //0.247167;  //

class KfrCalculator extends AbstractCalculator{
  KfrCalculator(super.data);
  final List<double> _diag = [];

  void getValues() async {
    const storage = FlutterSecureStorage();
    String? sdk = await storage.read(key: 'diaps_koef');
    print('kfr.sdk : ------------------ $sdk');
    if (sdk != null) {
      _diapsKoef = double.tryParse(sdk)!;
    }

    _calculate();
  }

  @override
  void calculate() {
    getValues();
  }

  void _calculate(){
    for (int j = 0; j < 20; ++j) {
      _diag.add(0);
    }

    int n = dataSize();

    double min = 100000000;
    double max = 0;
    double minX = 100000000;
    double maxX = 0;
    double minY = 100000000;
    double maxY = 0;
    double minZ = 100000000;
    double maxZ = 0;
    for (int i = 0; i < n; ++i){
      var val = dataValue(i);
      double vct = sqrt(pow(val.ax, 2) + pow(val.ay, 2) + pow(val.az, 2));
      if (vct < min) {min = vct;}
      if (vct > max) {max = vct;}
      if (val.ax.abs() < minX) {minX = val.ax.abs();}
      if (val.ax.abs() > maxX) {maxX = val.ax.abs();}
      if (val.ay.abs() < minY) {minY = val.ay.abs();}
      if (val.ay.abs() > maxY) {maxY = val.ay.abs();}
      if (val.az.abs() < minZ) {minZ = val.az.abs();}
      if (val.az.abs() > maxZ) {maxZ = val.az.abs();}

      for (int j = 0; j < 20; ++j) {
//        if (vct >= sqrt(j) * 0.043599 && vct < sqrt(j+1) * 0.043599){
        if (vct >= sqrt(j) * _diapsKoef && vct < sqrt(j+1) * _diapsKoef){
          ++_diag[j];
        }
      }
    }

    print('-------------------------');
    print('min = $min   max = $max');
    print('minX = $minX   maxX = $maxX   |   minY = $minY   maxY = $maxY  |  minZ = $minZ   maxZ = $maxZ');
    for (int j = 0; j < 20; ++j) {
      var v1 = sqrt(j) * _diapsKoef;
      var v2 = sqrt(j + 1) * _diapsKoef;
      print('-- j = $j  v1 = $v1   v2 = $v2');
    }
    print('-------------------------');


    double s = 0;
    for (int j = 1; j < 20; ++j) {
      _diag[j] += _diag[j-1];
      var v = _diag[j];
      print('-- j = $j   val = $v');
      s += _diag[j];
    }
    print('summ = $s');
    double summ = 0;
    for (int j = 0; j < 20; ++j) {
      _diag[j] = _diag[j] / (n ?? 1);
      summ += _diag[j];
    }

    double kfr = summ / 20 * 100;

    print('-------------------------');
    print('kfr = $kfr');


    addFactor(FactorInfo(id: 'kfr', name: 'Качество функции равновесия', value: kfr, shortName: 'KFR', measure: '%', format: 2));
  }

  static double diapDistance(){
    return _diapsKoef;
  }

  static void setDiapDistance(double dd){
    _diapsKoef = dd;
  }
}