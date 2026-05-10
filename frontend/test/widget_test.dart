import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:buscai/screens/figma_flow.dart';

void main() {
  testWidgets('signup creates user and opens home feed', (tester) async {
    AppSession.currentUser = null;
    await tester.pumpWidget(
      const MaterialApp(home: SignupScreen()),
    );

    await tester.enterText(find.widgetWithText(TextFormField, 'Nome completo'), 'Samira Santos');
    await tester.enterText(find.widgetWithText(TextFormField, 'E-mail'), 'samira@email.com');
    await tester.enterText(find.widgetWithText(TextFormField, '00 90000-0000'), '75981908860');
    await tester.enterText(find.widgetWithText(TextFormField, 'Senha'), '1234567');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Criar conta'));
    await tester.pumpAndSettle();

    expect(find.text('O que você precisa hoje?'), findsOneWidget);
    expect(find.text('Perto de você'), findsOneWidget);
  });
}
