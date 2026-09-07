import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:floating_tile_nav_example/src/demo_app.dart';
import 'package:floating_tile_nav_example/src/demo_pages.dart';

const _navLabels = <String>['ホーム', '検索', 'プロフィール'];

Finder _navButton(String label) => find.bySemanticsLabel(label).last;

List<DemoCard> _manyCards() {
  return List<DemoCard>.generate(
    24,
    (index) =>
        DemoCard(title: 'カード$index', color: Colors.blueGrey, height: 140),
  );
}

void main() {
  testWidgets('AC-1: 初回起動ではホームだけが選択される', (tester) async {
    await tester.pumpWidget(FloatingTileNavDemoApp());
    await tester.pumpAndSettle();

    expect(find.text('Floating Tile Nav'), findsOneWidget);
    for (final label in _navLabels) {
      final button = _navButton(label);
      expect(button, findsOneWidget);
      expect(
        tester.getSemantics(button),
        isSemantics(
          label: label,
          hasTapAction: true,
          hasSelectedState: true,
          isSelected: label == 'ホーム',
        ),
      );
    }
  });

  testWidgets('AC-2: ナビタップで画面と選択状態が順番に切り替わる', (tester) async {
    await tester.pumpWidget(FloatingTileNavDemoApp());
    await tester.pumpAndSettle();

    for (final target in <String>['検索', 'プロフィール', 'ホーム']) {
      await tester.tap(_navButton(target));
      await tester.pumpAndSettle();

      expect(
        find.text(target == 'ホーム' ? 'Floating Tile Nav' : target),
        findsOneWidget,
      );
      for (final label in _navLabels) {
        expect(
          tester.getSemantics(_navButton(label)),
          isSemantics(
            label: label,
            hasSelectedState: true,
            isSelected: label == target,
          ),
        );
      }
    }
  });

  testWidgets('AC-3: ホームのスクロール位置をタブ往復と再タップで保持する', (tester) async {
    await tester.pumpWidget(FloatingTileNavDemoApp(homeCards: _manyCards()));
    await tester.pumpAndSettle();

    final homeScrollable = find.byType(Scrollable).first;
    final homeState = tester.state<ScrollableState>(homeScrollable);
    final initialOffset = homeState.position.pixels;
    await tester.drag(homeScrollable, const Offset(0, -280));
    await tester.pumpAndSettle();
    final scrolledOffset = homeState.position.pixels;
    expect(scrolledOffset, greaterThan(initialOffset));

    await tester.tap(_navButton('検索'));
    await tester.pumpAndSettle();
    await tester.tap(_navButton('ホーム'));
    await tester.pumpAndSettle();
    expect(homeState.position.pixels, closeTo(scrolledOffset, 0.001));

    await tester.tap(_navButton('ホーム'));
    await tester.pumpAndSettle();
    expect(homeState.position.pixels, closeTo(scrolledOffset, 0.001));
  });

  testWidgets('AC-4: 上下スクロール後もナビが固定されてタップできる', (tester) async {
    await tester.pumpWidget(FloatingTileNavDemoApp(homeCards: _manyCards()));
    await tester.pumpAndSettle();

    final homeButton = _navButton('ホーム');
    final initialRect = tester.getRect(homeButton);
    final homeScrollable = find.byType(Scrollable).first;
    await tester.drag(homeScrollable, const Offset(0, -280));
    await tester.pumpAndSettle();
    await tester.drag(homeScrollable, const Offset(0, 180));
    await tester.pumpAndSettle();

    expect(tester.getRect(homeButton), initialRect);
    await tester.tap(_navButton('検索'));
    await tester.pumpAndSettle();
    expect(find.text('検索'), findsOneWidget);
  });

  testWidgets('AC-5: キャンセルでは選択を変えず、離した後の通常タップは切り替わる', (tester) async {
    await tester.pumpWidget(FloatingTileNavDemoApp());
    await tester.pumpAndSettle();

    final searchButton = _navButton('検索');
    final searchVisual = find.byKey(
      const ValueKey<String>('nav-search-visual'),
    );
    expect(searchVisual, findsOneWidget);
    final initialVisualRect = tester.getRect(searchVisual);

    final movedGesture = await tester.startGesture(
      tester.getCenter(searchButton),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    final pressedVisualRect = tester.getRect(searchVisual);
    expect(pressedVisualRect.width, lessThan(initialVisualRect.width));
    await movedGesture.moveBy(const Offset(0, -120));
    await movedGesture.up();
    await tester.pumpAndSettle();

    expect(find.text('Floating Tile Nav'), findsOneWidget);
    expect(tester.getRect(searchVisual), initialVisualRect);

    final cancelledGesture = await tester.startGesture(
      tester.getCenter(searchButton),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    await cancelledGesture.cancel();
    await tester.pumpAndSettle();

    expect(find.text('Floating Tile Nav'), findsOneWidget);
    expect(tester.getRect(searchVisual), initialVisualRect);

    await tester.tap(searchButton);
    await tester.pumpAndSettle();
    expect(find.text('検索'), findsOneWidget);
  });

  testWidgets('AC-6: 幅320/430と下余白0/34でナビが画面内に収まる', (tester) async {
    addTearDown(tester.view.reset);

    tester.view.devicePixelRatio = 1;
    const height = 640.0;
    for (final width in <double>[320, 430]) {
      for (final bottomPadding in <double>[0, 34]) {
        tester.view
          ..physicalSize = Size(width, height)
          ..padding = FakeViewPadding(bottom: bottomPadding)
          ..viewPadding = FakeViewPadding(bottom: bottomPadding);
        await tester.pumpWidget(FloatingTileNavDemoApp());
        await tester.pumpAndSettle();

        for (final label in _navLabels) {
          final rect = tester.getRect(_navButton(label));
          expect(rect.left, greaterThanOrEqualTo(0));
          expect(rect.right, lessThanOrEqualTo(width));
          expect(rect.top, greaterThanOrEqualTo(0));
          expect(rect.bottom, lessThanOrEqualTo(height - bottomPadding));
        }
      }
    }
  });

  testWidgets('AC-7: 空一覧でも使え、多数件を末尾までスクロールできる', (tester) async {
    await tester.pumpWidget(FloatingTileNavDemoApp(homeCards: <DemoCard>[]));
    await tester.pumpAndSettle();
    expect(find.text('アイデアはまだありません'), findsOneWidget);
    await tester.tap(_navButton('検索'));
    await tester.pumpAndSettle();
    expect(find.text('検索'), findsOneWidget);

    final cards = _manyCards();
    await tester.pumpWidget(
      FloatingTileNavDemoApp(
        key: const ValueKey<String>('many-cards'),
        homeCards: cards,
      ),
    );
    await tester.pumpAndSettle();
    final homeScrollable = find.byType(Scrollable).first;
    final lastCard = find.text('カード23', skipOffstage: false);
    await tester.scrollUntilVisible(lastCard, 500, scrollable: homeScrollable);
    final homeState = tester.state<ScrollableState>(homeScrollable);
    homeState.position.jumpTo(homeState.position.maxScrollExtent);
    await tester.pumpAndSettle();

    expect(lastCard, findsOneWidget);
    expect(homeState.position.pixels, greaterThan(0));
    expect(
      tester.getRect(lastCard).bottom,
      lessThan(tester.getRect(_navButton('ホーム')).top),
    );
  });

  testWidgets('AC-8: ナビの名前・選択状態・タップ領域を公開情報で確認できる', (tester) async {
    await tester.pumpWidget(FloatingTileNavDemoApp());
    await tester.pumpAndSettle();

    for (final label in _navLabels) {
      final button = _navButton(label);
      expect(button, findsOneWidget);
      expect(
        tester.getSemantics(button),
        isSemantics(
          label: label,
          hasTapAction: true,
          hasSelectedState: true,
          isSelected: label == 'ホーム',
        ),
      );
      final rect = tester.getRect(button);
      expect(rect.width, greaterThanOrEqualTo(48));
      expect(rect.height, greaterThanOrEqualTo(48));
    }
  });
}
