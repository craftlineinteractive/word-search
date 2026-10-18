import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_search/main.dart';
import 'package:word_search/widgets/craftline_branding.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('WordPuzzleApp smoke test renders SplashScreen and CraftlineLogo', (WidgetTester tester) async {
    // Build our app and trigger an initial frame.
    await tester.pumpWidget(const WordPuzzleApp());
    await tester.pump();

    // Verify that title and Craftline branding logo render immediately on splash
    expect(find.text('WORD SEARCH'), findsWidgets);
    expect(find.byType(CraftlineLogo), findsOneWidget);
  });
}

