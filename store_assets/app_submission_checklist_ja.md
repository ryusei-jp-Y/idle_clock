# App Store Submission Checklist

## App Store Connect

- アプリ名: `Idle Clock`
- Bundle ID: `dev.yamanari.idleclock`
- SKU: `idle-clock-ios`
- Primary Language: Japanese
- Version: `1.0.0`
- Build: `1`

## URLs

- Marketing URL: `https://idle-clock.yamanari.dev/`
- Support URL: `https://idle-clock.yamanari.dev/support/`
- Privacy Policy URL: `https://idle-clock.yamanari.dev/privacy/`

## Category

- Primary Category: Lifestyle
- Secondary Category: Utilities

## App Privacy

- Data collection: No
- Tracking: No
- Account creation: No
- External server sync: No
- Settings are saved locally on the device.

## Screenshots

Use the PNG files in:

```text
store_assets/iphone_6_9_landscape/ja/
```

## Xcode Signing

1. Open `ios/Runner.xcworkspace`.
2. Select the `Runner` project, then the `Runner` target.
3. Open `Signing & Capabilities`.
4. Select your Apple Developer Team.
5. Confirm Bundle Identifier is `dev.yamanari.idleclock`.
6. Enable automatic signing.

## Build

After Xcode signing is configured:

```sh
flutter build ipa --release --build-name=1.0.0 --build-number=1
```

Upload the generated archive from Xcode Organizer or Transporter.
