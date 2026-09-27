import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vsit_complaint_box/main.dart';
import 'package:vsit_complaint_box/providers/complaint_provider.dart';

void main() {
  testWidgets('VSIT portal opens on submit screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ComplaintProvider(),
        child: const VSITApp(),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Submit New Complaint'), findsOneWidget);
    expect(find.text('Track Status'), findsOneWidget);
  });
}
