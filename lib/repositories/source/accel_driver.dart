
import 'package:process_control/repositories/process_params.dart';
import 'package:process_control/repositories/source/abstract_source_repository.dart';
import 'package:sensors_plus/sensors_plus.dart';

const double diap = 10.0;

class AccelDriver extends AbstractSourceRepository {
  double _ax = 0;
  double _ay = 0;
  double _az = 0;
  // double _gx = 0;
  // double _gy = 0;
  // double _gz = 0;
  double _midX = 0;
  double _midY = 0;
  double _midZ = 0;
  final int _freq = 50;
  final double _min = -diap;
  final double _max = diap;
  bool _isCalibratng = false;

  late Function _func;

  List<DataBlock> _dataCalibrate = [];

  AccelDriver(){
    Duration sensorInterval = SensorInterval.gameInterval;
    accelerometerEventStream(samplingPeriod: sensorInterval).listen((AccelerometerEvent event){
      _ax = event.x - _midX;
      _ay = event.y - _midY;
      _az = event.z - _midZ;
      _func(_ax, _ay, _az);


      if (_isCalibratng){
        _dataCalibrate.add(DataBlock(ax: _ax, ay: _ay, az: _az));
        if (_dataCalibrate.length > _freq){
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
        }
      }
    });

    // gyroscopeEventStream(samplingPeriod: sensorInterval).listen((GyroscopeEvent event){
    //   _gx = event.x;
    //   _gy = event.y;
    //   _gz = event.z;
    //   // _func(_gx, _gy, _gz);
    // });
  }

  @override
  Future<int> getCounter() async {
    return 0;
  }

  @override
  Future<DataParams> init(Function func) async {
    _func = func;
    DataParams pi = DataParams(freq: _freq, min: _min, max: _max);
    return pi;
  }

  @override
  Future<void> calibrate() async {
    _midX = 0;
    _midY = 0;
    _midZ = 0;
    _isCalibratng = true;
  }

  @override
  Future<void> setMode(ChaningMode md) async {
  }

}