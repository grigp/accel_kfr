
part of 'recording_bloc.dart';

class RecordingEvent{}

class InitSendDataEvent extends RecordingEvent {
  InitSendDataEvent({
    required this.func
  });
  Function func;
}

class SetModeEvent extends RecordingEvent {
  SetModeEvent({
    required this.mode,
  });
  final ChaningMode mode;
}

class CalibrationEvent extends RecordingEvent {
  CalibrationEvent({
    required this.func
  });
  Function func;
}

class UpdateParamsEvent extends RecordingEvent {}
