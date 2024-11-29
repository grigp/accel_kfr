
import 'dart:math';
import 'package:vector_math/vector_math.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:process_control/calculators/abstract_calculator.dart';
import 'package:process_control/calculators/calculate_defines.dart';

double _diapsKoef =  0.025;//0.043599; //0.247167;  //
int _ndiaps = 50;   /// Кол-во диапазонов
CalculateDirectionMode _cdm = CalculateDirectionMode.cdm3D;

class KfrCalculator extends AbstractCalculator{
  KfrCalculator(super.data);
  final List<double> _diag = [];

  void getValues() async {
    const storage = FlutterSecureStorage();
    String? sdk = await storage.read(key: 'diaps_koef');
    if (sdk != null) {
      _diapsKoef = double.tryParse(sdk)!;
    }
    String? stcdm = await storage.read(key: 'calculate_direction_mode');
    if (stcdm != null) {
      _cdm = CalculateDirectionMode.values[int.tryParse(stcdm)!];
    }
  }

  @override
  Future<void> calculate() async {
    getValues();

    for (int j = 0; j < _ndiaps; ++j) {
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
      double vct = 0;
      // double ax = val.ax + 9.8 * sin(radians(val.gy));  Поисследовать поворот
      // double ay = val.ay + 9.8 * sin(radians(val.gx));
      // double az = val.az + 9.8 * sin(radians(val.gz));
      double ax = val.ax * cos(radians(val.gx));
      double ay = val.ay * cos(radians(val.gy));
      double az = val.az * cos(radians(val.gz));
      if (_cdm == CalculateDirectionMode.cdm3D) {
        vct = sqrt(pow(ax, 2) + pow(ay, 2) + pow(az, 2));
      } else
      if (_cdm == CalculateDirectionMode.cdmVertical) {
        vct = sqrt(pow(ax, 2) + pow(az, 2));
      } else
      if (_cdm == CalculateDirectionMode.cdmHorizontal) {
        vct = sqrt(pow(ax, 2) + pow(ay, 2));
      }
      if (vct < min) {min = vct;}
      if (vct > max) {max = vct;}

      if (ax.abs() < minX) {minX = ax.abs();}
      if (ax.abs() > maxX) {maxX = ax.abs();}
      if (ay.abs() < minY) {minY = ay.abs();}
      if (ay.abs() > maxY) {maxY = ay.abs();}
      if (az.abs() < minZ) {minZ = az.abs();}
      if (az.abs() > maxZ) {maxZ = az.abs();}

      for (int j = 0; j < _ndiaps; ++j) {
        if (vct >= sqrt(j) * _diapsKoef && vct < sqrt(j+1) * _diapsKoef){
          ++_diag[j];
        }
      }
    }

    print('-------------------------');
    print('min = $min   max = $max');
    print('minX = $minX   maxX = $maxX   |   minY = $minY   maxY = $maxY  |  minZ = $minZ   maxZ = $maxZ');
    for (int j = 0; j < _ndiaps; ++j) {
      var v1 = sqrt(j) * _diapsKoef;
      var v2 = sqrt(j + 1) * _diapsKoef;
      print('-- j = $j  v1 = $v1   v2 = $v2');
    }
    print('-------------------------');


    double s = 0;
    for (int j = 1; j < _ndiaps; ++j) {
      _diag[j] += _diag[j-1];
      s += _diag[j];
    }
    double summ = 0;
    for (int j = 0; j < _ndiaps; ++j) {
      _diag[j] = _diag[j] / n * 100;
      print('-- j = $j   val = ${_diag[j]}');
      summ += _diag[j];
    }

    double kfr = summ / _ndiaps;

    print('-------------------------');
    print('summ = $s   n = $n');
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

  List<double> diagram(){
    List<double> retval = [];
    for(int i = 0; i < _ndiaps; ++i) {
      retval.add(_diag[i]);
    }
    return retval;
  }
}