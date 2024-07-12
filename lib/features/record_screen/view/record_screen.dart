import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:process_control/features/record_screen/bloc/recording_bloc.dart';
import 'package:process_control/features/record_screen/painters/any_picture_painter.dart';
import 'package:process_control/features/record_screen/painters/oscilloscope.dart';
import 'package:process_control/repositories/database/abstract_database_repository.dart';
import 'package:process_control/repositories/source/abstract_source_repository.dart';
import 'package:process_control/repositories/process_params.dart';

import '../painters/bar_diagram_painter.dart';

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
  int _n = 0;
  int _recCount = 0;
  final int _screenRate = 20;
  int _freq = 50;
  double _min = -10;
  double _max = -10;

  List<DataBlock> _block = []; // Данные для записи

  bool _isRecording = false;
  IconData _saveIcon = Icons.save_outlined;

  @override
  void initState() {
    _pcBloc.add(InitSendDataEvent(func: getData));
    super.initState();
  }

  void getData(double ax, double ay, double az) async {
    ++_n;
    _block.add(DataBlock(ax: ax, ay: ay, az: az));
    if (_isRecording) {
      await _database.add(DataBlock(ax: ax, ay: ay, az: az));
      ++_recCount;
    }

    if (_n % (_freq / _screenRate) == 0) {
      setState(() {
        _ax = ax;
        _ay = ay;
        _az = az;
      });
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
      await _database.setParams(_freq);
      Navigator.of(context).pushNamed('/result');
    } else {
      _database.clear();
    }
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
                        Text('A(x) : ',
                            style: Theme.of(context).textTheme.headlineMedium),
                        SizedBox(
                          width: 200,
                          child: Text('${num.parse(_ax.toStringAsFixed(4))}',
                              style:
                                  Theme.of(context).textTheme.headlineMedium),
                        ),
                      ]),
                      Row(children: [
                        Text('A(y) : ',
                            style: Theme.of(context).textTheme.headlineMedium),
                        SizedBox(
                          width: 200,
                          child: Text('${num.parse(_ay.toStringAsFixed(4))}',
                              //'$_ay',
                              style:
                                  Theme.of(context).textTheme.headlineMedium),
                        ),
                      ]),
                      Row(children: [
                        Text('A(z) : ',
                            style: Theme.of(context).textTheme.headlineMedium),
                        SizedBox(
                          width: 200,
                          child: Text('${num.parse(_az.toStringAsFixed(4))}',
                              //'$_az',
                              style:
                                  Theme.of(context).textTheme.headlineMedium),
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
                        child: Text(
                            '${num.parse((_recCount / _freq).toStringAsFixed(1))} сек',
                            style: Theme.of(context).textTheme.displayLarge),
                      )
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
          FloatingActionButton(
            onPressed: () {
              _pcBloc.add(CalibrationEvent());
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
