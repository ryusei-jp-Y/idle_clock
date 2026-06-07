# 開発環境セットアップ

2026年6月7日にApple Silicon Macで確認した手順です。

## 使用するツール

- Flutter 3.44.1 / Dart 3.12.1
- Android SDK 36 / Build Tools 36.0.0
- Android Emulator 36.6.11
- Android Studio
- Xcode 26.3
- iOS 26.3.1 Simulator
- CocoaPods 1.16.2
- Visual Studio Code + Flutter / Dart拡張

FlutterやAndroid SDKの安定版は更新されるため、別PCでは導入後に
`flutter --version`と`flutter doctor -v`で実際のバージョンを記録する。

## 1. Homebrew

Homebrewをインストール済みの状態で、リポジトリ直下から実行する。

```sh
brew bundle
```

XcodeはHomebrewではなく、Mac App Storeからインストールする。
最新Xcodeが現在のmacOSに対応していない場合、App Storeに表示される
「互換性のある旧バージョン」をインストールする。

## 2. Android SDK

Android Studio付属のJDKと、標準のAndroid SDK保存先を使用する。

```sh
export ANDROID_HOME="$HOME/Library/Android/sdk"
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"

mkdir -p "$ANDROID_HOME"
yes | sdkmanager --sdk_root="$ANDROID_HOME" --licenses
sdkmanager --sdk_root="$ANDROID_HOME" \
  "cmdline-tools;latest" \
  "platform-tools" \
  "platforms;android-36" \
  "build-tools;36.0.0" \
  "emulator" \
  "system-images;android-36;google_apis_playstore;arm64-v8a"

flutter config --android-sdk "$ANDROID_HOME"
flutter config --jdk-dir "$JAVA_HOME"
```

Intel Macではシステムイメージの`arm64-v8a`を`x86_64`へ変更する。

`~/.zshrc`へ次を追加し、新しいターミナルを開く。

```sh
export ANDROID_HOME="$HOME/Library/Android/sdk"
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"
```

Android仮想端末を作成する。

```sh
avdmanager create avd \
  --name idle_clock_api_36 \
  --package "system-images;android-36;google_apis_playstore;arm64-v8a" \
  --device pixel_7
```

## 3. Xcode

Mac App StoreからXcode本体をインストールした後に実行する。

```sh
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
xcodebuild -downloadPlatform iOS
```

`sudo`ではMacのログインパスワードが必要になる。入力中の文字はターミナルに
表示されないが、そのまま入力してReturnを押す。

SimulatorランタイムはXcode本体とは別に数GBのダウンロードが必要になる。
このPCではiOS 26.3.1が8.39GBだった。また、最初のSimulator起動時には
共有ライブラリキャッシュが生成されるため、Appleロゴの画面で数分待つ場合がある。

## 4. VS Code

VS Codeでこのリポジトリを開くと、`.vscode/extensions.json`によりFlutterと
Dart拡張が推奨される。CLIから導入する場合は次を実行する。

```sh
code --install-extension Dart-Code.flutter
```

## 5. 動作確認

```sh
flutter doctor -v
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Androidで起動する。

```sh
flutter emulators --launch idle_clock_api_36
flutter run
```

iOSで起動する。

```sh
open -a Simulator
flutter run
```

## このPCの現在の状態

- Android: 初期アプリのビルド、インストール、エミュレーター起動まで確認済み
- iOS: 初期アプリのビルド、インストール、Simulator起動まで確認済み
- `flutter doctor`: 問題なし
- `flutter analyze` / `flutter test`: 成功
- 仮Application ID: `com.example.idle_clock`
- 仮Bundle ID: `com.example.idleClock`

正式なIDはストア配布準備までに決定し、AndroidとiOSの両方で変更する。
