import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garbo_swms/presentation/field_staff/special_tasks/widgets/task_filter_chips.dart';

void main() {
  Widget createTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('TaskFilterChips Tests', () {
    testWidgets('renders filter chips with counts', (tester) async {
      String selected = 'All';

      final items = [
        TaskFilterItem(label: 'All', count: 13),
        TaskFilterItem(label: 'In Progress', count: 8),
        TaskFilterItem(label: 'Resolved', count: 3),
        TaskFilterItem(label: 'Rejected', count: 2),
      ];

      await tester.pumpWidget(
        createTestWidget(
          TaskFilterChips(
            filters: items,
            selectedFilter: selected,
            onFilterChanged: (val) => selected = val,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('All (13)'), findsOneWidget);
      expect(find.text('In Progress'), findsOneWidget);
      expect(find.text('Resolved'), findsOneWidget);
      expect(find.text('Rejected'), findsOneWidget);

      // Tap 'In Progress'
      await tester.tap(find.text('In Progress'));
      await tester.pump();

      expect(selected, 'In Progress');
    });
  });
}
