import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:number_text_input_formatter/number_text_input_formatter.dart';
import 'package:process_control/calculators/kfr_calculator.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.title});

  final String title;

  @override
  State<StatefulWidget> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _textDiapsKoef;
  late TextEditingController _textTimeWait;
  late TextEditingController _textTimeCalibr;
  late TextEditingController _textTimeRec;
  bool _isReady = false;

  double _diapsKoef = 0.043599;  //active = 0.247167
  int _timeWait = 4;
  int _timeCalibr = 1;
  int _timeRec = 20;

  void getValues() async {
    const storage =  FlutterSecureStorage();
    String? sdk = await storage.read(key: 'diaps_koef');
    print('sdk : ------------------ $sdk');
    if (sdk != null) {
      _diapsKoef = double.tryParse(sdk)!;
    }

//    _diapsKoef = KfrCalculator.diapDistance();
    _textDiapsKoef = TextEditingController(text: _diapsKoef.toString());
    _textTimeWait = TextEditingController(text: _timeWait.toString());
    _textTimeCalibr = TextEditingController(text: _timeCalibr.toString());
    _textTimeRec = TextEditingController(text: _timeRec.toString());
    setState(() {
      _isReady = true;
    });
  }

  void saveValues() async {
    const storage =  FlutterSecureStorage();
    var s = _diapsKoef.toString();
//    await storage.delete(key: 'diaps_koef');
    await storage.write(key: 'diaps_koef', value: s);
    KfrCalculator.setDiapDistance(_diapsKoef);
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
              Text('Коэффициент диапазонов',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(
                width: 20,
              ),
              if(_isReady) SizedBox(
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
              const SizedBox(height: 20),
              Text('Время ожидания, сек',
                style: Theme.of(context).textTheme.headlineSmall,),
              if(_isReady) SizedBox(
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
              const SizedBox(height: 20),
              Text('Время калибровки, сек',
                style: Theme.of(context).textTheme.headlineSmall,),
              if(_isReady) SizedBox(
                width: 100,
                child: TextField(
                  controller: _textTimeCalibr,
                  style: Theme.of(context).textTheme.headlineSmall,
                  inputFormatters: [
                    NumberTextInputFormatter(
                      integerDigits: 2,
                      decimalDigits: 0,
                      maxValue: '3',
                      allowNegative: false,
                    )
                  ],
                  onChanged: (String value) {
                    _timeCalibr = int.tryParse(value)!;
                  },
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(height: 20),
              Text('Время записи, сек',
                style: Theme.of(context).textTheme.headlineSmall,),
              if(_isReady) SizedBox(
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
              const Expanded(child: SizedBox(height: double.infinity)),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      saveValues();
                      Navigator.of(context).pushNamed('/');
                    },
                    child: Text('Сохранить',
                        style: Theme.of(context).textTheme.headlineSmall),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/');
                      },
                      child: Text('Отмена',
                          style: Theme.of(context).textTheme.headlineSmall))
                ],
              )
            ],
          ),
        ));
  }
}
