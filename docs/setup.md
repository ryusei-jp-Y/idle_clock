# 開発環境セットアップ

2026年6月21日に、Apple App Storeのみへリリースする方針に合わせて
iOS専用の開発環境へ単純化した手順です。

## 使用するツール

- Flutter 3.44.1 / Dart 3.12.1
- Xcode
- iOS Simulator
- CocoaPods 1.16.2
- Visual Studio Code + Flutter / Dart拡張

Android SDK、Android Studio、Android Emulatorはこのプロジェクトでは使用しない。

## 1. Homebrew

Homebrewをインストール済みの状態で、リポジトリ直下から実行する。

```sh
brew bundle
```

XcodeはHomebrewではなく、Mac App Storeからインストールする。
最新Xcodeが現在のmacOSに対応していない場合、App Storeに表示される
「互換性のある旧バージョン」をインストールする。

Flutterの診断対象もiOSに絞る。

```sh
flutter config \
  --no-enable-android \
  --no-enable-web \
  --no-enable-macos-desktop \
  --no-enable-linux-desktop \
  --no-enable-windows-desktop
```

## 2. Xcode

Mac App StoreからXcode本体をインストールした後に実行する。

```sh
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
xcodebuild -downloadPlatform iOS
```

`sudo`ではMacのログインパスワードが必要になる。入力中の文字はターミナルに
表示されないが、そのまま入力してReturnを押す。

SimulatorランタイムはXcode本体とは別に数GBのダウンロードが必要になる。
最初のSimulator起動時には共有ライブラリキャッシュが生成されるため、
Appleロゴの画面で数分待つ場合がある。

## 3. VS Code

VS Codeでこのリポジトリを開くと、`.vscode/extensions.json`によりFlutterと
Dart拡張が推奨される。CLIから導入する場合は次を実行する。

```sh
code --install-extension Dart-Code.flutter
```

## 4. 動作確認

```sh
flutter doctor -v
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

iOSで起動する。

```sh
open -a Simulator
flutter run -d ios
```

## 5. 修正後の反映・プレビュー

`flutter run -d ios`で起動している最中にDart / Flutter側だけを変更した場合は、
ターミナルで`r`を押してHot Reload、反映が不十分な場合は`R`でHot Restartする。

一度ビルド済みの`Runner.app`をSimulatorへ入れて確認している場合、コード修正後は
必ず再ビルドしてから入れ直す。古い`Runner.app`を再インストールすると、最新の
UI変更が反映されない。

```sh
flutter build ios --simulator
open -a Simulator
xcrun simctl install booted build/ios/iphonesimulator/Runner.app
xcrun simctl launch booted com.example.idleClock
```

起動中のSimulatorがない場合は、先に利用可能な端末を起動する。

```sh
xcrun simctl list devices available
xcrun simctl boot <device-udid>
xcrun simctl bootstatus <device-udid> -b
open -a Simulator
```

作業後にマシン負荷を下げる場合は、Simulator端末とSimulatorアプリを終了する。

```sh
xcrun simctl shutdown all
osascript -e 'tell application "Simulator" to quit'
```

App Store配布前は、XcodeでBundle ID、署名チーム、表示名、アイコン、
プライバシー情報を確定する。

## このPCの現在の方針

- Android開発環境は削除済み
- 配布対象はApple App Storeのみ
- Xcode 26.5 / iOS 26.5 Simulatorで起動確認済み
- `flutter doctor`: 問題なし
- `dart format --output=none --set-exit-if-changed lib test`: 成功
- `flutter analyze`: 成功
- `flutter test`: 成功
- 仮Bundle ID: `com.example.idleClock`
- 正式なBundle IDはApp Store配布準備までに決定する
