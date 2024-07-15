part of 'result_bloc.dart';

class ResultState{}

class DataInitial extends ResultState{}

class DataLoaded extends ResultState {
  DataLoaded({
    required this.data,
    required this.params,
  });

  final List<DataBlock> data;
  final DataParams params;
}

class DataLoadingFailure extends ResultState {
  DataLoadingFailure({
    this.exception,
  });

  final Object? exception;
}


class CalculateState{}

class CalculateInitial extends CalculateState{}

class KfrCalculate extends CalculateState {
  KfrCalculate({
    required this.factors,
  });

  final KfrCalculator factors;
}

class KfrCalculateFailure extends CalculateState {
  KfrCalculateFailure({
    this.exception,
  });

  final Object? exception;
}
