# floating_tile_nav

A reusable, single-row floating bottom navigation bar for Flutter apps. Its only runtime dependency is the Flutter SDK. Your app manages the selected state and screen switching; the bar just reports the item index.

<p align="center">
  <img src="https://raw.githubusercontent.com/4armsxlr8/floating_tile_nav/main/doc/demo.gif" width="270" alt="The floating navigation bar at the bottom center of the example app, switching between the home, search, and profile screens.">
</p>

## Using it from your app

To depend on it from pub.dev, specify a version in your app's `pubspec.yaml`.

```yaml
dependencies:
  floating_tile_nav: ^0.1.0
```

To reference it locally after cloning the repository, specify the package's path.

```yaml
dependencies:
  floating_tile_nav:
    path: /path/to/floating_tile_nav
```

Import only the public entry point, and pass `selectedIndex` and `onSelected`.

```dart
import 'package:floating_tile_nav/floating_tile_nav.dart';

FloatingBottomNavigation(
  selectedIndex: selectedIndex,
  onSelected: (index) => setState(() => selectedIndex = index),
)
```

If you omit `items`, it shows the current 3 default items with the package's own shapes: 'ホーム', '検索', and 'プロフィール'. You can specify 2 to 5 items, and your app decides the display order, semantic label, normal icon, and selected icon for each. There's no visible text label.

```dart
final items = <FloatingNavigationItem>[
  FloatingNavigationItem(
    icon: const FloatingNavigationIcon(
      icon: FloatingNavigationIconType.home,
    ),
    selectedIcon: const FloatingNavigationIcon(
      icon: FloatingNavigationIconType.home,
      selected: true,
    ),
    semanticLabel: 'ホーム',
  ),
  const FloatingNavigationItem(
    icon: Icon(Icons.bookmark_border),
    selectedIcon: Icon(Icons.bookmark),
    semanticLabel: '保存済み',
  ),
];
```

You can mix the built-in default icons with arbitrary Widgets such as `Icon` in the same `items`. `FloatingNavigationIcon` has `home`, `search`, and `profile` shapes, and draws the selected shape when `selected: true`. The bar's `iconColor` and `iconSize` are inherited as an `IconTheme` by icons that don't explicitly set their own color or size. A color or size a Widget sets itself is used as-is.

## Colors, dimensions, and the safe area

The defaults are background color `#32332d`, icon color white (`Color(0xFFFFFFFF)`), button size 52, gap 8, border radius 16, icon size 28, and minimum bottom padding 32 (all in logical pixels). You can specify only the values you need.

```dart
FloatingBottomNavigation(
  selectedIndex: selectedIndex,
  onSelected: onSelected,
  items: items,
  backgroundColor: const Color(0xff102030),
  iconColor: const Color(0xffd7e8ff),
  buttonSize: 56,
  gap: 10,
  borderRadius: 18,
  iconSize: 30,
  minimumBottomPadding: 24,
  useSafeArea: true,
)
```

All dimensions must be finite values. The button size must be 48 or more; the gap, border radius, and minimum bottom padding must be 0 or more; the border radius must be at most half the button size; and the icon size must be greater than 0 and at most the button size. The item count, selected index, and semantic labels also have constraints, and invalid settings throw `ArgumentError` in both debug and release builds. The item list you pass in is defensively copied at construction time.

`useSafeArea: true` is the default. The bar doesn't avoid the top edge, but avoids the OS safe area on the left, right, and bottom edges. The bottom becomes whichever is larger: `minimumBottomPadding` or the OS's bottom inset. If your app manages the safe area separately, set `useSafeArea: false` and the bar leaves only the minimum bottom padding you specify.

Placing the bar and adding trailing padding to your content are your app's responsibility. Typically you overlay it on your content with a `Stack`, and add trailing padding to scrollable content so it isn't hidden behind the bar. The bar never changes the selected state itself after a tap. Tapping the selected item again also notifies the same index, so your app can choose to ignore it, scroll back to the top, or handle it some other way.

Your screen can manage the selected state, overlay position, scroll trailing padding, and handling of tapping the selected item again, all together, like this.

```dart
import 'dart:math' show max;

class ExampleShell extends StatefulWidget {
  const ExampleShell({super.key});

  @override
  State<ExampleShell> createState() => _ExampleShellState();
}

class _ExampleShellState extends State<ExampleShell> {
  var _selectedIndex = 0;

  void _selectTab(int index) {
    if (_selectedIndex == index) {
      return; // Example: the consuming app ignores tapping the selected item again
    }
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    const buttonSize = 52.0;
    const minimumBottomPadding = 32.0;
    final contentBottomPadding =
        buttonSize + max(minimumBottomPadding, MediaQuery.paddingOf(context).bottom) + 18;

    return Stack(
      children: [
        ListView(
          padding: EdgeInsets.only(bottom: contentBottomPadding),
          children: const [Text('コンテンツ')],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: FloatingBottomNavigation(
            selectedIndex: _selectedIndex,
            onSelected: _selectTab,
          ),
        ),
      ],
    );
  }
}
```

You can compute the required width as follows.

```text
buttonSize × itemCount + gap × (itemCount - 1)
```

Compare this value against the available width — the screen width minus the left and right safe areas. The bar doesn't automatically shrink, wrap, or horizontally scroll its own dimensions.

## The bundled example app

The 3-screen example app is in `example/`. Run it from the example app's directory, not the repository root.

```sh
cd example
flutter pub get
flutter run
```

It targets iOS/Android smartphones in portrait orientation, plus Web for verification. The screens, dummy content, tab switching, and each screen's scroll position live in the example app, and there's no runtime network access.

On the web, `example/web/flutter_bootstrap.js` loads CanvasKit from `canvaskit/` and the fallback font from `assets/fonts/`, both relative to the page's base URI. The asset URLs follow along whether deployed at the root or a subpath, and since the Flutter SDK's assets are bundled, no runtime CDN is required.

```sh
cd example
flutter build web --release --no-web-resources-cdn
flutter build web --release --no-web-resources-cdn \
  --base-href /samples/floating-tile-nav/ \
  --output build/web-subpath/samples/floating-tile-nav
```

Noto Sans JP is declared in `example/pubspec.yaml` twice: as `NotoSansJP` for the app's display text, and as `Roboto` to satisfy the Flutter engine's default font request locally. The bundled font is the official Noto Sans JP from Google Fonts.

- Source: https://github.com/google/fonts/tree/main/ofl/notosansjp
- Font: https://raw.githubusercontent.com/google/fonts/main/ofl/notosansjp/NotoSansJP%5Bwght%5D.ttf
- License: https://raw.githubusercontent.com/google/fonts/main/ofl/notosansjp/OFL.txt
- `NotoSansJP[wght].ttf` SHA-256: `c2f3b4d463500a2ddcd3849cded1fceeb9fd6d1c32e6cbecd568453ba50fc68f`
- `OFL.txt` SHA-256: `1c05c68c34f9708415aada51f17e1b0092d2cea709bf4a94cd38114f9e73d7d9`
