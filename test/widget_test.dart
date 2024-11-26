import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Dashboard Page has title and buttons',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp() as Widget);

    // Verify that the greeting text is present.
    expect(find.text('Happy Monday, Ms. Alice!'), findsOneWidget);

    // Verify the existence of the three main buttons.
    expect(find.text('Add Students'), findsOneWidget);
    expect(find.text('Rating Sheets'), findsOneWidget);
    expect(find.text('Upload Grades'), findsOneWidget);
  });
}

class MyApp {}
