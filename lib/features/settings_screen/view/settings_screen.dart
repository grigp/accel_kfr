import 'package:flutter/material.dart';
import 'package:number_text_input_formatter/number_text_input_formatter.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.title});

  final String title;

  @override
  State<StatefulWidget> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
                Text('Коэффициент диапазонов',
                    style:
                    Theme.of(context).textTheme.bodyLarge),
                const SizedBox(width: 20,),
                SizedBox(
                  width: 100,
                  child: TextField(
                    inputFormatters: [
                      NumberTextInputFormatter(
                        integerDigits: 8,
                        decimalDigits: 6,
                        decimalSeparator: '.',
                        allowNegative: false,
                      )
                    ],

                    onChanged: (String value){
                      print(value);

                    },
                    keyboardType: TextInputType.number,
                  ),
                )

              ],
            )
          ],
        ),
      )
    );
  }
}
