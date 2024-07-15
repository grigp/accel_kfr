import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:process_control/calculators/kfr_calculator.dart';
import 'package:process_control/repositories/database/abstract_database_repository.dart';
import 'package:process_control/repositories/process_params.dart';

part 'result_event.dart';
part 'result_state.dart';

class ResultBloc extends Bloc<ResultEvent, ResultState> {
  ResultBloc(this.dbRepo) : super(DataInitial()) {
    on<GetListData>((event, emit) async {
      try {
        final data = await dbRepo.getData();
        final params = await dbRepo.getParams();
        emit(DataLoaded(data: data, params: params));
      } catch(e) {
        emit(DataLoadingFailure(exception: e));
      }
    });
  }

  final AbstractDatabaseRepository dbRepo;
}