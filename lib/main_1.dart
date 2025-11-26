import 'package:flutter/material.dart';

// Example 1: The most fundamental usage of ValueListenable and ValueListenableBuilder.
// This uses a ValueNotifier, which is a ChangeNotifier that holds a single value (`class ValueNotifier<T> extends ChangeNotifier implements ValueListenable<T>`)
// The ValueNotifier contains the domain model directly, and exposes it via its `value` getter and setter (which notifies listeners on set).

// The Data used to define the state of the application (defines how the UI looks at any point in time)
class DomainModel {
  final int counter;
  DomainModel(this.counter);
}

void main() {
  final appState = ValueNotifier(DomainModel(0));
  runApp(MyApp(appState: appState));
}

// The root widget of the application.
// It listens if the appState has been changed (the single value has been replaced with a new DomainModel instance), and rebuilds the full widget tree when that happens.
class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.appState});
  final ValueNotifier<DomainModel> appState;
  
  @override
  Widget build(BuildContext _) {
    return ValueListenableBuilder(
      valueListenable: appState,
      builder: (_, _, _) {
        return MaterialApp(
          home: MyHomePage(appState: appState),
        );
      }
    );
  }
}

// The home page of the application.
// It uses appState directly to read the domain model data, and replace the appState's value (triggering a rebuild).
// It is responsible for retrieving the data it requires from the value notifier, and how to set the value notifier so the app rebuilds.
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.appState});
  final ValueNotifier<DomainModel> appState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Value: ${appState.value.counter}')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          appState.value = DomainModel(appState.value.counter + 1);
        },
        child: const Icon(Icons.add),
      ), 
    );
  }
}