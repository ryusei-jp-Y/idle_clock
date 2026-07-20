# Store Assets

App Store登録用の画像群です。

## iPhone 6.9インチ 横向き / 日本語

出力先:

- `iphone_6_9_landscape/ja/01_main_clock.png`
- `iphone_6_9_landscape/ja/02_ripple_moment.png`
- `iphone_6_9_landscape/ja/03_sideways_clock.png`
- `iphone_6_9_landscape/ja/04_settings.png`
- `iphone_6_9_landscape/ja/05_four_objects.png`

仕様:

- サイズ: `2868 x 1320`
- 形式: PNG
- カラーモード: RGB
- 透過: なし

Apple公式のApp Store Connect screenshot specificationsで、iPhone 6.9インチ横向きの受け付けサイズとして listed されている寸法に合わせています。

## Regenerate

```sh
python3 tool/create_store_images.py
```

生成スクリプトは現在のアプリ実装の色、時計フォント、設定項目、光るオブジェクト、波紋表現を元にしています。

このコマンドでは、スクリーンショットに加えて以下も生成します。

- `app_icon/idle_clock_app_icon_1024.png`
- `app_icon/idle_clock_app_icon_preview.png`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png`

## Metadata

- `app_store_metadata_ja.md`: App Store Connect入力用の日本語原稿
- `app_review_notes_ja.md`: App Review向けメモ
- `app_privacy_answers_ja.md`: App Privacy申告用メモ

## Web

- `web/support.html`: サポートURL用の静的HTML
- `web/privacy.html`: プライバシーポリシーURL用の静的HTML

本番用の公式サイトは `site/` 配下です。

- `site/index.html`: `https://idle-clock.yamanari.dev/`
- `site/support/index.html`: `https://idle-clock.yamanari.dev/support/`
- `site/privacy/index.html`: `https://idle-clock.yamanari.dev/privacy/`
