import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:floating_tile_nav/floating_tile_nav.dart';

Finder _navButton(String label, {int index = 0}) {
  return find.bySemanticsLabel(label).at(index);
}

FinderBase<SemanticsNode> _navSemantics(String label, {int index = 0}) {
  return find.semantics.byLabel(label).at(index);
}

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
  String semanticLabel, {
  String? iconKey,
  String? selectedIconKey,
}) {
  return FloatingNavigationItem(
    icon: SizedBox(
      key: iconKey == null ? null : ValueKey<String>(iconKey),
      width: 24,
      height: 24,
    ),
    selectedIcon: SizedBox(
      key: selectedIconKey == null ? null : ValueKey<String>(selectedIconKey),
      width: 24,
      height: 24,
    ),
    semanticLabel: semanticLabel,
  );
}

List<FloatingNavigationItem> _items(int count, {String prefix = 'item'}) {
  return List<FloatingNavigationItem>.generate(
    count,
    (index) => _item('$prefix-$index'),
  );
}

void _expectSelected(
  WidgetTester tester,
  String label,
  bool selected, {
  int index = 0,
}) {
  expect(
    tester.getSemantics(_navButton(label, index: index)),
    isSemantics(
      label: label,
      hasTapAction: true,
      hasSelectedState: true,
      isSelected: selected,
    ),
  );
}

void main() {
  testWidgets('AC-2: itemsを省略すると既定3項目と選択状態を表示する', (tester) async {
    await tester.pumpWidget(
      _navigationHost(
        FloatingBottomNavigation(selectedIndex: 0, onSelected: (_) {}),
      ),
    );
    await tester.pumpAndSettle();

    for (final label in <String>['ホーム', '検索', 'プロフィール']) {
      expect(find.bySemanticsLabel(label), findsOneWidget);
      _expectSelected(tester, label, label == 'ホーム');
    }
  });

  testWidgets('AC-3: 2項目と5項目で指定順・アイコン・ラベル・選択状態を反映する', (tester) async {
    final twoItems = <FloatingNavigationItem>[
      _item('二つ目の先頭', iconKey: 'two-icon-0', selectedIconKey: 'two-selected-0'),
      _item('二つ目の末尾', iconKey: 'two-icon-1', selectedIconKey: 'two-selected-1'),
    ];
    await tester.pumpWidget(
      _navigationHost(
        FloatingBottomNavigation(
          selectedIndex: 0,
          onSelected: (_) {},
          items: twoItems,
        ),
      ),
    );
    await tester.pumpAndSettle();

    for (var index = 0; index < twoItems.length; index += 1) {
      final label = index == 0 ? '二つ目の先頭' : '二つ目の末尾';
      _expectSelected(tester, label, index == 0);
      expect(
        find.byKey(
          ValueKey<String>('two-${index == 0 ? 'selected' : 'icon'}-$index'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(
          ValueKey<String>('two-${index == 0 ? 'icon' : 'selected'}-$index'),
        ),
        findsNothing,
      );
      if (index > 0) {
        expect(
          tester.getCenter(find.byKey(ValueKey<String>('two-icon-1'))).dx,
          greaterThan(
            tester.getCenter(find.byKey(ValueKey<String>('two-selected-0'))).dx,
          ),
        );
      }
    }

    final fiveItems = List<FloatingNavigationItem>.generate(
      5,
      (index) => _item(
        '五つ目-$index',
        iconKey: 'five-icon-$index',
        selectedIconKey: 'five-selected-$index',
      ),
    );
    await tester.pumpWidget(
      _navigationHost(
        FloatingBottomNavigation(
          selectedIndex: 4,
          onSelected: (_) {},
          items: fiveItems,
        ),
      ),
    );
    await tester.pumpAndSettle();

    var previousX = double.negativeInfinity;
    for (var index = 0; index < fiveItems.length; index += 1) {
      final label = '五つ目-$index';
      _expectSelected(tester, label, index == 4);
      expect(
        find.byKey(
          ValueKey<String>(
            index == 4 ? 'five-selected-$index' : 'five-icon-$index',
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(
          ValueKey<String>(
            index == 4 ? 'five-icon-$index' : 'five-selected-$index',
          ),
        ),
        findsNothing,
      );
      final centerX = tester
          .getCenter(
            find.byKey(
              ValueKey<String>(
                index == 4 ? 'five-selected-$index' : 'five-icon-$index',
              ),
            ),
          )
          .dx;
      expect(centerX, greaterThan(previousX));
      previousX = centerX;
    }
  });

  testWidgets('AC-4: 同じ読み上げ名の兄弟項目も位置の番号を通知する', (tester) async {
    final selectedIndices = <int>[];
    await tester.pumpWidget(
      _navigationHost(
        FloatingBottomNavigation(
          selectedIndex: 0,
          onSelected: selectedIndices.add,
          items: <FloatingNavigationItem>[
            _item('同じ名前', iconKey: 'duplicate-icon-0'),
            _item('同じ名前', iconKey: 'duplicate-icon-1'),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('同じ名前'), findsNWidgets(2));
    await tester.tap(_navButton('同じ名前', index: 0));
    await tester.pumpAndSettle();
    expect(selectedIndices, <int>[0]);

    await tester.tap(_navButton('同じ名前', index: 1));
    await tester.pumpAndSettle();
    expect(selectedIndices, <int>[0, 1]);
  });

  testWidgets('AC-5: 選択番号は通知だけでは変わらず、更新後に反映される', (tester) async {
    var selectedIndex = 0;
    final selectedIndices = <int>[];
    final items = <FloatingNavigationItem>[_item('制御先頭'), _item('制御末尾')];

    await tester.pumpWidget(
      _navigationHost(
        FloatingBottomNavigation(
          selectedIndex: selectedIndex,
          onSelected: selectedIndices.add,
          items: items,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(_navButton('制御末尾'));
    await tester.pumpAndSettle();
    expect(selectedIndices, <int>[1]);
    _expectSelected(tester, '制御先頭', true);
    _expectSelected(tester, '制御末尾', false);

    selectedIndex = 1;
    await tester.pumpWidget(
      _navigationHost(
        FloatingBottomNavigation(
          selectedIndex: selectedIndex,
          onSelected: selectedIndices.add,
          items: items,
        ),
      ),
    );
    await tester.pumpAndSettle();
    _expectSelected(tester, '制御先頭', false);
    _expectSelected(tester, '制御末尾', true);
  });

  testWidgets('AC-6: 通常タップ・再タップ・読み上げタップは各1回通知する', (tester) async {
    final selectedIndices = <int>[];
    await tester.pumpWidget(
      _navigationHost(
        FloatingBottomNavigation(
          selectedIndex: 0,
          onSelected: selectedIndices.add,
          items: <FloatingNavigationItem>[_item('選択済み'), _item('未選択')],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(_navButton('未選択'));
    await tester.pumpAndSettle();
    expect(selectedIndices, <int>[1]);

    await tester.tap(_navButton('選択済み'));
    await tester.pumpAndSettle();
    expect(selectedIndices, <int>[1, 0]);

    tester.semantics.tap(_navSemantics('未選択'));
    await tester.pumpAndSettle();
    expect(selectedIndices, <int>[1, 0, 1]);

    tester.semantics.tap(_navSemantics('選択済み'));
    await tester.pumpAndSettle();
    expect(selectedIndices, <int>[1, 0, 1, 0]);
  });

  testWidgets('AC-7: 外側離しとキャンセルは通知せず縮小を戻し、通常タップは通知する', (tester) async {
    final selectedIndices = <int>[];
    await tester.pumpWidget(
      _navigationHost(
        FloatingBottomNavigation(
          selectedIndex: 0,
          onSelected: selectedIndices.add,
          items: <FloatingNavigationItem>[
            _item('押下元'),
            _item('押下対象', iconKey: 'ac7-target-icon'),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    final button = _navButton('押下対象');
    final visual = find.byKey(const ValueKey<String>('ac7-target-icon'));
    final initialButtonRect = tester.getRect(button);
    final initialVisualRect = tester.getRect(visual);
    expect(initialButtonRect.width, greaterThanOrEqualTo(48));
    expect(initialButtonRect.height, greaterThanOrEqualTo(48));

    final outsideGesture = await tester.startGesture(tester.getCenter(button));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    final halfwayVisualRect = tester.getRect(visual);
    expect(halfwayVisualRect.width, lessThan(initialVisualRect.width));
    expect(tester.getRect(button), initialButtonRect);
    await tester.pump(const Duration(milliseconds: 60));
    final pressedVisualRect = tester.getRect(visual);
    expect(
      pressedVisualRect.width,
      closeTo(initialVisualRect.width * 0.88, 0.5),
    );
    expect(pressedVisualRect.width, lessThan(halfwayVisualRect.width));
    expect(tester.getRect(button), initialButtonRect);

    await outsideGesture.moveBy(const Offset(0, -120));
    await outsideGesture.up();
    await tester.pumpAndSettle();
    expect(selectedIndices, isEmpty);
    expect(tester.getRect(visual), initialVisualRect);
    expect(tester.getRect(button), initialButtonRect);

    final cancelledGesture = await tester.startGesture(
      tester.getCenter(button),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(tester.getRect(visual).width, lessThan(initialVisualRect.width));
    await cancelledGesture.cancel();
    await tester.pumpAndSettle();
    expect(selectedIndices, isEmpty);
    expect(tester.getRect(visual), initialVisualRect);
    expect(tester.getRect(button), initialButtonRect);

    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(selectedIndices, <int>[1]);
  });

  testWidgets('AC-12: 不正な項目数・選択番号・空白ラベルはArgumentErrorになる', (tester) async {
    expect(
      () => FloatingBottomNavigation(
        selectedIndex: 0,
        onSelected: (_) {},
        items: <FloatingNavigationItem>[],
      ),
      throwsArgumentError,
    );
    expect(
      () => FloatingBottomNavigation(
        selectedIndex: 0,
        onSelected: (_) {},
        items: _items(1),
      ),
      throwsArgumentError,
    );
    expect(
      () => FloatingBottomNavigation(
        selectedIndex: 0,
        onSelected: (_) {},
        items: _items(6),
      ),
      throwsArgumentError,
    );
    expect(
      () => FloatingBottomNavigation(
        selectedIndex: -1,
        onSelected: (_) {},
        items: _items(2),
      ),
      throwsArgumentError,
    );
    expect(
      () => FloatingBottomNavigation(
        selectedIndex: 2,
        onSelected: (_) {},
        items: _items(2),
      ),
      throwsArgumentError,
    );
    expect(
      () => FloatingBottomNavigation(
        selectedIndex: 0,
        onSelected: (_) {},
        items: <FloatingNavigationItem>[_item('   '), _item('有効')],
      ),
      throwsArgumentError,
    );
  });

  testWidgets('AC-15: 5項目から2項目への有効更新を反映し範囲外を拒否する', (tester) async {
    final fiveItems = _items(5, prefix: 'old');
    final twoItems = _items(2, prefix: 'new');
    await tester.pumpWidget(
      _navigationHost(
        FloatingBottomNavigation(
          selectedIndex: 4,
          onSelected: (_) {},
          items: fiveItems,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.pumpWidget(
      _navigationHost(
        FloatingBottomNavigation(
          selectedIndex: 1,
          onSelected: (_) {},
          items: twoItems,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('old-4'), findsNothing);
    expect(find.bySemanticsLabel('new-0'), findsOneWidget);
    expect(find.bySemanticsLabel('new-1'), findsOneWidget);
    _expectSelected(tester, 'new-0', false);
    _expectSelected(tester, 'new-1', true);

    expect(
      () => FloatingBottomNavigation(
        selectedIndex: 4,
        onSelected: (_) {},
        items: twoItems,
      ),
      throwsArgumentError,
    );
  });
}
