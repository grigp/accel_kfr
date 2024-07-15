part of 'result_bloc.dart';

class ResultEvent{}

class GetListData extends ResultEvent {}

class CalculateEvent{}

class GetFactors extends CalculateEvent {
  GetFactors({
    required this.data,
  });
  final List<DataBlock> data;
}
