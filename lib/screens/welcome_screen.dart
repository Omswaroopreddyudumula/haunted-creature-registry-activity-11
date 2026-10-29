import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

import 'signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2E1065), Color(0xFF14101F)],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.nightlight_round,
                  size: 88,
                  color: Color(0xFFFFB86C),
                ),
                const SizedBox(height: 20),
                const Text(
                  'SNACK CLUB  /  AFTER DARK',
                  style: TextStyle(letterSpacing: 2),
                ),
                const SizedBox(height: 20),
                Semantics(
                  label: 'The Haunted Creature Registry',
                  child: ExcludeSemantics(
                    child: AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText(
                          'The Haunted Creature Registry',
                          textAlign: TextAlign.center,
                          textStyle: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                          speed: const Duration(milliseconds: 65),
                        ),
                      ],
                      totalRepeatCount: 1,
                      displayFullTextOnTap: true,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Every midnight snack deserves a companion.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  key: const Key('enter'),
                  icon: const Icon(Icons.door_front_door),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const SignupScreen(),
                    ),
                  ),
                  label: const Text('Enter If You Dare'),
                ),
                const SizedBox(height: 16),
                const Text(
                  '01 FOYER    /    02 LAB    /    03 BALLROOM',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Colors.white60),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
