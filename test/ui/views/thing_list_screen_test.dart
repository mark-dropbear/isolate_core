import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_core/api/models/thing.dart';
import 'package:isolate_core/domain/usecases/delete_thing_usecase.dart';
import 'package:isolate_core/domain/usecases/get_things_usecase.dart';
import 'package:isolate_core/ui/viewmodels/thing_list_viewmodel.dart';
import 'package:isolate_core/ui/views/thing_list_screen.dart';

import '../../fakes/fake_thing_repository.dart';

void main() {
  group('ThingListScreen Widget Tests', () {
    late FakeThingRepository fakeRepo;
    late ThingListViewModel viewModel;

    setUp(() {
      fakeRepo = FakeThingRepository();
      viewModel = ThingListViewModel(
        GetThingsUseCase(fakeRepo),
        DeleteThingUseCase(fakeRepo),
      );
    });

    testWidgets('renders empty state when no things exist', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ThingListScreen(
            viewModel: viewModel,
          ),
        ),
      );

      // Need to pump to allow the Future in initState to complete
      await tester.pumpAndSettle();

      expect(find.text('Things API'), findsOneWidget);
      expect(find.text('No things found. Add one!'), findsOneWidget);
    });

    testWidgets('renders list of things', (WidgetTester tester) async {
      fakeRepo.seed([
        const Thing(name: 'things/1', displayName: 'Apple'),
        const Thing(name: 'things/2', displayName: 'Banana'),
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: ThingListScreen(
            viewModel: viewModel,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Banana'), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(2));
    });

    testWidgets('tapping delete icon removes the thing', (
      WidgetTester tester,
    ) async {
      fakeRepo.seed([const Thing(name: 'things/1', displayName: 'Apple')]);

      await tester.pumpWidget(
        MaterialApp(
          home: ThingListScreen(
            viewModel: viewModel,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Apple'), findsOneWidget);

      // Tap the delete icon
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // Verify UI update
      expect(find.text('Apple'), findsNothing);
      expect(find.text('No things found. Add one!'), findsOneWidget);

      // Verify backend update
      final things = await fakeRepo.getThings();
      expect(things, isEmpty);
    });
  });
}
