import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:process_control/features/record_screen/bloc/recording_bloc.dart';
import 'package:process_control/features/record_screen/painters/any_picture_painter.dart';
import 'package:process_control/features/record_screen/painters/oscilloscope.dart';
import 'package:process_control/repositories/database/abstract_database_repository.dart';
import 'package:process_control/repositories/source/abstract_source_repository.dart';
import 'package:process_control/repositories/process_params.dart';

import '../painters/bar_diagram_painter.dart';

enum RecordStages { stgNone, stgWait1, stgCalibrating, stgWait2, stgRecording }

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key, required this.title});

  final String title;

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  final _pcBloc = ProcessControlBloc(GetIt.I<AbstractSourceRepository>());
  final _database = GetIt.I<AbstractDatabaseRepository>();

  double _ax = 0;
  double _ay = 0;
  double _az = 0;
  double _gx = 0;
  double _gy = 0;
  double _gz = 0;
  int _n = 0;
  int _recCount = 0;
  final int _screenRate = 20;
  int _freq = 50;
  double _min = -10;
  double _max = -10;
  int _timeWait = 4;
  int _timeRec = 20;
  RecordStages _stage = RecordStages.stgNone;

  List<DataBlock> _block = []; // Данные для записи

  bool _isRecording = false;
  IconData _saveIcon = Icons.save_outlined;

  @override
  void initState() {
    _pcBloc.add(InitSendDataEvent(func: getData));
    getSettings();
    super.initState();
  }

  

  void getSettings() async {
    const storage = FlutterSecureStorage();
    String? stw = await storage.read(key: 'time_wait');
    if (stw != null) {
      _timeWait = int.tryParse(stw)!;
    }
    String? str = await storage.read(key: 'time_record');
    if (str != null) {
      _timeRec = int.tryParse(str)!;
    }
    _pcBloc.add(UpdateParamsEvent());
  }

  void getData(
      double ax, double ay, double az, double gx, double gy, double gz) async {
    ++_n;
    _block.add(DataBlock(ax: ax, ay: ay, az: az, gx: gx, gy: gy, gz: gz));

    if (_n % (_freq / _screenRate) == 0) {
      setState(() {
        _ax = ax;
        _ay = ay;
        _az = az;
        _gx = gx;
        _gy = gy;
        _gz = gz;
      });
    }

    if (_isRecording) {
      if (_stage == RecordStages.stgRecording) {
        await _database
            .add(DataBlock(ax: ax, ay: ay, az: az, gx: gx, gy: gy, gz: gz));
      }

      ++_recCount;
      if (_stage == RecordStages.stgWait1) {
        if (_recCount == _timeWait * _freq) {
          _recCount = 0;
          _stage = RecordStages.stgCalibrating;
          _pcBloc.add(CalibrationEvent(func: onEndCalibration));
        }
      } else if (_stage == RecordStages.stgWait2) {
//        if (_recCount == _timeWait * _freq) {
        if (_recCount == 1 * _freq) {
          _recCount = 0;
          _stage = RecordStages.stgRecording;
        }
      } else if (_stage == RecordStages.stgRecording) {
        if (_recCount == _timeRec * _freq) {
          _isRecording = false;
          _recCount = 0;
          _stage = RecordStages.stgNone;
          await _database.setParams(_freq);
          Navigator.of(context).pushNamed('/result');
          AssetsAudioPlayer.newPlayer().open(
            Audio('sounds/ok.mp3'),
            autoStart: true,
          );
          setState(() {
            _saveIcon = Icons.save_outlined;
          });
        }
      }
    }
  }

  void onEndCalibration() async {
    if (_isRecording) {
      _recCount = 0;
      _stage = RecordStages.stgWait2;
    }
  }

  void _setRecording() async {
    _isRecording = !_isRecording;
    _recCount = 0;
    setState(() {
      if (_isRecording) {
        _saveIcon = Icons.save_rounded;
      } else {
        _saveIcon = Icons.save_outlined;
      }
    });

    //! Остановили запись
    if (!_isRecording) {
      _stage = RecordStages.stgNone;
      await _database.setParams(_freq);
      Navigator.of(context).pushNamed('/result');
    } else {
      _stage = RecordStages.stgWait1;
      _database.clear();
    }
  }

  String getStageTime() {
    if (_stage == RecordStages.stgCalibrating ||
        _stage == RecordStages.stgRecording) {
      return '${num.parse((_recCount / _freq).toStringAsFixed(1))} сек';
    } else if (_stage == RecordStages.stgWait1) {
      return '${num.parse((_timeWait - (_recCount / _freq)).toStringAsFixed(1))} сек';
    }
    if (_stage == RecordStages.stgWait2) {
      return '${num.parse((1 - (_recCount / _freq)).toStringAsFixed(1))} сек';
    }
    return '';
  }

  String getStageComment() {
    if (_stage == RecordStages.stgWait1) {
      return 'До калибровки';
    } else if (_stage == RecordStages.stgCalibrating) {
      return 'Калибровка';
    } else if (_stage == RecordStages.stgWait2) {
      return 'До записи';
    }
    if (_stage == RecordStages.stgRecording) {
      return 'Запись $_timeRec сек';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: BlocBuilder<ProcessControlBloc, RecordingState>(
        bloc: _pcBloc,
        builder: (context, state) {
          if (state is ProcessGetFreq) {
            String sTimer = getStageTime();
            String sStage = getStageComment();
            _freq = state.freq;
            _min = state.min;
            _max = state.max;
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Stack(
                  children: <Widget>[
                    Column(children: [
                      Row(children: [
                        Text(
                          'A(x):',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        SizedBox(
                          width: 120,
                          child: Text(
                            '${num.parse(_ax.toStringAsFixed(4))}',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                        Text(
                          'G(x):',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        SizedBox(
                          width: 120,
                          child: Text(
                            '${num.parse(_gx.toStringAsFixed(4))}',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                      ]),
                      Row(children: [
                        Text(
                          'A(y):',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        SizedBox(
                          width: 120,
                          child: Text(
                            '${num.parse(_ay.toStringAsFixed(4))}',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                        Text(
                          'G(y):',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        SizedBox(
                          width: 120,
                          child: Text(
                            '${num.parse(_gy.toStringAsFixed(4))}',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                      ]),
                      Row(children: [
                        Text(
                          'A(z):',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        SizedBox(
                          width: 120,
                          child: Text(
                            '${num.parse(_az.toStringAsFixed(4))}',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                        Text(
                          'G(z):',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        SizedBox(
                          width: 120,
                          child: Text(
                            '${num.parse(_gz.toStringAsFixed(4))}',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                      ]),
                      const SizedBox(
                        height: 10,
                      ),
                      Expanded(
                        child: Row(children: [
                          Expanded(
                            child: SizedBox(
                              height: double.infinity,
                              child: CustomPaint(
                                painter: Oscilloscope(_block, _min, _max),
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ]),
                    if (_isRecording)
                      Center(
                          child: Column(
                        children: [
                          const SizedBox(height: 200),
                          Text(sStage,
                              style: Theme.of(context).textTheme.displaySmall),
                          Text(sTimer,
                              style: Theme.of(context).textTheme.displayLarge),
                        ],
                      ))
                  ],
                ),
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (!_isRecording)
            FloatingActionButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/settings');
              },
              heroTag: 'Settings',
              tooltip: 'Настройки',
              child: const Icon(Icons.settings),
            ),
          const SizedBox(
            width: 60,
          ),
          if (!_isRecording)
            FloatingActionButton(
              onPressed: () {
                _pcBloc.add(CalibrationEvent(func: onEndCalibration));
              },
              heroTag: 'Calibrate',
              tooltip: 'Калибровка',
              child: const Icon(Icons.center_focus_strong),
            ),
          const SizedBox(
            width: 40,
          ),
          FloatingActionButton(
            onPressed: _setRecording,
            heroTag: 'Recording',
            tooltip: 'Запись',
            child: Icon(_saveIcon), //Icons.save),
          ),
        ],
      ),
    );
  }
}
