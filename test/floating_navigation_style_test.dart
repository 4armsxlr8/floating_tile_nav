import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:floating_tile_nav/floating_tile_nav.dart';

const _defaultButtonSize = 52.0;
const _defaultGap = 8.0;
const _defaultBorderRadius = 16.0;
const _defaultIconSize = 28.0;
const _defaultMinimumBottomPadding = 32.0;
const _defaultBackgroundColor = Color(0xff32332d);
const _defaultIconColor = Colors.white;

Finder _navButton(String label) => find.bySemanticsLabel(label);

Widget _navigationHost(Widget navigation) {
  return MaterialApp(
    home: Scaffold(
      body: Stack(
        children: <Widget>[
          const Positioned.fill(child: ColoredBox(color: Colors.black)),
          Positioned(left: 0, right: 0, bottom: 0, child: navigation),
        ],
      ),
    ),
  );
}

FloatingNavigationItem _item(
  String label, {
  Widget? icon,
  Widget? selectedIcon,
}) {
  return FloatingNavigationItem(
    icon: icon ?? const SizedBox(width: 20, height: 20),
    selectedIcon: selectedIcon ?? const SizedBox(width: 20, height: 20),
    semanticLabel: label,
  );
}

List<FloatingNavigationItem> _items(int count, {String prefix = 'item'}) {
  return List<FloatingNavigationItem>.generate(
    count,
    (index) => _item('$prefix-$index'),
  );
}

FloatingBottomNavigation _navigation({
  int selectedIndex = 0,
  List<FloatingNavigationItem>? items,
  Color? backgroundColor,
  Color? iconColor,
  double? buttonSize,
  double? gap,
  double? borderRadius,
  double? iconSize,
  double? minimumBottomPadding,
  bool? useSafeArea,
}) {
  return FloatingBottomNavigation(
    selectedIndex: selectedIndex,
    onSelected: (_) {},
    items: items ?? _items(2, prefix: 'style'),
    backgroundColor: backgroundColor ?? _defaultBackgroundColor,
    iconColor: iconColor ?? _defaultIconColor,
    buttonSize: buttonSize ?? _defaultButtonSize,
    gap: gap ?? _defaultGap,
    borderRadius: borderRadius ?? _defaultBorderRadius,
    iconSize: iconSize ?? _defaultIconSize,
    minimumBottomPadding: minimumBottomPadding ?? _defaultMinimumBottomPadding,
    useSafeArea: useSafeArea ?? true,
  );
}

Finder _buttonDecoration(Finder icon) {
  return find.ancestor(of: icon, matching: find.byType(DecoratedBox)).first;
}

BoxDecoration _boxDecoration(WidgetTester tester, Finder icon) {
  final decoration = tester.widget<DecoratedBox>(_buttonDecoration(icon));
  return decoration.decoration as BoxDecoration;
}

Finder _iconRichText(String key) {
  return find.descendant(
    of: find.byKey(ValueKey<String>(key)),
    matching: find.byType(RichText),
  );
}

Finder _iconSizedBox(String key) {
  return find.descendant(
    of: find.byKey(ValueKey<String>(key)),
    matching: find.byType(SizedBox),
  );
}

void _setView(
  WidgetTester tester, {
  required double width,
  required double height,
  double left = 0,
  double right = 0,
  double bottom = 0,
}) {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = Size(width, height)
    ..padding = FakeViewPadding(left: left, right: right, bottom: bottom)
    ..viewPadding = FakeViewPadding(left: left, right: right, bottom: bottom);
}

void _expectValidNavigation({
  double buttonSize = _defaultButtonSize,
  double gap = _defaultGap,
  double borderRadius = _defaultBorderRadius,
  double iconSize = _defaultIconSize,
  double minimumBottomPadding = _defaultMinimumBottomPadding,
}) {
  expect(
    () => _navigation(
      buttonSize: buttonSize,
      gap: gap,
      borderRadius: borderRadius,
      iconSize: iconSize,
      minimumBottomPadding: minimumBottomPadding,
    ),
    returnsNormally,
  );
}

void _expectArgumentError({
  double buttonSize = _defaultButtonSize,
  double gap = _defaultGap,
  double borderRadius = _defaultBorderRadius,
  double iconSize = _defaultIconSize,
  double minimumBottomPadding = _defaultMinimumBottomPadding,
}) {
  expect(
    () => _navigation(
      buttonSize: buttonSize,
      gap: gap,
      borderRadius: borderRadius,
      iconSize: iconSize,
      minimumBottomPadding: minimumBottomPadding,
    ),
    throwsArgumentError,
  );
}

FloatingBottomNavigation _navigationWithDimension(String name, double value) {
  return switch (name) {
    'buttonSize' => _navigation(buttonSize: value),
    'gap' => _navigation(gap: value),
    'borderRadius' => _navigation(borderRadius: value),
    'iconSize' => _navigation(iconSize: value),
    'minimumBottomPadding' => _navigation(minimumBottomPadding: value),
    _ => throw StateError('Unknown style dimension: $name'),
  };
}

void main() {
  testWidgets('AC-8: 色・寸法・間隔・角丸・余白とIconThemeを反映する', (tester) async {
    addTearDown(tester.view.reset);
    _setView(tester, width: 600, height: 640);

    const backgroundColor = Color(0xff102030);
    const inheritedIconColor = Color(0xff405060);
    const explicitIconColor = Color(0xffc0a080);
    const buttonSize = 64.0;
    const gap = 14.0;
    const borderRadius = 18.0;
    const inheritedIconSize = 30.0;
    const explicitIconSize = 18.0;
    const minimumBottomPadding = 44.0;

    await tester.pumpWidget(
      _navigationHost(
        _navigation(
          backgroundColor: backgroundColor,
          iconColor: inheritedIconColor,
          buttonSize: buttonSize,
          gap: gap,
          borderRadius: borderRadius,
          iconSize: inheritedIconSize,
          minimumBottomPadding: minimumBottomPadding,
          items: <FloatingNavigationItem>[
            _item(
              '明示色',
              icon: Icon(
                Icons.home_outlined,
                key: const ValueKey<String>('ac8-inherited-icon'),
              ),
              selectedIcon: Icon(
                Icons.home,
                key: const ValueKey<String>('ac8-explicit-icon'),
                color: explicitIconColor,
                size: explicitIconSize,
              ),
            ),
            _item(
              '継承色',
              icon: Icon(
                Icons.search,
                key: const ValueKey<String>('ac8-inherited-icon-2'),
              ),
              selectedIcon: Icon(
                Icons.search,
                key: const ValueKey<String>('ac8-selected-icon-2'),
              ),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    final explicitIcon = find.byKey(
      const ValueKey<String>('ac8-explicit-icon'),
    );
    final inheritedIcon = find.byKey(
      const ValueKey<String>('ac8-inherited-icon-2'),
    );
    final explicitDecoration = _boxDecoration(tester, explicitIcon);
    final inheritedDecoration = _boxDecoration(tester, inheritedIcon);
    expect(explicitDecoration.color, backgroundColor);
    expect(
      explicitDecoration.borderRadius,
      BorderRadius.circular(borderRadius),
    );
    expect(inheritedDecoration.color, backgroundColor);
    expect(
      inheritedDecoration.borderRadius,
      BorderRadius.circular(borderRadius),
    );

    final explicitButton = _buttonDecoration(explicitIcon);
    final inheritedButton = _buttonDecoration(inheritedIcon);
    expect(
      tester.getRect(explicitButton).size,
      const Size(buttonSize, buttonSize),
    );
    expect(
      tester.getRect(inheritedButton).size,
      const Size(buttonSize, buttonSize),
    );
    expect(
      tester.getRect(inheritedButton).left -
          tester.getRect(explicitButton).right,
      gap,
    );
    expect(
      tester.getRect(explicitButton).bottom,
      closeTo(640 - minimumBottomPadding, 0.001),
    );

    final inheritedText = tester.widget<RichText>(
      _iconRichText('ac8-inherited-icon-2'),
    );
    final inheritedStyle = (inheritedText.text as TextSpan).style!;
    expect(inheritedStyle.color, inheritedIconColor);
    expect(inheritedStyle.fontSize, inheritedIconSize);
    expect(
      tester.getRect(_iconSizedBox('ac8-inherited-icon-2')).size,
      const Size(30, 30),
    );

    final explicitText = tester.widget<RichText>(
      _iconRichText('ac8-explicit-icon'),
    );
    final explicitStyle = (explicitText.text as TextSpan).style!;
    expect(explicitStyle.color, explicitIconColor);
    expect(explicitStyle.fontSize, explicitIconSize);
    expect(
      tester.getRect(_iconSizedBox('ac8-explicit-icon')).size,
      const Size(18, 18),
    );
  });

  testWidgets('AC-9: 公開独自アイコンと任意Iconを混在し、変更ラベルを公開する', (tester) async {
    await tester.pumpWidget(
      _navigationHost(
        _navigation(
          selectedIndex: 0,
          items: <FloatingNavigationItem>[
            _item(
              '開始',
              icon: FloatingNavigationIcon(
                icon: FloatingNavigationIconType.home,
              ),
              selectedIcon: FloatingNavigationIcon(
                icon: FloatingNavigationIconType.home,
                selected: true,
              ),
            ),
            _item(
              '保存済み',
              icon: const Icon(
                Icons.bookmark_border,
                key: ValueKey<String>('ac9-arbitrary-icon'),
              ),
              selectedIcon: const Icon(Icons.bookmark),
            ),
            _item(
              '探す',
              icon: FloatingNavigationIcon(
                icon: FloatingNavigationIconType.search,
              ),
              selectedIcon: FloatingNavigationIcon(
                icon: FloatingNavigationIconType.search,
                selected: true,
              ),
            ),
            _item(
              '人物',
              icon: FloatingNavigationIcon(
                icon: FloatingNavigationIconType.profile,
              ),
              selectedIcon: FloatingNavigationIcon(
                icon: FloatingNavigationIconType.profile,
                selected: true,
              ),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FloatingNavigationIcon), findsNWidgets(3));
    expect(
      find.byKey(const ValueKey<String>('ac9-arbitrary-icon')),
      findsOneWidget,
    );
    for (final label in <String>['開始', '保存済み', '人物']) {
      expect(find.bySemanticsLabel(label), findsOneWidget);
    }
  });

  testWidgets('AC-10: 標準寸法の2/5項目が幅と下安全領域に収まる', (tester) async {
    addTearDown(tester.view.reset);
    const widthValues = <double>[320, 430];
    const bottomValues = <double>[0, 34];
    const height = 640.0;

    for (final width in widthValues) {
      for (final bottom in bottomValues) {
        for (final count in <int>[2, 5]) {
          _setView(tester, width: width, height: height, bottom: bottom);
          await tester.pumpWidget(
            _navigationHost(
              _navigation(
                selectedIndex: count - 1,
                items: _items(count, prefix: 'ac10-$count'),
              ),
            ),
          );
          await tester.pumpAndSettle();

          final expectedBottom = height - (bottom > 32 ? bottom : 32);
          for (var index = 0; index < count; index += 1) {
            final rect = tester.getRect(_navButton('ac10-$count-$index'));
            expect(rect.width, _defaultButtonSize);
            expect(rect.height, _defaultButtonSize);
            expect(rect.left, greaterThanOrEqualTo(0));
            expect(rect.right, lessThanOrEqualTo(width));
            expect(rect.bottom, closeTo(expectedBottom, 0.001));
          }
        }
      }
    }
  });

  testWidgets('AC-11: SafeArea有効時は左右を避け、無効時は最小下余白だけを残す', (tester) async {
    addTearDown(tester.view.reset);
    const width = 400.0;
    const height = 640.0;
    const leftInset = 20.0;
    const rightInset = 220.0;
    const bottomInset = 50.0;
    const minimumBottomPadding = 40.0;
    final items = _items(2, prefix: 'ac11');

    _setView(
      tester,
      width: width,
      height: height,
      left: leftInset,
      right: rightInset,
      bottom: bottomInset,
    );
    await tester.pumpWidget(
      _navigationHost(
        _navigation(items: items, minimumBottomPadding: minimumBottomPadding),
      ),
    );
    await tester.pumpAndSettle();
    final safeFirst = tester.getRect(_navButton('ac11-0'));
    final safeLast = tester.getRect(_navButton('ac11-1'));
    expect(safeFirst.left, greaterThanOrEqualTo(leftInset));
    expect(safeLast.right, lessThanOrEqualTo(width - rightInset));
    expect(safeLast.bottom, closeTo(height - bottomInset, 0.001));

    await tester.pumpWidget(
      _navigationHost(
        _navigation(
          items: items,
          minimumBottomPadding: minimumBottomPadding,
          useSafeArea: false,
        ),
      ),
    );
    await tester.pumpAndSettle();
    final unsafeFirst = tester.getRect(_navButton('ac11-0'));
    final unsafeLast = tester.getRect(_navButton('ac11-1'));
    expect(unsafeFirst.left, closeTo(144, 0.001));
    expect(unsafeLast.right, closeTo(256, 0.001));
    expect(
      (unsafeFirst.left + unsafeLast.right) / 2,
      closeTo(width / 2, 0.001),
    );
    expect(unsafeLast.right, greaterThan(width - rightInset));
    expect(unsafeLast.bottom, closeTo(height - minimumBottomPadding, 0.001));
  });

  testWidgets('AC-13: 寸法の有効境界を受け入れ、不正な境界をArgumentErrorで拒否する', (tester) async {
    _expectArgumentError(buttonSize: 47);
    _expectValidNavigation(buttonSize: 48);

    _expectArgumentError(gap: -1);
    _expectValidNavigation(gap: 0);

    _expectArgumentError(minimumBottomPadding: -1);
    _expectValidNavigation(minimumBottomPadding: 0);

    _expectArgumentError(borderRadius: -1);
    _expectValidNavigation(borderRadius: 0);
    _expectValidNavigation(buttonSize: 52, borderRadius: 26);
    _expectArgumentError(buttonSize: 52, borderRadius: 26.1);

    _expectArgumentError(iconSize: 0);
    _expectValidNavigation(iconSize: 1);
    _expectValidNavigation(buttonSize: 52, iconSize: 52);
    _expectArgumentError(buttonSize: 52, iconSize: 52.1);
  });

  testWidgets('AC-14: 寸法のNaNと正負InfinityをArgumentErrorで拒否する', (tester) async {
    const dimensions = <String>[
      'buttonSize',
      'gap',
      'borderRadius',
      'iconSize',
      'minimumBottomPadding',
    ];
    const invalidValues = <double>[
      double.nan,
      double.infinity,
      double.negativeInfinity,
    ];

    for (final dimension in dimensions) {
      for (final value in invalidValues) {
        expect(
          () => _navigationWithDimension(dimension, value),
          throwsArgumentError,
          reason: '$dimension=$value',
        );
      }
    }
  });
}
