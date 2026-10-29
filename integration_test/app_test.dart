import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:snack_club/main.dart';
import 'package:snack_club/screens/signup_screen.dart';

import '../test/registry_test.dart' as helpers;

Future<void> capture(String name) async {
  // The host runner captures the real Android display after this marker.
  debugPrint('EVIDENCE:$name');
  await Future<void>.delayed(const Duration(seconds: 2));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Android registry evidence and rotation state ownership', (
    t,
  ) async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await t.pumpWidget(const HauntedMansionApp());
    await t.pumpAndSettle();
    await capture('01-foyer');
    await t.tap(find.byKey(const Key('enter')));
    await t.pumpAndSettle();
    await helpers.tapVisible(t, find.byKey(const Key('register')));
    await t.pumpAndSettle();
    await capture('02-empty-validation');
    expect(find.text('Please enter your full name.'), findsOneWidget);
    await helpers.fill(t, 'Black Cat');
    await helpers.tapVisible(t, find.byKey(const Key('visibility')));
    final stateBefore = t.state(find.byType(SignupScreen));
    await t.ensureVisible(find.byKey(const Key('name')));
    await t.pumpAndSettle();
    await capture('03-before-rotation');
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
    ]);
    await t.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 2));
    await t.pumpAndSettle();
    expect(identical(stateBefore, t.state(find.byType(SignupScreen))), isTrue);
    expect(
      t.widget<TextFormField>(find.byKey(const Key('name'))).controller!.text,
      '  Mina Moon  ',
    );
    expect(
      t
          .widget<TextFormField>(find.byKey(const Key('birth-date')))
          .controller!
          .text,
      '1/1/2008',
    );
    expect(
      t
          .widget<EditableText>(
            find.descendant(
              of: find.byKey(const Key('password')),
              matching: find.byType(EditableText),
            ),
          )
          .obscureText,
      isFalse,
    );
    expect(find.text('Black Cat'), findsOneWidget);
    final size = MediaQuery.sizeOf(t.element(find.byType(SignupScreen)));
    expect(size.width, greaterThan(size.height));
    await capture('04-landscape-state-retained');
    await helpers.tapVisible(t, find.byKey(const Key('birth-date')));
    await t.pumpAndSettle();
    await capture('05-date-picker');
    await t.tap(find.text('Cancel'));
    await t.pumpAndSettle();
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await Future<void>.delayed(const Duration(seconds: 2));
    await t.pumpAndSettle();
    await helpers.tapVisible(t, find.byKey(const Key('register')));
    await t.pump(const Duration(milliseconds: 100));
    await capture('06-loading');
    await t.pumpAndSettle();
    expect(find.text('Welcome, Mina Moon!'), findsOneWidget);
    expect(find.text('Creature registered: Black Cat.'), findsOneWidget);
    await capture('07-success');
    await t.binding.handlePopRoute();
    await t.pumpAndSettle();
    expect(find.byKey(const Key('enter')), findsOneWidget);
    await t.tap(find.byKey(const Key('enter')));
    await t.pumpAndSettle();
    expect(
      t.widget<TextFormField>(find.byKey(const Key('name'))).controller!.text,
      isEmpty,
    );
    expect(
      t
          .widget<TextFormField>(find.byKey(const Key('birth-date')))
          .controller!
          .text,
      isEmpty,
    );
    expect(find.text('Black Cat'), findsNothing);
    expect(
      t
          .widget<EditableText>(
            find.descendant(
              of: find.byKey(const Key('password')),
              matching: find.byType(EditableText),
            ),
          )
          .obscureText,
      isTrue,
    );
    await capture('08-new-lab-reset');
    await t.pageBack();
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
  });
}
