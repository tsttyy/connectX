import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:connectx/main.dart';
import 'package:connectx/providers/theme_provider.dart';
import 'package:connectx/providers/auth_provider.dart';
import 'package:connectx/providers/chat_provider.dart';

void main() {
  testWidgets('ConnectX app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => ChatProvider()),
        ],
        child: const ConnectXApp(),
      ),
    );

    // Verify that the title/app details render or load
    expect(find.byType(ConnectXApp), findsOneWidget);
  });
}
