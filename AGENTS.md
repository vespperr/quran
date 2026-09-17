## TEMPORARY AGENTS.MD TEST

At the beginning of your next response, before doing anything else, write exactly:

AGENTS_MD_LOADED

Do not edit files or run commands before writing this.
# Flutter Engineering Agent Instructions

You are working on a production-grade Flutter/Dart application.

Your goal is not only to generate code. Your goal is to leave the project in a working, analyzed, tested, and buildable state.

## Core behavior

Always understand the existing implementation before editing it.

For non-trivial work:

1. Inspect
2. Understand
3. Plan
4. Implement
5. Format
6. Analyze
7. Test
8. Diagnose failures
9. Fix
10. Re-test
11. Review the final diff

Never stop merely because code was generated.

Do not claim completion until the relevant verification steps have been performed.

---

## Investigation discipline

Investigate only as much as necessary to understand and solve the task correctly.

Do not wander through unrelated files, packages, documentation, websites, or architectural areas without a concrete reason.

Every investigation step should answer a specific question relevant to the current task.

Before opening additional files or performing additional research, ask internally:

* What am I trying to verify?
* Is this information necessary for the requested task?
* Can the answer already be determined from the project?
* Will this investigation change the implementation decision?

If the answer is no, stop researching and continue with the task.

Prefer this order:

1. inspect the directly relevant code
2. inspect its callers and dependencies
3. inspect project configuration when relevant
4. inspect package source/documentation only when the API is genuinely unclear
5. use external research only when local project evidence is insufficient

Do not research broadly merely because additional information might exist.

Do not repeatedly search for the same answer after sufficient evidence has already been found.

Do not turn a small task into a repository-wide refactor or architectural investigation.

---

## Evidence before conclusions

Never assume something works because the code looks correct.

Never claim:

* "fixed"
* "working"
* "resolved"
* "implemented successfully"
* "no errors"
* "production ready"

unless there is evidence supporting that statement.

Evidence may include:

* `flutter analyze` results
* passing tests
* successful build output
* successful application execution
* reproduced user flow
* relevant logs
* verified API response
* verified persisted state

Distinguish clearly between:

* something you implemented
* something you tested
* something you inferred
* something you could not verify

If something was not actually tested, say that it was not tested.

Do not convert an assumption into a fact.

---

## Anti-self-deception

Actively try to prove your own implementation wrong before declaring success.

After implementing a solution, ask:

* What assumption could be incorrect?
* What input could break this?
* What state could I have forgotten?
* What happens when the API fails?
* What happens with null or missing data?
* What happens after navigation or disposal?
* What happens on repeated execution?
* Did I test the actual behavior or only inspect the code?
* Could the test pass while the real feature remains broken?

When possible, attempt a failure case before declaring success.

A successful compilation does not prove that the feature works.

A passing analyzer does not prove that runtime behavior is correct.

A passing unit test does not prove that the full user flow works.

Use the strongest available verification appropriate to the task.

---

## Stop conditions for research

Stop investigating and begin implementation once all of the following are true:

* the affected code path is understood
* the expected behavior is understood
* the root cause or required change is sufficiently identified
* relevant dependencies are known
* there is enough evidence to make a safe implementation decision

Do not continue researching merely to gain absolute certainty.

If uncertainty remains but is not material to the implementation, document the assumption and proceed.

If uncertainty is material, investigate only that specific uncertainty.

---

## Scope control

Stay within the user's requested scope.

Do not:

* redesign unrelated screens
* refactor unrelated modules
* rename unrelated classes
* upgrade unrelated packages
* change architecture without need
* add features that were not requested
* remove existing behavior because it appears unnecessary
* perform cleanup unrelated to the current task

If you notice an unrelated problem, mention it separately instead of automatically modifying it.

Prefer the smallest robust change that fully solves the requested problem.

---

## Understand the Flutter project first

Before making significant changes, inspect relevant project files and architecture.

Pay attention to:

* `pubspec.yaml`
* `analysis_options.yaml`
* `lib/`
* `test/`
* `integration_test/`
* platform folders when relevant
* existing state-management solution
* routing/navigation system
* dependency injection
* networking layer
* models/entities
* repositories/services
* local storage
* generated files
* themes
* localization
* existing widgets and reusable components

Do not introduce a new architecture, package, or state-management system when the project already has an established solution unless there is a strong technical reason.

---

## Correctness

Do not:

* invent APIs that do not exist
* invent backend fields
* invent Dart or Flutter APIs
* assume package APIs from memory when they can be inspected
* use outdated package APIs when the installed version can be checked
* suppress analyzer errors to make the project appear correct
* remove failing tests without justification
* replace complex functionality with placeholders
* leave TODO implementations instead of finishing requested work
* silently remove existing functionality
* use fake data when real application behavior is required

When uncertain, investigate the project and installed dependencies.

---

## Flutter package awareness

Before using functionality from a dependency:

1. inspect `pubspec.yaml`
2. determine which package version the project uses
3. inspect existing usage inside the project
4. follow the API appropriate for that version

Do not unnecessarily upgrade packages while solving an unrelated task.

Do not add a new dependency when Flutter/Dart or an existing dependency already provides an appropriate solution.

After changing dependencies, run:

```bash
flutter pub get
```

Check for dependency conflicts before proceeding.

---

## Codebase preservation

Respect the project's existing:

* architecture
* state-management approach
* folder structure
* naming conventions
* routing system
* dependency injection
* networking approach
* theme system
* localization system
* widget patterns
* error-handling patterns
* formatting
* public interfaces
* platform support

Avoid unrelated modifications.

Do not rewrite working sections of the application merely because another implementation style is preferred.

---

## Dart formatting

After modifying Dart files, run:

```bash
dart format .
```

Do not finish with improperly formatted Dart code.

Do not manually fight Dart's formatter.

---

## Flutter analyzer

Never finish a coding task while new Flutter analyzer errors remain.

After meaningful Dart or Flutter changes, run:

```bash
flutter analyze
```

Then:

1. read every analyzer error
2. inspect relevant warnings
3. determine their actual cause
4. fix issues caused by the changes
5. run `flutter analyze` again
6. repeat until the task introduces no analyzer errors

Do not hide analyzer problems.

Do not use:

* `// ignore:`
* `// ignore_for_file:`
* unnecessary casts
* `dynamic`
* unsafe null assertions with `!`

merely to silence the analyzer.

Such mechanisms may be used only when technically justified and should not replace a proper fix.

Never change `analysis_options.yaml` simply to make bad code pass analysis.

---

## Existing analyzer problems

The project may already contain old analyzer warnings or errors.

When that happens:

1. determine whether each problem existed before the current task
2. fix problems introduced by the current changes
3. do not falsely claim that an existing issue was created by the current task
4. do not use existing problems as an excuse to ignore new problems

If an existing analyzer error directly prevents completion of the requested feature, investigate and fix it when reasonably within scope.

---

## Null safety

Respect Dart null safety.

Do not solve null-safety problems by adding `!` everywhere.

Before using a null assertion:

1. prove that the value cannot legitimately be null
2. consider proper null handling
3. consider early returns
4. consider validation
5. consider correct typing

Prefer explicit and safe null handling.

---

## Async code

Be especially careful with:

* `Future`
* `Stream`
* `async`
* `await`
* widget lifecycle
* navigation after asynchronous operations
* disposed widgets
* subscriptions
* controllers

When using `BuildContext` after an asynchronous gap, verify that the widget is still mounted when applicable.

For example:

```dart
if (!context.mounted) return;
```

Do not introduce race conditions through careless asynchronous code.

---

## Widget lifecycle

Respect Flutter widget lifecycle rules.

Correctly manage and dispose resources such as:

* `TextEditingController`
* `AnimationController`
* `ScrollController`
* `FocusNode`
* `StreamSubscription`
* timers
* listeners

Do not leave resources undisposed.

Do not call lifecycle-sensitive operations from inappropriate lifecycle methods.

---

## State management

Use the state-management solution already present in the project.

Examples may include:

* Riverpod
* Bloc / Cubit
* Provider
* GetX
* MobX
* Redux
* custom architecture

Do not introduce a second state-management system without a strong reason.

Keep:

* business logic out of presentation code when the project architecture expects separation
* state transitions predictable
* loading/error/success states handled properly
* unnecessary widget rebuilds under control

---

## UI work

When changing Flutter UI:

* preserve existing design language unless redesign was requested
* support different screen sizes
* avoid unnecessary fixed dimensions
* prevent overflow
* respect SafeArea when applicable
* handle keyboard appearance correctly
* support scrolling where content can exceed available space
* preserve accessibility
* preserve localization
* preserve RTL behavior when supported by the project

Check for common problems such as:

* `RenderFlex overflowed`
* clipped text
* broken small-screen layouts
* incorrect keyboard resizing
* overflowing rows
* inaccessible buttons
* incorrect dark-mode appearance

Do not fix overflow by blindly wrapping everything in `SingleChildScrollView`.

Understand the layout first.

---

## Responsive behavior

For responsive interfaces, consider:

* phone widths
* tablets
* orientation changes
* large text
* system font scaling
* safe areas
* keyboard visibility

Avoid hardcoded sizes when they make the interface fragile.

Use the project's existing responsive utilities when available.

---

## Navigation

Respect the navigation system already used by the project.

Examples:

* Navigator
* GoRouter
* AutoRoute
* GetX routing

Do not mix navigation architectures unnecessarily.

Verify:

* back navigation
* deep links when applicable
* redirects
* authentication guards
* route parameters
* restoration of navigation state when relevant

---

## Networking

When modifying API-related code:

* inspect the existing API client first
* verify endpoint paths
* verify HTTP methods
* verify request models
* verify response models
* handle timeout/error states
* handle authentication correctly
* preserve interceptors
* preserve refresh-token behavior
* avoid exposing credentials in logs

Do not invent backend behavior.

If the backend contract is unclear, derive it from existing application code, models, documentation, or the actual API definition when available.

---

## JSON and models

When editing data models:

* verify nullability
* verify API field names
* preserve serialization behavior
* preserve backwards compatibility when possible

If the project uses code generation such as:

* `json_serializable`
* `freezed`
* `retrofit`
* Riverpod generators

do not manually edit generated files.

Edit the source files and regenerate the output.

When required by the project, run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Only run code generation when the project actually uses it.

---

## Generated files

Do not manually edit generated files unless the project explicitly requires it.

Common generated files include:

```text
*.g.dart
*.freezed.dart
*.gr.dart
```

Modify their source definitions instead and regenerate them.

---

## Localization

If the project supports localization:

* do not hardcode user-facing strings when localized equivalents should exist
* preserve existing localization conventions
* update localization resources when introducing new user-facing text
* verify RTL layouts when the app supports RTL languages

If Flutter's localization generator is used, regenerate localization files when required.

---

## Debugging

When debugging:

1. reproduce the problem
2. collect the exact exception/error
3. inspect logs and stack traces
4. locate the execution path
5. inspect related widgets/services/providers/controllers
6. formulate plausible hypotheses
7. test those hypotheses
8. identify the root cause
9. implement the smallest robust fix
10. add a regression test when appropriate
11. verify the original failure no longer occurs
12. verify that the fix did not break related behavior

Never repeatedly modify random code hoping the bug disappears.

Fix causes, not symptoms.

---

## Flutter runtime errors

Never ignore runtime errors such as:

* `setState() called after dispose()`
* `RenderFlex overflowed`
* `LateInitializationError`
* `Null check operator used on a null value`
* `Looking up a deactivated widget's ancestor`
* `Bad state`
* provider/state errors
* navigation exceptions
* platform-channel exceptions

Investigate their root cause.

Do not simply hide console output.

---

## Testing

After relevant changes, run:

```bash
flutter test
```

Fix test failures caused by the current task.

When the project contains targeted tests, run the relevant test files during development and the broader test suite before completion.

Consider the appropriate test level:

* unit tests
* widget tests
* integration tests

For bug fixes, add a regression test when reasonably possible.

Do not:

* delete legitimate failing tests
* weaken assertions merely to make tests pass
* skip tests to hide failures
* modify tests to accept incorrect behavior

---

## Integration tests

If the project contains an `integration_test/` directory and the task affects user flows, run the applicable integration tests when the environment allows it.

Pay particular attention to flows involving:

* authentication
* onboarding
* navigation
* payments
* forms
* persistence
* API interactions
* critical business processes

---

## Build verification

For changes that could affect compilation or platform integration, verify an applicable Flutter build.

Examples:

```bash
flutter build apk
```

or:

```bash
flutter build appbundle
```

or:

```bash
flutter build ios
```

or:

```bash
flutter build web
```

Use the build target appropriate for the project.

Do not unnecessarily build every platform when the task only concerns one platform.

If the build fails because of your changes, investigate and fix it.

---

## Android-specific work

When working inside `android/`, pay attention to:

* Gradle
* Kotlin
* AndroidManifest.xml
* permissions
* SDK versions
* signing configuration
* ProGuard/R8
* Flutter plugin compatibility

Do not change Android build settings randomly to bypass an error.

Determine the real compatibility problem first.

---

## iOS-specific work

When working inside `ios/`, pay attention to:

* CocoaPods
* Podfile
* deployment target
* Info.plist
* permissions
* Swift/Objective-C interoperability
* Flutter plugin compatibility

Do not make unrelated Podfile or Xcode configuration changes simply to force a build through.

---

## Security

Never expose:

* API keys
* secrets
* tokens
* passwords
* credentials
* private keys
* signing secrets

Do not log sensitive authentication information.

Validate external input.

Check authentication and authorization boundaries.

Pay attention to:

* insecure local storage
* token leakage
* sensitive information in logs
* insecure network communication
* improperly protected application routes
* unsafe WebViews
* injection
* path traversal
* privilege escalation

Use secure-storage mechanisms already established by the project when sensitive values must be stored locally.

---

## Performance

Before introducing expensive behavior, consider:

* unnecessary widget rebuilds
* expensive work inside `build()`
* unnecessary API calls
* repeated database queries
* large image memory usage
* unbounded lists
* excessive object allocation
* blocking the UI isolate
* unnecessary listeners
* unnecessary provider/state updates

Use existing project patterns for optimization.

Do not prematurely optimize without evidence.

---

## Final verification

Before saying a task is complete, perform the relevant sequence:

```bash
dart format .
flutter analyze
flutter test
```

Then run any required:

```bash
dart run build_runner build --delete-conflicting-outputs
```

and an appropriate Flutter build if the changes warrant build verification.

After that:

1. review the final diff
2. check for accidental changes
3. check for temporary debug code
4. check for leftover `print()` / `debugPrint()` statements added only for debugging
5. check for TODO placeholders introduced during the task
6. check that no required functionality was removed
7. verify the requested feature or bug fix itself

---

## Completion criteria

A task is complete only when:

* the requested behavior is implemented
* Dart code is formatted
* no new `flutter analyze` errors remain
* relevant tests pass
* applicable builds succeed
* generated code is updated when required
* resources/controllers/subscriptions are properly disposed
* important edge cases were considered
* no temporary debugging code remains
* no placeholder implementation remains
* no known failure caused by the changes is being ignored
* the final diff was reviewed

Never say a task is complete simply because code was written.

If something cannot be completed, report:

* what failed
* the exact error
* what was investigated
* why it remains blocked

Do not pretend success.
