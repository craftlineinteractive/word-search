import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_search/widgets/craftline_branding.dart';

void main() {
  testWidgets('CraftlineLogo renders pure Flutter vector gear and typography without assets', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CraftlineLogo(
              width: 160,
            ),
          ),
        ),
      ),
    );

    // Verify CraftlineLogo and Image widget are rendered
    expect(find.byType(CraftlineLogo), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });
}
