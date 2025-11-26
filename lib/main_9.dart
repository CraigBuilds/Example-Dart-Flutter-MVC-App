import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  // Single global app model notifier
  final appModelNotifier = ValueNotifier<AppModel>(
    AppModel(counter: 0),
  );

  final appRouter = AppRouter(appModelNotifier);

  runApp(MyApp(
    router: appRouter.router,
  ));
}

/* ==================== Root app ==================== */

class MyApp extends StatelessWidget {
  final GoRouter router;

  const MyApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'GoRouter + Model Callback Demo',
      routerConfig: router,
    );
  }
}

/* ==================== Model ==================== */

class AppModel {
  final int counter;

  const AppModel({required this.counter});

  AppModel copyWith({int? counter}) {
    return AppModel(
      counter: counter ?? this.counter,
    );
  }
}

/* ==================== Router ==================== */

class AppRouter {
  final ValueNotifier<AppModel> appModelNotifier;
  late final GoRouter router;

  AppRouter(this.appModelNotifier) {
    router = GoRouter(
      initialLocation: '/',
      // When the model changes, GoRouter rebuilds routes
      refreshListenable: appModelNotifier,
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) {
            // Create controller from current model snapshot
            final controller = HomeController(model: appModelNotifier.value);

            // Wire controller callback to the global notifier
            controller.onModelChanged = (newModel) {
              appModelNotifier.value = newModel;
            };

            return HomeView(controller: controller);
          },
        ),
        GoRoute(
          path: '/details',
          name: 'details',
          builder: (context, state) {
            final controller = DetailsController(model: appModelNotifier.value);

            controller.onModelChanged = (newModel) {
              appModelNotifier.value = newModel;
            };

            return DetailsView(controller: controller);
          },
        ),
      ],
    );
  }
}

/* ==================== Controllers ==================== */

typedef ModelChangedCallback = void Function(AppModel model);

class HomeController {
  AppModel _model;
  ModelChangedCallback? onModelChanged;

  HomeController({required AppModel model}) : _model = model;

  AppModel get model => _model;

  void increment() {
    _model = _model.copyWith(counter: _model.counter + 1);
    onModelChanged?.call(_model);
  }

  void goToDetails(BuildContext context) {
    context.go('/details');
  }
}

class DetailsController {
  AppModel _model;
  ModelChangedCallback? onModelChanged;

  DetailsController({required AppModel model}) : _model = model;

  AppModel get model => _model;

  void resetCounter() {
    _model = _model.copyWith(counter: 0);
    onModelChanged?.call(_model);
  }

  void goBack(BuildContext context) {
    context.go('/');
  }
}

/* ==================== Views ==================== */

class HomeView extends StatelessWidget {
  final HomeController controller;

  const HomeView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Counter: ${controller.model.counter}',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: controller.increment,
              child: const Text('Increment'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => controller.goToDetails(context),
              child: const Text('Go to details'),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailsView extends StatelessWidget {
  final DetailsController controller;

  const DetailsView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Details')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Current counter: ${controller.model.counter}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: controller.resetCounter,
              child: const Text('Reset counter'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => controller.goBack(context),
              child: const Text('Back to home'),
            ),
          ],
        ),
      ),
    );
  }
}
