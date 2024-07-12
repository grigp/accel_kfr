import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:process_control/process_control_app.dart';
import 'package:process_control/repositories/database/abstract_database_repository.dart';
import 'package:process_control/repositories/database/database.dart';
import 'package:process_control/repositories/source/abstract_source_repository.dart';
import 'package:process_control/repositories/source/accel_driver.dart';
import 'package:process_control/repositories/source/sinus_generator.dart';

void main() {
  GetIt.I.registerLazySingleton<AbstractSourceRepository>(
          () => AccelDriver()//SinusGenerator()
  );

  GetIt.I.registerLazySingleton<AbstractDatabaseRepository>(
          () => Database()
  );

  runApp(const ProcessControlApp());
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

// class ProcessControlScreen extends StatefulWidget {
//   const ProcessControlScreen({super.key, required this.title});
//
//   final String title;
//
//   @override
//   State<ProcessControlScreen> createState() => _ProcessControlScreenState();
// }
//
// class _ProcessControlScreenState extends State<ProcessControlScreen> {
//   int _counter = 0;
//
//   void _incrementCounter() {
//     setState(() {
//       _counter++;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }
