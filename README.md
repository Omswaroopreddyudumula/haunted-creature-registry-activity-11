# The Haunted Creature Registry

MAD 4360 Activity 11 - Undergraduate track, shared build Steps 1-6 only.

**Contributor:** Om Swaroop Reddy Udumula (individual submission; no teammates).

**Repository:** https://github.com/Omswaroopreddyudumula/haunted-creature-registry-activity-11

## Start and verify

Use Flutter 3.47.2 / Dart 3.13.2 or a compatible SDK. Android SDK and Java are required for the APK.

```sh
flutter pub get
flutter analyze
flutter test
flutter run
flutter build apk --release
```

For the Android checks and actual display captures, start an Android emulator identified as `emulator-5554` and run:

```sh
python3 test_driver/capture_android.py
```

The capture runner uses `$ANDROID_HOME/platform-tools/adb`, falling back to the standard macOS SDK location. Screenshots and logs are written into `evidence/`. Test input is fictional. These commands replace the previous capture files when rerun.

## Activity 10 continuity

The base was the existing `snack_club_activity_10` project from October 27, including its Android host project and signup page. The original name, email, and password validator bodies and messages were retained when the page moved into `lib/screens/signup_screen.dart`. The existing local signup-tip simulation remains: three stored tips, a 600 ms delay, and no network calls. This is an extension of that project, rather than a replacement signup implementation.

Name rejects empty or whitespace-only input. Email trims surrounding spaces and requires the original basic `@` and dot pattern. Password rejects whitespace-only input and requires six entered characters. Neither email syntax checking nor this demonstration creates a real account.

## Three rooms and their route stack

`main.dart` configures the app theme and sets `WelcomeScreen` as home. Each screen has its own file in `lib/screens/`.

```text
Launch                         [Welcome]
Enter If You Dare -- push -->   [Welcome, Signup]
Valid submit -- replacement -->[Welcome, Success]
System Back from Success       [Welcome]
Back to the Foyer -- popUntil ->[Welcome]
```

The Lab can be abandoned, so the Foyer remains below it. Successful signup replaces the Lab; Back cannot reopen the submitted form. The diagram on assignment page 6 uses broad wording about no back from the Ballroom; the worked code on pages 26-27 specifically keeps the Foyer. This project follows that code: Back reaches the Foyer and never the old Lab.

## State lifetime and cleanup

The name, email, and password controllers belong to `SignupScreen` State. `_obscurePassword`, `_birthDate`, `_selectedCreatureType`, and `_submitting` also belong to that State; the date controller mirrors the selected birth date for display. A layout change can rebuild the screen while retaining its State. Popping or replacing the Lab disposes all four text controllers and discards the form values. The Success widget receives only the trimmed name and creature type through its required constructor parameters.

`_signUp` validates the complete Form, snapshots the name and creature, disables editing and submission, waits two seconds, checks `mounted`, and replaces the route. The date picker and local helper also check `mounted` after their waits. The password is never persisted or passed to Success. No profile storage, database, or graduate extension is included.

The Success State creates one three-second `ConfettiController`, starts it in `initState`, sets `shouldLoop: false`, and disposes it when the screen leaves. The typewriter title comes from `animated_text_kit`; the celebration uses `confetti`.

## Form and design details

The required dropdown offers exactly Ghost, Bat, Black Cat, Pumpkin Spirit, and Witch. Birth date is required, read-only, starts at January 1 1920, and ends at the device's current date. Cancel leaves the previous value intact. The password eye button changes visibility without changing validation. Live validation clears errors as fields are corrected.

The midnight Snack Club concept connects the earlier project to the new theme. A purple gradient, moon icon, orange accents, room numbers, and original snack-table copy connect the three screens. SafeArea, scrolling, and a maximum form width of 480 keep the layout usable across sizes.

## Executed verification

Recorded October 29 2026. Flutter 3.47.2, Dart 3.13.2; Android emulator API 37, arm64. Evidence contains the raw successful run logs, actual Android screen captures, and the controlled compiler experiment.

| Case | Expected | Observed and evidence |
|---|---|---|
| Empty / whitespace input | Original validators plus creature and date errors | Pass; widget tests and `02-empty-validation.png` |
| All five creatures | Correct type with Mina Moon on Success | Pass; five separate widget tests; Black Cat also on Android |
| Email missing @ / password 12345 | Errors under the matching fields | Pass; widget test |
| Visibility on and off | Text toggles; short password still invalid | Pass; widget test and Android rotation assertions |
| Empty / canceled birth date | Cannot submit; cancel does not fill date | Pass; widget tests |
| Date limits | Accept 1/1/1920 and today; reject tomorrow | Pass; widget tests inspect bounds and enter dates |
| Lab Back | Foyer, then a fresh empty Lab | Pass; widget and Android tests |
| Ballroom Back and Foyer button | Foyer; no submitted Lab | Pass; both exit paths covered by widget tests; Android Back dispatch also checked |
| Double tap during delay | One Success; disabled button | Pass; five widget flow tests; loading screenshot |
| Confetti and reentry | Single nonlooping burst; safe disposal | Pass for controller configuration and navigation; Android flow completes without exception |
| Rotation | Same State and all selected values retained | Pass; real portrait-to-landscape Android orientation request and assertions |
| Small screen with keyboard | Scrollable with no overflow | Pass; 360 by 640 widget viewport and 280-pixel keyboard inset |
| Leave during loading | No late navigation or disposed-state exception | Pass; widget test |
| Local helper | Three tips cycle in order | Pass; widget test |

`evidence/widget-tests.txt`: 12 tests passed. `evidence/android-integration.txt`: one Android integration test passed. `evidence/analyze.txt`: no issues found. `evidence/release-build.txt`: release build output. Android screenshots are taken by the host runner from the emulator display, not drawn mockups.

## Bug graveyard

- **Dropdown overflow on a small screen:** the first 360-pixel layout test reported a 6.1-pixel horizontal overflow. Allowing the dropdown to expand within its field (`isExpanded: true`) fixed it; the same test then passed.
- **Confetti test timeout:** the package advances particles with wall-clock time, while widget tests advance a simulated clock. Waiting for all particle frames to settle timed out. Flow tests now advance route transitions by fixed frames and inspect the nonlooping controller configuration; Android verifies the real flow.
- **Emulator orientation:** an existing tablet-size display override kept the first Android run in portrait. Resetting that override to the emulator's normal phone size allowed a real landscape check. This was a test-environment issue.
- **Concurrent build interference:** a release build started during an integration build picked up the integration plugin registrant and failed. Running the release build after the Android test completed avoids that shared generated-file conflict.
- **Controlled constructor mismatch:** the deliberately broken caller and exact compiler output are retained under `evidence/constructor/`. They are text fixtures, excluded from normal compilation; the corrected caller built successfully.

## Ghost Hunt and submission

The accompanying Word document answers Pumpkin Patch prompts 2 and 4 with build-specific traces, screenshots, and compiler evidence. The constructor experiment was controlled; it is not presented as a real teammate merge. One contributor handled architecture, form enhancements, testing, and documentation. No teammate commits or live demos are claimed.

The release APK uses the Android project's debug signing key for classroom installation; it is a release-mode binary, not store-signed. The example application ID remains `edu.example.snack_club` from Activity 10. The Android-only host project is included. iOS, web, physical-device testing, store distribution, and a live course demo were not verified. Repository access and course submission remain separate from building the app; submit the repository URL, Word file, and APK through the course system.
