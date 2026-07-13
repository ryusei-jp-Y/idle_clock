# App Storeリリース準備メモ

2026年6月24日時点で、コード以外に準備できるものを整理する。

## 1. 先に決めるもの

- 正式名称
- App Storeサブタイトル
- Bundle ID
- 表示名
- アプリアイコン方針
- ストア掲載画像の方向性
- サポートURL
- プライバシーポリシーURL
- 年齢制限
- カテゴリ
- 価格: 無料 / 有料
- 対応言語: 初期は日本語のみか、日本語 + 英語か

## 2. App Store Connectで必要になる主な素材

| 項目 | 状態 | メモ |
|---|---|---|
| アプリアイコン | 未作成 | 1024px正方形のマスターを先に作る |
| スクリーンショット | 未作成 | Apple公式では1〜10枚 |
| App Preview | 任意 | Apple公式では最大3本、最大30秒 |
| アプリ名 | 未決定 | 候補は`release-creative-brief.md`に整理 |
| サブタイトル | 未決定 | 体験価値が伝わる短文 |
| 説明文 | 下書きあり | 後述 |
| キーワード | 下書きあり | 後述 |
| サポートURL | 未作成 | 簡易WebページまたはGitHub Pages等 |
| プライバシーポリシーURL | 未作成 | データ非収集方針を明記 |
| カテゴリ | 未決定 | 候補: Lifestyle / Utilities |
| 年齢制限 | 未確認 | 通常は低年齢向けで問題ない想定 |
| 著作権表記 | 未決定 | 個人名または屋号 |

## 3. 説明文ドラフト

### 日本語版

```text
横向きに置いて眺める、ミニマルな時計アプリです。

画面の中を光のオブジェクトがゆっくり動き、壁や他のオブジェクトに当たると、波紋、色の変化、短い電子音が広がります。

作業机やベッドサイドに置いて、時刻を確認しながら、静かな動きをぼんやり眺められます。

主な機能:
・大きく読みやすい時計表示
・12時間 / 24時間表記の切り替え
・秒表示のオン / オフ
・最大4つの移動オブジェクト
・衝突時の波紋、色変化、短いSE
・メイン画面表示中の常時点灯
・設定の端末内保存

アカウント登録やクラウド同期はありません。
シンプルに開いて、置いて、眺めるための時計です。
```

### 英語版

```text
A minimal clock app made to sit sideways on your desk or bedside table.

Glowing objects drift across the screen. When they hit an edge or each other, a soft ripple, a color shift, and a short electronic chime appear.

Use it as a quiet clock for your desk, nightstand, or focus breaks.

Features:
・Large, readable clock
・12-hour and 24-hour time formats
・Optional seconds display
・Up to four moving objects
・Ripples, color shifts, and short sound effects on collision
・Keeps the screen awake while the main clock is open
・Settings saved locally on your device

No account, cloud sync, or external service is required.
Just open it, set it down, and watch time drift.
```

## 4. プロモーション文候補

App Storeのプロモーションテキストや掲載画像の短いコピーに使う。

- 置いて眺める、静かな時計
- 光が跳ねて、時間が流れる
- 反射、波紋、短い電子音
- ベッドサイドに置くミニマル時計
- A calm clock with drifting light
- Watch time drift
- Light, ripple, chime

## 5. キーワード候補

### 日本語

```text
時計,デジタル時計,置き時計,常時点灯,ベッドサイド,ミニマル,反射,波紋,作業用,集中,夜,シンプル
```

### 英語

```text
clock,digital clock,desk clock,bedside clock,ambient,minimal,night clock,screensaver,chime,ripple,focus
```

## 6. カテゴリ候補

### 第1候補: Lifestyle

理由: 眺める体験、ベッドサイドや作業机で使う体験が中心。

### 第2候補: Utilities

理由: 時計としての実用性を前面に出す場合はこちら。

## 7. プライバシー方針ドラフト

現時点のアプリ仕様では、アカウント登録、外部API、広告、解析、クラウド同期は使っていない。設定は端末内に保存する。

```text
このアプリは個人情報を収集しません。
アカウント登録、広告、解析、外部サーバーとの同期はありません。
設定値は端末内に保存され、開発者へ送信されません。
```

App Store提出前に、実装済みの依存パッケージとネットワーク通信の有無を再確認する。

## 8. サポートページに載せる内容

- アプリ概要
- 対応環境
- よくある質問
- 音が鳴らない場合は端末の音量、消音モード、集中モードを確認する案内
- 常時点灯中はバッテリー消費が増える可能性がある案内
- 問い合わせ先
- プライバシーポリシーへのリンク

## 9. スクリーンショット制作タスク

1. 正式名称を決める
2. アイコン案を3〜5案作る
3. App Store掲載画像のコピーを決める
4. iPhone Simulatorまたは実機で横画面スクリーンショットを撮る
5. 画像に短いコピーを載せる
6. App Store Connectで必要なデバイスサイズを確認する
7. PNGまたはJPEGで書き出す
8. 実際のアプリ機能と齟齬がないか確認する

## 10. App Preview制作タスク

App Previewは任意。作る場合は次の構成を推奨する。

| 秒数 | 内容 |
|---|---|
| 0〜3秒 | メイン時計画面 |
| 3〜8秒 | オブジェクトの反射、波紋、色変化 |
| 8〜12秒 | オブジェクト数を増やした状態 |
| 12〜16秒 | 設定画面を短く表示 |
| 16〜20秒 | メイン画面へ戻って余韻 |

`simctl recordVideo`は映像のみ。音声込みの動画が必要な場合は、OBS、ScreenFlow、または仮想オーディオデバイスを使ってシステム音声も録る。

## 11. 提出前に再確認すること

- 正式名称が既存アプリや商標と衝突しない
- アイコンが既存ブランドに似ていない
- スクリーンショットが実際のUIと一致している
- 常時点灯によるバッテリー消費の注意を必要に応じて説明している
- SEがマナーモードや音量設定で自然に扱われる
- 個人情報を収集しないことをプライバシー申告と一致させる
- 実機で長時間表示、発熱、電池消費を確認する

## 12. 参考リンク

- Apple App Store Product Page: https://developer.apple.com/app-store/product-page/
- Screenshot specifications: https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/
- Upload app previews and screenshots: https://developer.apple.com/help/app-store-connect/manage-app-information/upload-app-previews-and-screenshots/
- App icons - Human Interface Guidelines: https://developer.apple.com/design/human-interface-guidelines/app-icons
