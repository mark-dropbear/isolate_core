import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:isolate_core/api/models/thing.dart';
import 'package:isolate_core/domain/usecases/save_thing_usecase.dart';
import 'package:isolate_core/ui/viewmodels/thing_detail_viewmodel.dart';
import 'package:isolate_core/ui/views/thing_form_screen.dart';

import '../../fakes/fake_thing_repository.dart';

void main() {
  group('ThingFormScreen Widget Tests', () {
    late FakeThingRepository fakeRepo;
    late ThingDetailViewModel viewModel;

    setUp(() {
      fakeRepo = FakeThingRepository();
      viewModel = ThingDetailViewModel(SaveThingUseCase(fakeRepo));
    });

    testWidgets('renders create mode when no existing thing is provided', (
      WidgetTester tester,
    ) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Container(),
          ),
          GoRoute(
            path: '/form',
            builder: (context, state) => ThingFormScreen(viewModel: viewModel),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(routerConfig: router),
      );
      router.push('/form');
      await tester.pumpAndSettle();

      expect(find.text('Create Thing'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);

      // Text field should be empty
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, isEmpty);
    });

    testWidgets('renders edit mode when existing thing is provided', (
      WidgetTester tester,
    ) async {
      const existing = Thing(name: 'things/1', displayName: 'Existing Apple');

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Container(),
          ),
          GoRoute(
            path: '/form',
            builder: (context, state) => ThingFormScreen(viewModel: viewModel, thing: existing),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(routerConfig: router),
      );
      router.push('/form');
      await tester.pumpAndSettle();

      expect(find.text('Edit Thing'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);

      // Text field should be populated
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, 'Existing Apple');
    });

    testWidgets('filling form and tapping create saves the thing', (
      WidgetTester tester,
    ) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Container(),
          ),
          GoRoute(
            path: '/form',
            builder: (context, state) => ThingFormScreen(viewModel: viewModel),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(routerConfig: router),
      );
      router.push('/form');
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'New Banana');
      await tester.pump(); // Register the text input

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final things = await fakeRepo.getThings();
      expect(things.length, 1);
      expect(things.first.displayName, 'New Banana');
    });

    testWidgets('filling form and tapping update modifies existing thing', (
      WidgetTester tester,
    ) async {
      const existing = Thing(name: 'things/1', displayName: 'Old Apple');
      fakeRepo.seed([existing]);

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Container(),
          ),
          GoRoute(
            path: '/form',
            builder: (context, state) => ThingFormScreen(viewModel: viewModel, thing: existing),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(routerConfig: router),
      );
      router.push('/form');
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Fresh Apple');
      await tester.pump();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final things = await fakeRepo.getThings();
      expect(things.length, 1);
      expect(things.first.name, 'things/1');
      expect(things.first.displayName, 'Fresh Apple');
    });
  });
}
