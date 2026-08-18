import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garbo_swms/data/models/complaint_model.dart';
import 'package:garbo_swms/presentation/field_staff/special_tasks/widgets/task_card.dart';

void main() {
  Widget createTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('TaskCard Widget Tests', () {
    testWidgets('renders task card information accurately', (tester) async {
      final task = ComplaintModel(
        id: 39,
        title: 'Overflowing Bin in Park',
        wasteType: 'General Waste',
        status: 'IN_PROGRESS',
        location: '6.927100, 79.861200',
        urgency: 'High',
        description: 'Trash is spilling onto the pavement',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      );

      await tester.pumpWidget(
        createTestWidget(
          TaskCard(
            task: task,
            onApprove: () {},
            onReject: () {},
          ),
        ),
      );
      await tester.pump();

      // Check badges
      expect(find.text('#39'), findsOneWidget);
      expect(find.text('General Waste'), findsOneWidget);
      expect(find.text('In Progress'), findsOneWidget);

      // Check title and details
      expect(find.text('Overflowing Bin in Park'), findsOneWidget);
      expect(find.text('6.927100, 79.861200'), findsOneWidget);
      expect(find.text('Urgency: High'), findsOneWidget);
      expect(find.text('Trash is spilling onto the pavement'), findsOneWidget);

      // Check action buttons when in progress
      expect(find.text('Reject'), findsOneWidget);
      expect(find.text('Approve'), findsOneWidget);
    });

    testWidgets('triggers approve and reject callbacks', (tester) async {
      bool approved = false;
      bool rejected = false;

      final task = ComplaintModel(
        id: 10,
        title: 'Broken Bin Lid',
        status: 'IN_PROGRESS',
      );

      await tester.pumpWidget(
        createTestWidget(
          TaskCard(
            task: task,
            onApprove: () => approved = true,
            onReject: () => rejected = true,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Approve'));
      await tester.pump();
      expect(approved, isTrue);

      await tester.tap(find.text('Reject'));
      await tester.pump();
      expect(rejected, isTrue);
    });

    testWidgets('does not show approve/reject buttons for resolved tasks', (tester) async {
      final task = ComplaintModel(
        id: 11,
        title: 'Resolved Issue',
        status: 'RESOLVED',
      );

      await tester.pumpWidget(createTestWidget(TaskCard(task: task)));
      await tester.pump();

      expect(find.text('#11'), findsOneWidget);
      expect(find.text('Resolved'), findsOneWidget);
      expect(find.text('Reject'), findsNothing);
      expect(find.text('Approve'), findsNothing);
    });
  });
}
