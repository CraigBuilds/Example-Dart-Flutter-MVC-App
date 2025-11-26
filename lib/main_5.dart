import 'package:flutter/material.dart';

// ------------------- Domain Model ------------------
// The data used to define the state of the application (defines how the UI looks at any point in time)
// It is a modeled after a domain area (e.g robotics, banking, fitness, etc) and can use structures that best represent that domain.
// In this example, we have a simple counter application, so the domain model is just a single integer value.

class CounterModel {
  final int counter;
  const CounterModel(this.counter);
}


// ------------------- Controllers (Business Logic Layer) ------------------
// It is tempting to define methods on the CounterModel itself to mutate its state (e.g increment, decrement), or to define extension methods on it,
// but by using controller objects that contain a reference to the model, we can restrict UI components from being able to mutate the model unless they have access to a controller.
// This helps enforce separation of concerns.
// It is tempting to put a ValueNotifier inside the controller, but that would couple the controller to a specific state management approach.
// Instead, we pass in a callback that the controller can use to notify when the model has changed, and we wire it all together in the application entry point.
// We can separate controllers for different use cases (e.g incrementing vs decrementing), so that UI components only have access to the functionality they need.

class CounterUpController {
  CounterModel _model;
  final void Function(CounterModel newModel) onModelChanged;
  CounterUpController(this._model, this.onModelChanged);
  void incrementCounter() {
    _model = CounterModel(_model.counter + 1);
    onModelChanged(_model);
  }
}

class CounterDownController {
  CounterModel _model;
  final void Function(CounterModel newModel) onModelChanged;
  CounterDownController(this._model, this.onModelChanged);
  void decrementCounter() {
    _model = CounterModel(_model.counter - 1);
    onModelChanged(_model);
  }
}

// ------------------- Application Entry Point and Wiring together ------------------
// The application entry point is responsible for creating the domain model, creating the reactivity mechanism (ValueNotifier) that notifies the ValueListenableBuilder
// of changes to the model, wiring together controllers to that reactivity mechanism, and defining the root widget of the widget tree (A MaterialApp with a home
// page and routes). The home page and routes are "Views" (The main pages of our UI application), and Views have access to the domain model and an appropriate controller.

void main() {
  final model = ValueNotifier(const CounterModel(0));

  runApp(
    ValueListenableBuilder(
      valueListenable: model,
      builder: (_, __, ___) => MaterialApp(
        home: CounterUpView(model: model.value, controller: CounterUpController(model.value, (newValue) => model.value = newValue)),
        routes: {
          '/down': (_) => CounterDownView(model: model.value, controller: CounterDownController(model.value, (newValue) => model.value = newValue)),
        },
      ),
    ),
  );
}

// ------------------- Pages (Main Declarative UI Code) ------------------
// Pages are the main screens of our application. They are responsible for declaratively composing smaller widgets together to form the full screen UI.
// Pages have access to the domain model and appropriate controllers to handle user interactions.
// They pass the appropriate data from the domain model into it's display widgets, and it passes appropriate controller methods into the interaction widgets.
// It should not pass the entire model or controller down to child widgets, only the data and methods that those child widgets need. Pages are the only Widgets
// that have access to the model or controller objects. This keeps the widgets "dumb". They simply display the data they are given, and call the methods they
// are given when user interactions occur.
// Pages should not use reference theme data directly. The child widgets should use the context to retrieve theme data as needed. 

class CounterUpView extends StatelessWidget {
  final CounterModel model;
  final CounterUpController controller;
  const CounterUpView({super.key, required this.model, required this.controller});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: CenteredValue(value: model.counter),
    floatingActionButton: PlusMinusFloatingActionButton(onPlus: controller.incrementCounter),
    appBar: BackForthAppBar(onBack: ()=>Navigator.of(context).pushNamed('/down'), onForth: (){}),
  );
}

class CounterDownView extends StatelessWidget {
  final CounterModel model;
  final CounterDownController controller;
  const CounterDownView({super.key, required this.model, required this.controller});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: CenteredValue(value: model.counter),
    floatingActionButton: PlusMinusFloatingActionButton(onMinus: controller.decrementCounter),
    appBar: BackForthAppBar(onBack: Navigator.of(context).pop, onForth: ()=>Navigator.of(context).pushNamed('/')),
  );
}


// ------------------- Widgets ------------------
// Widgets are the building blocks of our UI. They should be as dumb as possible. They simply display the data they are given, and call the methods they
// are given when user interactions occur. They should not have any knowledge of the domain model or controllers.
// They can use the BuildContext to retrieve theme data as needed. It is better to do that here rather than in the parent, so that widgets have consistent
// theming across the application.

class CenteredValue extends StatelessWidget {
  final int value;
  const CenteredValue({super.key, required this.value});
  @override
  Widget build(BuildContext context) => Center(child: Text('Value: $value'));
}

class BackForthAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onBack;
  final VoidCallback onForth;
  const BackForthAppBar({super.key, required this.onBack, required this.onForth});

  @override
  Widget build(BuildContext context) => AppBar(
    actions: [
      IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onBack,
      ),
      IconButton(
        icon: const Icon(Icons.arrow_forward),
        onPressed: onForth,
      ),
    ],
  );

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class PlusMinusFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPlus;
  final VoidCallback? onMinus;
  const PlusMinusFloatingActionButton({super.key, this.onPlus, this.onMinus});

  @override
  Widget build(BuildContext context) => FloatingActionButton(
    onPressed: onPlus ?? onMinus,
    child: Icon(onPlus != null ? Icons.add : Icons.remove),
  );
}
