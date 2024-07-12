
import 'package:flutter/material.dart';
import 'package:process_control/router/routes.dart';

class ProcessControlApp extends StatelessWidget {
  const ProcessControlApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Process control',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: routes,
//      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
