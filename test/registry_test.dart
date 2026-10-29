import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:confetti/confetti.dart';
import 'package:snack_club/main.dart';
import 'package:snack_club/screens/signup_screen.dart';
import 'package:snack_club/screens/success_screen.dart';

Future<void> enterLab(WidgetTester t) async {
  await t.pumpWidget(const HauntedMansionApp());
  await t.tap(find.byKey(const Key('enter')));
  await t.pumpAndSettle();
}

Future<void> tapVisible(WidgetTester t, Finder f) async {
  await t.ensureVisible(f);
  await t.pumpAndSettle();
  await t.tap(f);
  await t.pump();
}

Future<void> fill(WidgetTester t, String type) async {
  await t.enterText(find.byKey(const Key('name')), '  Mina Moon  ');
  await t.enterText(find.byKey(const Key('email')), 'mina@example.com');
  await t.enterText(find.byKey(const Key('password')), 'fangs6');
  await tapVisible(t, find.byKey(const Key('creature')));
  await t.pumpAndSettle();
  await t.tap(find.text(type).last);
  await t.pumpAndSettle();
  await tapVisible(t, find.byKey(const Key('birth-date')));
  await t.pumpAndSettle();
  await t.tap(find.text('OK'));
  await t.pumpAndSettle();
}

void main() {
  testWidgets('Empty and whitespace fields preserve all Activity 10 errors', (
    t,
  ) async {
    await enterLab(t);
    await tapVisible(t, find.byKey(const Key('register')));
    for (final message in [
      'Please enter your full name.',
      'Please enter your email address.',
      'Please enter a password.',
      'Choose your creature type.',
      'Pick your birth date',
    ]) {
      expect(find.text(message), findsOneWidget);
    }
    await t.enterText(find.byKey(const Key('name')), '   ');
    await t.enterText(find.byKey(const Key('email')), '   ');
    await t.enterText(find.byKey(const Key('password')), '   ');
    await tapVisible(t, find.byKey(const Key('register')));
    expect(find.text('Please enter your full name.'), findsOneWidget);
    expect(find.text('Please enter a password.'), findsOneWidget);
  });
  testWidgets(
    'Invalid email and short password fail with visibility both ways',
    (t) async {
      await enterLab(t);
      await t.enterText(find.byKey(const Key('email')), 'missing-at');
      await t.enterText(find.byKey(const Key('password')), '12345');
      for (final hidden in [true, false, true]) {
        final field = t.widget<TextFormField>(
          find.byKey(const Key('password')),
        );
        // TextFormField creates an EditableText containing the actual obscuring flag.
        final edit = t.widget<EditableText>(
          find.descendant(
            of: find.byKey(const Key('password')),
            matching: find.byType(EditableText),
          ),
        );
        expect(field.controller!.text, '12345');
        expect(edit.obscureText, hidden);
        await tapVisible(t, find.byKey(const Key('register')));
        expect(
          find.text('Please enter a valid email address.'),
          findsOneWidget,
        );
        expect(find.text('Use at least six characters.'), findsOneWidget);
        await tapVisible(t, find.byKey(const Key('visibility')));
      }
    },
  );
  for (final type in ['Ghost', 'Bat', 'Black Cat', 'Pumpkin Spirit', 'Witch']) {
    testWidgets(
      '$type reaches personalized success; double tap gives one route; Back resets',
      (t) async {
        await enterLab(t);
        await fill(t, type);
        await tapVisible(t, find.byKey(const Key('register')));
        expect(
          t.widget<FilledButton>(find.byKey(const Key('register'))).onPressed,
          isNull,
        );
        await t.tap(find.byKey(const Key('register')), warnIfMissed: false);
        await t.pump(const Duration(seconds: 1));
        expect(find.byType(SignupScreen), findsOneWidget);
        await t.pump(const Duration(seconds: 1));
        await t.pump(const Duration(milliseconds: 400));
        await t.pump(const Duration(milliseconds: 400));
        expect(find.text('Welcome, Mina Moon!'), findsOneWidget);
        expect(find.text('Creature registered: $type.'), findsOneWidget);
        expect(find.byType(SignupScreen), findsNothing);
        expect(find.byType(SuccessScreen), findsOneWidget);
        expect(
          t.widget<ConfettiWidget>(find.byType(ConfettiWidget)).shouldLoop,
          isFalse,
        );
        if (type == 'Ghost') {
          await t.tap(find.byKey(const Key('foyer')));
        } else {
          await t.binding.handlePopRoute();
        }
        await t.pumpAndSettle();
        expect(find.byKey(const Key('enter')), findsOneWidget);
        await t.tap(find.byKey(const Key('enter')));
        await t.pumpAndSettle();
        expect(
          t
              .widget<TextFormField>(find.byKey(const Key('name')))
              .controller!
              .text,
          isEmpty,
        );
        expect(t.takeException(), isNull);
      },
    );
  }
  testWidgets('Date picker bounds, cancel, lower bound and today', (t) async {
    await enterLab(t);
    await tapVisible(t, find.byKey(const Key('birth-date')));
    await t.pumpAndSettle();
    var picker = t.widget<DatePickerDialog>(find.byType(DatePickerDialog));
    expect(picker.firstDate, DateTime(1920));
    expect(picker.lastDate, DateUtils.dateOnly(DateTime.now()));
    await t.tap(find.text('Cancel'));
    await t.pumpAndSettle();
    expect(
      t
          .widget<TextFormField>(find.byKey(const Key('birth-date')))
          .controller!
          .text,
      isEmpty,
    );
    for (final date in [
      '01/01/1920',
      '${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year}',
    ]) {
      await tapVisible(t, find.byKey(const Key('birth-date')));
      await t.pumpAndSettle();
      await t.tap(find.byIcon(Icons.edit_outlined));
      await t.pumpAndSettle();
      await t.enterText(
        find.descendant(
          of: find.byType(DatePickerDialog),
          matching: find.byType(TextField),
        ),
        date,
      );
      await t.tap(find.text('OK'));
      await t.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsNothing);
    }
  });
  testWidgets('Future date is rejected and small keyboard layout scrolls', (
    t,
  ) async {
    t.view.physicalSize = const Size(360, 640);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await enterLab(t);
    expect(t.takeException(), isNull, reason: 'after entering lab');
    await tapVisible(t, find.byKey(const Key('birth-date')));
    await t.pumpAndSettle();
    expect(t.takeException(), isNull, reason: 'after picker step');
    await t.tap(find.byIcon(Icons.edit_outlined));
    await t.pumpAndSettle();
    expect(t.takeException(), isNull, reason: 'after picker step');
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    await t.enterText(
      find.descendant(
        of: find.byType(DatePickerDialog),
        matching: find.byType(TextField),
      ),
      '${tomorrow.month}/${tomorrow.day}/${tomorrow.year}',
    );
    await t.tap(find.text('OK'));
    await t.pumpAndSettle();
    expect(t.takeException(), isNull, reason: 'after picker step');
    expect(find.byType(DatePickerDialog), findsOneWidget);
    expect(find.text('Out of range.'), findsOneWidget);
    await t.tap(find.text('Cancel'));
    await t.pumpAndSettle();
    expect(t.takeException(), isNull, reason: 'after picker step');
    t.view.viewInsets = const FakeViewPadding(bottom: 280);
    addTearDown(t.view.resetViewInsets);
    await t.pump();
    await tapVisible(t, find.byKey(const Key('register')));
    expect(find.text('Pick your birth date'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
  testWidgets('Ordinary Back discards every form value', (t) async {
    await enterLab(t);
    await fill(t, 'Witch');
    await tapVisible(t, find.byKey(const Key('visibility')));
    await t.pageBack();
    await t.pumpAndSettle();
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
    expect(find.text('Witch'), findsNothing);
  });
  testWidgets('Back from Lab destroys input; leaving mid-load is safe', (
    t,
  ) async {
    await enterLab(t);
    await fill(t, 'Ghost');
    await tapVisible(t, find.byKey(const Key('register')));
    await t.pageBack();
    await t.pumpAndSettle();
    await t.pump(const Duration(seconds: 3));
    expect(find.byKey(const Key('enter')), findsOneWidget);
    expect(find.byType(SuccessScreen), findsNothing);
    expect(t.takeException(), isNull);
  });
  testWidgets('Local signup helper still cycles tips', (t) async {
    await enterLab(t);
    for (final tip in [
      'Use a long password that you do not use for another account.',
      'A few unrelated words can make a password easier to remember.',
      'Avoid using your name or birthday in your password.',
      'Use a long password that you do not use for another account.',
    ]) {
      await tapVisible(t, find.text('Get a signup tip'));
      await t.pump(const Duration(milliseconds: 600));
      expect(find.text(tip), findsOneWidget);
    }
  });
}
