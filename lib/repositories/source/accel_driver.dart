
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
  double _midX = 0;
  double _midY = 0;
  double _midZ = 0;
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
      _ax = event.x - _midX;
      _ay = event.y - _midY;
      _az = event.z - _midZ;

      ///< Фильтрация
      if (_isFilter) {
        _dataFilter.add(DataBlock(ax: _ax, ay: _ay, az: _az));
        if (_dataFilter.length > _fc) {
          _dataFilter.removeAt(0);
        }
      }
      DataBlock cur = DataBlock(ax: _ax, ay: _ay, az: _az);
      if (_isFilter) {
        if (_dataFilter.length >= _fc) {
          for (int i = 0; i < _dataFilter.length; ++i) {
            cur.ax = cur.ax + _koefs[i] * _dataFilter[i].ax;
            cur.ay = cur.ay + _koefs[i] * _dataFilter[i].ay;
            cur.az = cur.az + _koefs[i] * _dataFilter[i].az;
          }
          cur.ax /= _fc;
          cur.ay /= _fc;
          cur.az /= _fc;
        }
      }
      _sendData(cur.ax, cur.ay, cur.az);


      if (_isCalibratng){
        _dataCalibrate.add(DataBlock(ax: _ax, ay: _ay, az: _az));
        if (_dataCalibrate.length >= _timeCalibration * _freq){
          _isCalibratng = false;
          for (int i = 0; i < _dataCalibrate.length; ++i){
            _midX += _dataCalibrate[i].ax;
            _midY += _dataCalibrate[i].ay;
            _midZ += _dataCalibrate[i].az;
          }
          _midX /= _dataCalibrate.length;
          _midY /= _dataCalibrate.length;
          _midZ /= _dataCalibrate.length;

          _dataCalibrate.clear();
          _endCalibration();
        }
      }
    });

    gyroscopeEventStream(samplingPeriod: sensorInterval).listen((GyroscopeEvent event){
      _gx = _gx + event.x;
      _gy = _gy + event.y;
      _gz = _gz + event.z;
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
    _midX = 0;
    _midY = 0;
    _midZ = 0;
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