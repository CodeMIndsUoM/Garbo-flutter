import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garbo_swms/data/models/complaint_model.dart';
import 'package:garbo_swms/presentation/field_staff/special_tasks/widgets/task_details_overlay.dart';

void main() {
  Widget createTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('TaskDetailsOverlay Widget Tests', () {
    testWidgets('renders modal overlay details cleanly', (tester) async {
      final task = ComplaintModel(
        id: 33,
        title: 'Chemical Waste Dumping',
        issueType: 'Hazardous Waste',
        wasteType: 'Chemical',
        urgency: 'High',
        location: '6.927100, 79.861200',
        council: 'Moratuwa',
        description: 'Drums dumped near stream',
        status: 'IN_PROGRESS',
      );

      await tester.pumpWidget(createTestWidget(TaskDetailsOverlay(task: task)));
      await tester.pump();

      expect(find.text('#33'), findsOneWidget);
      expect(find.text('IN PROGRESS'), findsOneWidget);
      expect(find.text('Chemical Waste Dumping'), findsOneWidget);
      expect(find.text('Hazardous Waste'), findsOneWidget);
      expect(find.text('Chemical'), findsOneWidget);
      expect(find.text('High'), findsOneWidget);
      expect(find.text('Moratuwa'), findsOneWidget);
      expect(find.text('Drums dumped near stream'), findsOneWidget);
    });
  });
}
