import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:process_control/calculators/kfr_calculator.dart';
import 'package:process_control/features/result_screen/bloc/kfr_calculator_bloc.dart';
import 'package:process_control/features/result_screen/bloc/result_bloc.dart';
import 'package:process_control/features/result_screen/painters/graph.dart';
import 'package:process_control/repositories/process_params.dart';

import '../../../repositories/database/abstract_database_repository.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.title});

  final String title;

  @override
  State<StatefulWidget> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final _database = ResultBloc(GetIt.I<AbstractDatabaseRepository>());
  final _kfrCalculator = KfrCalculatorBloc();

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
      body: Column(
        children: [
          BlocBuilder<ResultBloc, ResultState>(
            bloc: _database,
            builder: (context, state) {
              if (state is DataLoaded) {
                  _kfrCalculator.add(GetFactors(data: state.data));
                // var kfr = KfrCalculator(state.data);
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        BlocBuilder<KfrCalculatorBloc, CalculateState>(
                            bloc: _kfrCalculator,
                            builder: (context, state) {
                              if (state is KfrCalculate) {
                                return Text(
                                    'КФР = ${num.parse(state.factors.factor(0).value.toStringAsFixed(0))} %',
                                    style:
                                    Theme.of(context).textTheme.headlineMedium);
                              };
                              return const CircularProgressIndicator();
                            }),
                        // Text(
                        //     'КФР = ${num.parse(kfr.factor(0).value.toStringAsFixed(0))} %',
                        //     style: Theme.of(context).textTheme.headlineMedium),
                        Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                      height: double.infinity,
                                      child: CustomPaint(
                                        painter: Graph(state.data, state.params.freq),
                                      )),
                                )
                              ],
                            )
                        )
                      ],
                    ),
                  ),
                );
              }
              // else
              // if (state is KfrCalculate) {
              //   return Text(
              //       'КФР = ${num.parse(state.factors.factor(0).value.toStringAsFixed(0))} %',
              //       style:
              //       Theme.of(context).textTheme.headlineMedium);
              // }
              return const Center(
                child:  CircularProgressIndicator(),
              );
            },
          ),

        ],
      ),
    );
  }
}
