import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kerdos/main.dart';

void main() {
  testWidgets('KerdosApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: KerdosApp(),
      ),
    );
    expect(find.byType(KerdosApp), findsOneWidget);
  });
}

