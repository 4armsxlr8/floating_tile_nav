# Pinterest風の浮遊ボトムナビ

黒いダミー画面に、ホーム・検索・プロフィールの3つのボタンを浮かべたFlutterサンプルです。ナビゲーションはスクロール中も固定され、タブを切り替えても各画面のスクロール位置を保持します。

## 起動

```sh
flutter pub get
flutter run
```

iOS / Android の縦向きスマートフォンを主な対象にしています。Webでも確認用に起動できます。

表示内容はローカルのダミーデータだけで、検索・ログイン・保存・外部通信には接続しません。

Webでは`web/flutter_bootstrap.js`でCanvasKitを`canvaskit/`、フォールバックフォントを`assets/fonts/`から、ページのbase URIを基準に読み込みます。`--base-href`でサブパスへ配置しても資材URLが追従します。Noto Sans JPはアプリ表示用の`NotoSansJP`と、Flutter engineの既定フォント要求をローカルで満たす`Roboto`として宣言しています。ビルド時はFlutter SDKの資材を同梱するため、次のようにCDNを無効化してください。

```sh
flutter build web --no-web-resources-cdn
```

同梱フォントはGoogle Fonts公式のNoto Sans JPです。

- 出典: https://github.com/google/fonts/tree/main/ofl/notosansjp
- フォント: https://raw.githubusercontent.com/google/fonts/main/ofl/notosansjp/NotoSansJP%5Bwght%5D.ttf
- ライセンス: https://raw.githubusercontent.com/google/fonts/main/ofl/notosansjp/OFL.txt
- `NotoSansJP[wght].ttf` SHA-256: `c2f3b4d463500a2ddcd3849cded1fceeb9fd6d1c32e6cbecd568453ba50fc68f`
- `OFL.txt` SHA-256: `1c05c68c34f9708415aada51f17e1b0092d2cea709bf4a94cd38114f9e73d7d9`
