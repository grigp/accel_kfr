import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:process_control/repositories/source/abstract_source_repository.dart';

part 'recording_event.dart';
part 'recording_state.dart';

class ProcessControlBloc
    extends Bloc<RecordingEvent, RecordingState> {
  ProcessControlBloc(this.process) : super(RecordingState()) {
    on<InitSendDataEvent>((event, emit) async {
      try {
        final pp = await process.init(event.func);
        emit(ProcessGetFreq(freq: pp.freq, min: pp.min, max: pp.max));

      } catch (e) {
        emit(ProcessGetValueFailure(exception: e));
      }
    });

    on<SetModeEvent>((event, emit) async {
      try {
        await process.setMode(event.mode);
      } catch (e) {

      }
    });

    on<CalibrationEvent>((event, emit) async {
      try {
        await process.calibrate();
      } catch (e) {

      }
    });
  }

  final AbstractSourceRepository process;
}
