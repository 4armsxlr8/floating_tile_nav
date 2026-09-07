# パッケージの利用イメージ

これは実装コードではなく、組み込み時の使い方を確認するための仕様用サンプルです。利用イメージはユーザーの「ok」、境界条件は「推奨でOK」を受けて採用。API名は例示であり、正本は確定specです。

## 利用するアプリが渡すもの
- 選択中の項目番号。
- 項目を押したときの処理。
- 必要に応じて、項目ごとの通常アイコン・選択アイコン・読み上げ名。省略すると既定3項目を使う。

```dart
FloatingBottomNavigation(
  selectedIndex: currentIndex,
  onSelected: (index) {
    setState(() => currentIndex = index);
  },
  // 項目を差し替える例
  items: [
    FloatingNavigationItem(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      semanticLabel: 'ホーム',
    ),
    FloatingNavigationItem(
      icon: Icon(Icons.bookmark_border),
      selectedIcon: Icon(Icons.bookmark),
      semanticLabel: '保存済み',
    ),
  ],
)
```

## 操作の責務案
ナビは押された項目を利用側へ通知し、利用側から渡された選択状態を表示する。画面切り替えとスクロール位置の保持は利用側が行う。ナビ自身は画面やルートを所有しない。

今のサンプルは利用例として残し、ホーム・検索・プロフィールの独自アイコン、画面切り替え、スクロール位置保持を引き続き確認できる。サンプルのフォントとダミーカードはパッケージ本体の必須素材にしない。

## 確定した境界と責務
項目数は2〜5個。選択中項目の再タップも通知する。自動縮小・横スクロールはしない。現在の独自アイコンも再利用でき、色と寸法の初期値は今の見た目を保つ。安全領域はナビが扱い、必要に応じて無効化できる。画面への重ね方とコンテンツの末尾余白は利用側で指定する。
