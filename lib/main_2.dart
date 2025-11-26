import 'package:flutter/material.dart';

// Example 2: This extracts the logic from the HomePage so it is now just a dumb widget.
// It simply displays the data it is given (the model), and calls a given callback when the button is pressed.
// However, while the HomePage is improved, the MyApp widget is now responsible for knowing how to write to the appState.

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
// The logic of how to write to the appState has been moved here
class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.appState});
  final ValueNotifier<DomainModel> appState;
  
  @override
  Widget build(BuildContext _) {
    return ValueListenableBuilder(
      valueListenable: appState,
      builder: (_, _, _) {
        return MaterialApp(
          home: MyHomePage(domainModel: appState.value, buttonCallback: () {
            appState.value = DomainModel(appState.value.counter + 1);
          }),
        );
      }
    );
  }
}

// The home page of the application.
// This is now just a dumb widget that displays the data it is given, and calls a callback when the button is pressed.
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.domainModel, required this.buttonCallback});
  final DomainModel domainModel;
  final VoidCallback buttonCallback;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Value: ${domainModel.counter}')),
      floatingActionButton: FloatingActionButton(
        onPressed: buttonCallback,
        child: const Icon(Icons.add),
      ), 
    );
  }
}