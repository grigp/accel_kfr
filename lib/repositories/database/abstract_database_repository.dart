
import 'package:process_control/repositories/process_params.dart';

abstract class AbstractDatabaseRepository{
  Future<void> clear();
  Future<void> add(DataBlock data);
  Future<void> setParams(int freq);

  Future<List<DataBlock>> getData();
  Future<DataParams> getParams();
}