# STONED for iPhone

This project builds the repository's root `index.html` into the app as a local resource. Keep the game self-contained or explicitly add any new game assets to the target's Resources phase. The app launch screen includes a content notice and a privacy policy. The game uses both landscape orientations on iPhone.

## Build and test

1. Open `ios/Stoned.xcodeproj` in Xcode. Select the **Stoned** scheme. In **Signing & Capabilities**, select the Apple Developer team. Confirm the provisional bundle ID `com.sararefundini.stoned` is available before creating the matching record in App Store Connect.
2. Run on two physical iPhones where possible, including a smaller display. Verify first launch and the full game in airplane mode. Test right and left landscape, audio from the first tap, joystick and look gestures, puzzle controls, leaving and returning to the app, and the ending. Confirm there are no overlay collisions, stuck inputs, or unreadable captions.
3. Archive a Release build, validate it in Xcode Organizer, and distribute it to App Store Connect for TestFlight. Review the exact TestFlight build before sending it to App Review.

For an unsigned simulator compilation check:

```sh
xcodebuild -project ios/Stoned.xcodeproj -scheme Stoned \
  -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```

Use an Xcode and SDK version that meets [Apple's upload requirements](https://developer.apple.com/news/upcoming-requirements/). TestFlight and App Store uploads require signing.

## Build with Codemagic

Keep this project's `ios/` folder and `codemagic.yaml` beside the repository's `index.html` on your iOS build branch. Connect the STONED repository in Codemagic and select **STONED - unsigned iPhone simulator build** for the first compilation check.

For TestFlight, register the bundle ID `com.sararefundini.stoned` with Apple and create the matching iOS app record in App Store Connect. Select **STONED - signed TestFlight build** in Codemagic. This workflow uses the team integration named `Codemagic` and needs an App Store distribution certificate and a provisioning profile for the STONED bundle ID. A successful build is uploaded to App Store Connect. Submit it for beta or production review from App Store Connect when ready.

## Draft listing

- **Name** — STONED: Scripture Ripples
- **Subtitle** — Biblical Horror Puzzle Game
- **Primary category** — Games
- **Suggested subcategories** — Puzzle, Adventure
- **Keywords** — scripture,bible,horror,puzzle,first person,mystery,interactive,atmosphere

### Description

Walk a hallway that keeps bringing you back to the same place. Look through a kaleidoscope, read clues drawn from Scripture, and learn which stones belong on an altar.

STONED is a short first-person horror puzzle game and a companion to Scripture Ripples. It explores how the image of a stone recurs in biblical passages about judgment, worship, and refuge.

Play in landscape on iPhone. The game includes depictions of execution and themes of death and judgment.

### Draft App Review notes

STONED is a first-person puzzle game for iPhone. Tap **Play**, then enter the game from its title screen. Hold the left joystick to move and drag on the right side to look. Use the on-screen controls to interact with clues and solve puzzles. No account is required and the game is bundled for offline play.

The game uses quoted Bible passages alongside original dramatizations. One sequence portrays a biblical-era execution. Before submitting, add the exact path reviewers can follow to reach this sequence and describe the visual and audio intensity of the submitted build.

### Before submitting

- Answer the age rating questionnaire using the final build's horror themes and the frequency and intensity of the violence. Assess the execution scene against [App Review Guidelines 1.1.2 and 1.1.5](https://developer.apple.com/app-store/review/guidelines/#objectionable-content). Confirm Scripture quotes are exact, distinguish dramatizations, and verify rights to every asset and quoted translation in the selected territories.
- Verify all bundled code and assets before completing App Privacy. The draft policy in `Stoned/Privacy.txt` assumes the app has no accounts, tracking, analytics, ads, or data collection. Verify that this remains accurate after the gameplay update. Publish the final policy at a public URL and add that URL in App Store Connect.
- Add a public support page with a current way to reach the developer. Capture the App Store screenshots from the actual iPhone build. Show gameplay and avoid graphic content in public screenshots.
- Confirm the app name, developer contact, screenshots, and release territories before sending to Apple. See [Apple's submission checklist](https://developer.apple.com/app-store/submitting/).
