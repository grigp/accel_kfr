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