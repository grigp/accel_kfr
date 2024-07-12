
import 'package:process_control/repositories/database/abstract_database_repository.dart';

import '../process_params.dart';

class Database extends AbstractDatabaseRepository{

  final List<DataBlock> _data = [];  // Данные для передачи в осциллограф
  final DataParams _params = DataParams(freq: 100, min: -100, max: 100);

  @override
  Future<void> clear() async {
    _data.clear();
  }

  @override
  Future<void> add(DataBlock data) async {
    _data.add(data);
  }

  @override
  Future<void> setParams(int freq) async {
    _params.freq = freq;
  }

  @override
  Future<List<DataBlock>> getData() async {
    return _data;
  }

  @override
  Future<DataParams> getParams() async {
    return _params;
  }

}