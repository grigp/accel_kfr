
part of 'recording_bloc.dart';

class RecordingState{}

class ProcessGetFreq extends RecordingState{
  ProcessGetFreq({
    required this.freq,
    required this.min,
    required this.max
  });
  final int freq;
  final double min;
  final double max;
}

class ProcessGetValueFailure extends RecordingState {
  ProcessGetValueFailure({
    this.exception,
  });
  final Object? exception;
}

class ProcessSetMode extends RecordingState{
  ProcessSetMode({
    required this.mode,
  });
  final ChaningMode mode;
}

class ProcessSetModeFailure extends RecordingState {
  ProcessSetModeFailure({
    this.exception,
  });
  final Object? exception;
}
