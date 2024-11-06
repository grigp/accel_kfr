import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:process_control/calculators/calculate_defines.dart';
import 'package:process_control/calculators/kfr_calculator.dart';
import 'package:process_control/features/result_screen/bloc/kfr_calculator_bloc.dart';
import 'package:process_control/features/result_screen/bloc/result_bloc.dart';
import 'package:process_control/features/result_screen/painters/graph.dart';
import 'package:process_control/features/result_screen/painters/histogram.dart';
import 'package:process_control/repositories/process_params.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../../../repositories/database/abstract_database_repository.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.title});

  final String title;

  @override
  State<StatefulWidget> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final _database = ResultBloc(GetIt.I<AbstractDatabaseRepository>());
  DecimalSeparator _ds = DecimalSeparator.dsComma;

  @override
  void initState() {
    _database.add(GetListData());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: BlocBuilder<ResultBloc, ResultState>(
        bloc: _database,
        builder: (context, state) {
          if (state is DataLoaded) {
            var kfr = KfrCalculator(state.data);
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                        'КФР = ${num.parse(kfr.factor(0).value.toStringAsFixed(0))} %',
                        style: Theme.of(context).textTheme.headlineMedium),
                    SizedBox(
                      height: 150,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: Histogram(data: kfr.diagram(), max: 100),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: double.infinity,
                              child: CustomPaint(
                                painter: Graph(state.data, state.params.freq),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    FloatingActionButton(
                      onPressed: () async {
                        final dir = Platform.isAndroid
                            ? await getExternalStorageDirectory()
                            : await getApplicationSupportDirectory();

                        var f = File('${dir?.path}/exchange.log');
                        if (await f.exists()) {
                          f.delete();
                        }
                        await f.writeAsString(dataToString(state.data));
                        Share.shareXFiles([XFile('${dir?.path}/exchange.log')],
                            text: 'Сигналы акселерограммы по x, y и z');

                        //Share.share(dataToString(state.data));
                      },
                      heroTag: 'Share',
                      tooltip: 'Поделиться',
                      child: const Icon(Icons.share),
                    ),
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
    );
  }

  void getValues() async {
    const storage = FlutterSecureStorage();
    String? stds = await storage.read(key: 'decimal_separator');
    if (stds != null) {
      _ds = DecimalSeparator.values[int.tryParse(stds)!];
    }
  }

  String getValue(double val) {
    String sval = '$val';
    String retval = '';
    for (int i = 0; i < sval.length; ++i) {
      if (sval[i] != '.' && sval[i] != ',') {
        retval = '$retval${sval[i]}';
      } else {
        if (_ds == DecimalSeparator.dsPoint) {
          retval = '$retval.';
        } else if (_ds == DecimalSeparator.dsComma) {
          retval = '$retval,';
        }
      }
    }
    print('-------------------- $_ds --- ${retval}');
    return retval;
  }

  String dataToString(List<DataBlock> data) {
    String retval = '';

    getValues();

    for (int i = 0; i < data.length; ++i) {
      retval =
          '$retval${getValue(data[i].ax)}\t${getValue(data[i].ay)}\t${getValue(data[i].az)}\t${getValue(data[i].gx)}\t${getValue(data[i].gy)}\t${getValue(data[i].gz)}\n';
  //     print('--------------------$i : $_ds ---- $retval');
    }
    return retval;
  }
}
