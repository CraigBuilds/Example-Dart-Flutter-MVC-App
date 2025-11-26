import 'package:flutter/material.dart';

// Example 3: 
// This extracts the logic of how to mutate the state into a separate controller class.
// The HomePage is still a dumb widget, and the MyApp widget now delegates the state mutation to the controller.

// The Data used to define the state of the application (defines how the UI looks at any point in time)
class DomainModel {
  final int counter;
  DomainModel(this.counter);
}

//Contains a reference to the ValueNotifier and exposes methods to mutate the state.
class CounterController {
  final ValueNotifier<DomainModel> _appState;
  CounterController(this._appState);
  void incrementCounter() {
    _appState.value = DomainModel(_appState.value.counter + 1);
  }
}

void main() {
  final appState = ValueNotifier(DomainModel(0));
  runApp(MyApp(appState: appState));
}

// The root widget of the application.
// It listens if the appState has been changed (the single value has been replaced with a new DomainModel instance), and rebuilds the full widget tree when that happens.
// The logic of how to write to the appState has been moved to the CounterController
class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.appState});
  final ValueNotifier<DomainModel> appState;
  
  @override
  Widget build(BuildContext _) {
    return ValueListenableBuilder(
      valueListenable: appState,
      builder: (_, _, _) {
        return MaterialApp(
          home: MyHomePage(domainModel: appState.value, counterController: CounterController(appState)),
        );
      }
    );
  }
}

// The home page of the application.
// Top level Pages contain controllers. Downstream widgets are even dumber.
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.domainModel, required this.counterController});
  final DomainModel domainModel;
  final CounterController counterController;

  @override
  Widget build(BuildContext context) {
    return ValueAndButton(
      value: domainModel.counter,
      onPressed: () {
        counterController.incrementCounter();
      },
    );
  }
}

//Widgets do not contain controllers, they get the exact data they need, and delegate behavior upstream.
class ValueAndButton extends StatelessWidget {
  const ValueAndButton({super.key, required this.value, required this.onPressed});
  final int value;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Value: $value')),
      floatingActionButton: FloatingActionButton(
        onPressed: onPressed,
        child: const Icon(Icons.add),
      ), 
    );  
  }
}