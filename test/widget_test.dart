import 'package:flutter_test/flutter_test.dart';
import 'package:word_search/main.dart';

void main() {
  testWidgets('WordPuzzleApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const WordPuzzleApp());
    await tester.pumpAndSettle();

    // Verify that title and Play button render
    expect(find.text('Word Search'), findsWidgets);
    expect(find.text('Continue – Level 1'), findsOneWidget);
    expect(find.text('All Levels'), findsOneWidget);
  });
}
