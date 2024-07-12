import '../repositories/process_params.dart';

class FactorInfo {
  String id;
  String name;
  double value;
  String shortName;
  String measure;
  int format;

  FactorInfo({
    required this.id,
    required this.name,
    required this.value,
    required this.shortName,
    required this.measure,
    required this.format
  });
}

abstract class AbstractCalculator {
  AbstractCalculator(this._data) {
    calculate();
  }

  void calculate();

  void addFactor(FactorInfo fi){
    _factors.add(fi);
  }

  int factorsCount() {
    return _factors.length;
  }

  FactorInfo factor(int idx) {
    assert(idx >= 0 && idx < _factors.length);
    return _factors[idx];
  }

  int dataSize(){
    return _data.length;
  }

  DataBlock dataValue(int idx){
    assert(idx >= 0 && idx < _data.length);
    return _data[idx];
  }

  List<DataBlock> _data;
  List<FactorInfo> _factors = [];
}
