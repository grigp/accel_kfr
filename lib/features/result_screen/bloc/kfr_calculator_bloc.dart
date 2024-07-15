

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:process_control/features/result_screen/bloc/result_bloc.dart';

import '../../../calculators/kfr_calculator.dart';

class KfrCalculatorBloc extends Bloc<CalculateEvent, CalculateState> {
  KfrCalculatorBloc() : super(CalculateInitial()) {
    on<GetFactors>((event, emit) async {
      try {
        final kfr = KfrCalculator(event.data);
        emit(KfrCalculate(factors: kfr));
      } catch(e) {
        emit(KfrCalculateFailure(exception: e));
      }
    });
  }
}