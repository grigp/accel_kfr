
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:process_control/repositories/process_params.dart';
import 'package:process_control/repositories/source/abstract_source_repository.dart';
import 'package:sensors_plus/sensors_plus.dart';

const double diap = 10.0;

class AccelDriver extends AbstractSourceRepository {
  double _ax = 0;
  double _ay = 0;
  double _az = 0;
  double _gx = 0;
  double _gy = 0;
  double _gz = 0;
  double _gsx = 0;
  double _gsy = 0;
  double _gsz = 0;
  double _midAX = 0;
  double _midAY = 0;
  double _midAZ = 0;
  double _midGX = 0;
  double _midGY = 0;
  double _midGZ = 0;
  final int _freq = 50;
  final double _min = -diap;
  final double _max = diap;
  bool _isCalibratng = false;
  int _timeCalibration = 1;
  bool _isFilter = true;

  late Function _sendData;
  late Function _endCalibration;

  final List<DataBlock> _dataCalibrate = [];
  final List<DataBlock> _dataFilter = [];
  final int _fc = 15;
  final List<double> _koefs = [0.08, 0.23, 0.5, 0.8, 1.1, 1.4, 1.9, 2, 1.9, 1.4, 1.1, 0.8, 0.5, 0.23, 0.08];

  AccelDriver(){
    getSettings();
    Duration sensorInterval = SensorInterval.gameInterval;
    accelerometerEventStream(samplingPeriod: sensorInterval).listen((AccelerometerEvent event){
      _ax = event.x - _midAX;
      _ay = event.y - _midAY;
      _az = event.z - _midAZ;

      ///< Фильтрация
      if (_isFilter) {
        _dataFilter.add(DataBlock(ax: _ax, ay: _ay, az: _az,
            gx: _gsx, gy: _gsy, gz: _gsz));
        if (_dataFilter.length > _fc) {
          _dataFilter.removeAt(0);
        }
      }
      DataBlock cur = DataBlock(ax: _ax, ay: _ay, az: _az,
          gx: _gx, gy: _gy, gz: _gz);
      if (_isFilter) {
        if (_dataFilter.length >= _fc) {
          for (int i = 0; i < _dataFilter.length; ++i) {
            cur.ax = cur.ax + _koefs[i] * _dataFilter[i].ax;
            cur.ay = cur.ay + _koefs[i] * _dataFilter[i].ay;
            cur.az = cur.az + _koefs[i] * _dataFilter[i].az;
            cur.gx = cur.gx + _koefs[i] * _dataFilter[i].gx;
            cur.gy = cur.gy + _koefs[i] * _dataFilter[i].gy;
            cur.gz = cur.gz + _koefs[i] * _dataFilter[i].gz;
          }
          cur.ax /= _fc;
          cur.ay /= _fc;
          cur.az /= _fc;
          cur.gx /= _fc;
          cur.gy /= _fc;
          cur.gz /= _fc;
        }
      }
      _sendData(cur.ax, cur.ay, cur.az, cur.gx, cur.gy, cur.gz);


      if (_isCalibratng){
        _dataCalibrate.add(DataBlock(ax: _ax, ay: _ay, az: _az,
          gx: _gx, gy: _gy, gz: _gz));
        if (_dataCalibrate.length >= _timeCalibration * _freq){
          _isCalibratng = false;
          // for (int i = 0; i < _dataCalibrate.length; ++i){
          //   _midAX += _dataCalibrate[i].ax;
          //   _midAY += _dataCalibrate[i].ay;
          //   _midAZ += _dataCalibrate[i].az;
          //   _midGX += _dataCalibrate[i].gx;
          //   _midGY += _dataCalibrate[i].gy;
          //   _midGZ += _dataCalibrate[i].gz;
          // }
          // _midAX /= _dataCalibrate.length;
          // _midAY /= _dataCalibrate.length;
          // _midAZ /= _dataCalibrate.length;
          // _midGX /= _dataCalibrate.length;
          // _midGY /= _dataCalibrate.length;
          // _midGZ /= _dataCalibrate.length;
          // _gsx = 0;
          // _gsy = 0;
          // _gsz = 0;

          _dataCalibrate.clear();
          _endCalibration();
        }
      }
    });

    gyroscopeEventStream(samplingPeriod: sensorInterval).listen((GyroscopeEvent event){
      _gx = event.x - _midGX;
      _gy = event.y - _midGY;
      _gz = event.z - _midGZ;
      _gsx += _gx;
      _gsy += _gy;
      _gsz += _gz;
      // _func(_gx, _gy, _gz);
    });
  }

  @override
  Future<int> getCounter() async {
    return 0;
  }

  @override
  Future<DataParams> init(Function func) async {
    _sendData = func;
    DataParams pi = DataParams(freq: _freq, min: _min, max: _max);
    return pi;
  }

  @override
  Future<void> calibrate(Function func) async {
    _endCalibration = func;
    _midAX = 0;
    _midAY = 0;
    _midAZ = 0;
    _midGX = 0;
    _midGY = 0;
    _midGZ = 0;
    _gsx = 0;
    _gsy = 0;
    _gsz = 0;
    _isCalibratng = true;
  }

  @override
  Future<void> setMode(ChaningMode md) async {
  }

  @override
  Future<void> getSettings() async {
    const storage =  FlutterSecureStorage();
    String? stc = await storage.read(key: 'time_calibration');
    if (stc != null) {
      _timeCalibration = int.tryParse(stc)!;
    }

    String? stf = await storage.read(key: 'filtration');
    if (stf != null) {
      if (stf == "1") {
        _isFilter = true;
      } else {
        _isFilter = false;
      }
    }
  }

}