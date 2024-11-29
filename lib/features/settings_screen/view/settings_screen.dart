import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:number_text_input_formatter/number_text_input_formatter.dart';
import 'package:process_control/calculators/kfr_calculator.dart';

import '../../../calculators/calculate_defines.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.title,
    required this.onAccept
  });

  final String title;
  final Function onAccept;

  @override
  State<StatefulWidget> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _textDiapsKoef;
  late TextEditingController _textTimeWait;
  late TextEditingController _textTimeCalibr;
  late TextEditingController _textTimeRec;
  bool _isReady = false;

  double _diapsKoef = 0.025;//0.043599; //active = 0.247167
  int _timeWait = 4;
  int _timeCalibr = 1;
  int _timeRec = 20;
  bool _isFilter = true;
  bool _isZeroing = true;

  ///< Режим расчета и ориентации устройства
  ///< cdm3D - трехмерный расчет (свободное расположение устройства),
  ///< cdmVertical - X и Z (вертикальное расположение устройства),
  ///< cdmHorizontal - X и Y (горизонтальное расположение устройства)
  CalculateDirectionMode _cdm = CalculateDirectionMode.cdm3D;

  ///< Разделитель целой и дробной частей числа
  DecimalSeparator _ds = DecimalSeparator.dsComma;

  void getValues() async {
    const storage = FlutterSecureStorage();
    String? sdk = await storage.read(key: 'diaps_koef');
    if (sdk != null) {
      _diapsKoef = double.tryParse(sdk)!;
    }
    String? stw = await storage.read(key: 'time_wait');
    if (stw != null) {
      _timeWait = int.tryParse(stw)!;
    }
    String? stc = await storage.read(key: 'time_calibration');
    if (stc != null) {
      _timeCalibr = int.tryParse(stc)!;
    }
    String? str = await storage.read(key: 'time_record');
    if (str != null) {
      _timeRec = int.tryParse(str)!;
    }
    String? stcdm = await storage.read(key: 'calculate_direction_mode');
    if (stcdm != null) {
      _cdm = CalculateDirectionMode.values[int.tryParse(stcdm)!];
    }
    String? stds = await storage.read(key: 'decimal_separator');
    if (stds != null) {
      _ds = DecimalSeparator.values[int.tryParse(stds)!];
    }

    String? stf = await storage.read(key: 'filtration');
    if (stf != null) {
      if (stf == "1") {
        _isFilter = true;
      } else {
        _isFilter = false;
      }
    }

    String? stz = await storage.read(key: 'zeroing');
    if (stz != null) {
      if (stz == "1") {
        _isZeroing = true;
      } else {
        _isZeroing = false;
      }
    }

    _textDiapsKoef = TextEditingController(text: _diapsKoef.toString());
    _textTimeWait = TextEditingController(text: _timeWait.toString());
    _textTimeCalibr = TextEditingController(text: _timeCalibr.toString());
    _textTimeRec = TextEditingController(text: _timeRec.toString());
    setState(() {
      _isReady = true;
    });
  }

  Future saveValues() async {
    const storage = FlutterSecureStorage();
    var s = _diapsKoef.toString();
    await storage.write(key: 'diaps_koef', value: s);
    KfrCalculator.setDiapDistance(_diapsKoef);
    s = _timeWait.toString();
    await storage.write(key: 'time_wait', value: s);
    s = _timeCalibr.toString();
    await storage.write(key: 'time_calibration', value: s);
    s = _timeRec.toString();
    await storage.write(key: 'time_record', value: s);
    s = _cdm.index.toString();
    await storage.write(key: 'calculate_direction_mode', value: s);
    s = _ds.index.toString();
    await storage.write(key: 'decimal_separator', value: s);
    if (_isFilter) {
      s = '1';
    } else {
      s = '0';
    }
    await storage.write(key: 'filtration', value: s);
    if (_isZeroing) {
      s = '1';
    } else {
      s = '0';
    }
    await storage.write(key: 'zeroing', value: s);
  }

  @override
  void initState() {
    super.initState();

    getValues();
  }

  @override
  void dispose() {
    _textDiapsKoef.dispose();
    _textTimeWait.dispose();
    _textTimeCalibr.dispose();
    _textTimeRec.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    'Коэф-т диапазонов',
                    style: TextStyle(fontSize: 18),
                  ),
                  const Spacer(),
                  if (_isReady)
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: _textDiapsKoef,
                        style: Theme.of(context).textTheme.headlineSmall,
                        inputFormatters: [
                          NumberTextInputFormatter(
                            integerDigits: 8,
                            decimalDigits: 6,
                            decimalSeparator: '.',
                            allowNegative: false,
                          )
                        ],
                        onChanged: (String value) {
                          _diapsKoef = double.tryParse(value)!;
                        },
                        keyboardType: TextInputType.number,
                      ),
                    ),
                ],
              ),
//              const SizedBox(height: 10),
              Row(
                children: [
                  const Text(
                    'Время ожидания, с',
                    style: TextStyle(fontSize: 18),
                  ),
                  const Spacer(),
                  if (_isReady)
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: _textTimeWait,
                        style: Theme.of(context).textTheme.headlineSmall,
                        inputFormatters: [
                          NumberTextInputFormatter(
                            integerDigits: 2,
                            decimalDigits: 0,
                            maxValue: '20',
                            allowNegative: false,
                          )
                        ],
                        onChanged: (String value) {
                          _timeWait = int.tryParse(value)!;
                        },
                        keyboardType: TextInputType.number,
                      ),
                    ),
                ],
              ),
//              const SizedBox(height: 10),
              Row(
                children: [
                  const Text(
                    'Время калибровки, с',
                    style: TextStyle(fontSize: 18),
                  ),
                  const Spacer(),
                  if (_isReady)
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: _textTimeCalibr,
                        style: Theme.of(context).textTheme.headlineSmall,
                        inputFormatters: [
                          NumberTextInputFormatter(
                            integerDigits: 2,
                            decimalDigits: 0,
                            maxValue: '10',
                            allowNegative: false,
                          )
                        ],
                        onChanged: (String value) {
                          _timeCalibr = int.tryParse(value)!;
                        },
                        keyboardType: TextInputType.number,
                      ),
                    ),
                ],
              ),
//              const SizedBox(height: 10),
              Row(
                children: [
                  const Text(
                    'Время записи, с',
                    style: TextStyle(fontSize: 18),
                  ),
                  const Spacer(),
                  if (_isReady)
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: _textTimeRec,
                        style: Theme.of(context).textTheme.headlineSmall,
                        inputFormatters: [
                          NumberTextInputFormatter(
                            integerDigits: 2,
                            decimalDigits: 0,
                            maxValue: '60',
                            allowNegative: false,
                          )
                        ],
                        onChanged: (String value) {
                          _timeRec = int.tryParse(value)!;
                        },
                        keyboardType: TextInputType.number,
                      ),
                    ),
                ],
              ),
//              const SizedBox(height: 10),
              Row(
                children: [
                  const Text(
                    'Фильтрация',
                    style: TextStyle(fontSize: 18),
                  ),
                  const Spacer(),
                  if (_isReady)
                    Switch(
                      value: _isFilter,
                      onChanged: (bool value){
                        setState(() {
                          _isFilter = value;
                        });
                      },
                    ),
                ],
              ),
              Row(
                children: [
                  const Text(
                    'Центровка',
                    style: TextStyle(fontSize: 18),
                  ),
                  const Spacer(),
                  if (_isReady)
                    Switch(
                      value: _isZeroing,
                      onChanged: (bool value){
                        setState(() {
                          _isZeroing = value;
                        });
                      },
                    ),
                ],
              ),

              ///< Режим расчета и ориентации устройства
              ///< cdm3D - трехмерный расчет (свободное расположение устройства),
              ///< cdmVertical - X и Z (вертикальное расположение устройства),
              ///< cdmHorizontal - X и Y (горизонтальное расположение устройства)
              const Text(
                'Режим расчета',
                style: TextStyle(fontSize: 18),
              ),
              Column(
                children: <Widget>[
                  ListTile(
                    title: const Text(
                      'XYZ (произвольно)',
                      style: TextStyle(fontSize: 18),
                    ),
                    // subtitle: const Text(
                    //     'трехмерный расчет (свободное расположение устройства)'),
                    leading: Radio<CalculateDirectionMode>(
                      value: CalculateDirectionMode.cdm3D,
                      groupValue: _cdm,
                      onChanged: (CalculateDirectionMode? value) {
                        setState(() {
                          _cdm = value!;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text(
                      'XZ (вертикально)',
                      style: TextStyle(fontSize: 18),
                    ),
                    // subtitle:
                    //     const Text('вертикальное расположение устройства'),
                    leading: Radio<CalculateDirectionMode>(
                      value: CalculateDirectionMode.cdmVertical,
                      groupValue: _cdm,
                      onChanged: (CalculateDirectionMode? value) {
                        setState(() {
                          _cdm = value!;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text(
                      'XY (горизонтально)',
                      style: TextStyle(fontSize: 18),
                    ),
                    // subtitle:
                    //     const Text('горизонтальное расположение устройства'),
                    leading: Radio<CalculateDirectionMode>(
                      value: CalculateDirectionMode.cdmHorizontal,
                      groupValue: _cdm,
                      onChanged: (CalculateDirectionMode? value) {
                        setState(() {
                          _cdm = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const Text(
                'Разделитель частей числа',
                style: TextStyle(fontSize: 14),
              ),
              // Column(
              //   children: <Widget>[
              //     ListTile(
              //       title: const Text(
              //         'Точка',
              //         style: TextStyle(fontSize: 14),
              //       ),
              //       leading: Radio<DecimalSeparator>(
              //         value: DecimalSeparator.dsPoint,
              //         groupValue: _ds,
              //         onChanged: (DecimalSeparator? value) {
              //           setState(() {
              //             _ds = value!;
              //           });
              //         },
              //       ),
              //     ),
              //     ListTile(
              //       title: const Text(
              //         'Запятая',
              //         style: TextStyle(fontSize: 14),
              //       ),
              //       leading: Radio<DecimalSeparator>(
              //         value: DecimalSeparator.dsComma,
              //         groupValue: _ds,
              //         onChanged: (DecimalSeparator? value) {
              //           setState(() {
              //             _ds = value!;
              //           });
              //         },
              //       ),
              //     ),
              //   ],
              // ),
              SegmentedButton<DecimalSeparator>(
                segments: const <ButtonSegment<DecimalSeparator>>[
                  ButtonSegment<DecimalSeparator>(
                    value: DecimalSeparator.dsPoint,
                    label: Text('Точка'),
                  ),
                  ButtonSegment<DecimalSeparator>(
                    value: DecimalSeparator.dsComma,
                    label: Text('Запятая'),
                  ),
                ],
                selected: <DecimalSeparator>{_ds},
                onSelectionChanged: (Set<DecimalSeparator> newSelection) {
                  setState(() {
                    _ds = newSelection.first;
//                    widget.onAmModeChanged(widget.amMode);
                  });
                },
              ),
              const Expanded(child: SizedBox(height: double.infinity)),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await saveValues();
                      await widget.onAccept();
                      Navigator.of(context).popUntil(ModalRoute.withName('/'));
                    },
                    child: Text('Сохранить',
                        style: Theme.of(context).textTheme.headlineSmall),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).popUntil(ModalRoute.withName('/'));
                      },
                      child: Text('Отмена',
                          style: Theme.of(context).textTheme.headlineSmall))
                ],
              )
            ],
          ),
        ),
    );
  }
}
