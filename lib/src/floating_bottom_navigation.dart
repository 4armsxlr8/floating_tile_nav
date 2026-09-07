import 'package:flutter/widgets.dart';

const _navigationButtonSize = 52.0;
const _navigationGap = 8.0;
const _navigationRadius = 16.0;
const _navigationColor = Color(0xff32332d);
const _navigationIconColor = Color(0xFFFFFFFF);
const _navigationIconSize = 28.0;
const _navigationMinimumBottomPadding = 32.0;
const _pressDuration = Duration(milliseconds: 120);
const _pressScale = 0.88;

/// A navigation item displayed by [FloatingBottomNavigation].
class FloatingNavigationItem {
  /// Creates a navigation item with separate unselected and selected icons.
  const FloatingNavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.semanticLabel,
  });

  /// The icon shown while this item is unselected.
  final Widget icon;

  /// The icon shown while this item is selected.
  final Widget selectedIcon;

  /// The label exposed to accessibility services.
  final String semanticLabel;
}

/// The custom icon shapes included with this package.
enum FloatingNavigationIconType {
  /// A house-shaped home icon.
  home,

  /// A magnifying-glass search icon.
  search,

  /// A person-shaped profile icon.
  profile,
}

/// Paints one of the package's reusable navigation icon shapes.
class FloatingNavigationIcon extends StatelessWidget {
  /// Creates a custom navigation icon.
  const FloatingNavigationIcon({
    super.key,
    required this.icon,
    this.selected = false,
    this.color,
    this.size,
  });

  /// The shape to paint.
  final FloatingNavigationIconType icon;

  /// Whether to paint the selected, filled form of the shape.
  final bool selected;

  /// An optional color override. The surrounding [IconTheme] is used when
  /// this is omitted.
  final Color? color;

  /// An optional logical-pixel size override. The surrounding [IconTheme] is
  /// used when this is omitted.
  final double? size;

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final resolvedColor = color ?? iconTheme.color ?? _navigationIconColor;
    final resolvedSize = size ?? iconTheme.size ?? _navigationIconSize;
    return CustomPaint(
      size: Size.square(resolvedSize),
      painter: _NavigationIconPainter(
        icon: icon,
        selected: selected,
        color: resolvedColor,
        backgroundColor: _FloatingNavigationBackground.of(context),
      ),
    );
  }
}

/// Displays a controlled, floating row of navigation buttons.
class FloatingBottomNavigation extends StatelessWidget {
  /// Creates a navigation row.
  ///
  /// The [selectedIndex] and [onSelected] values are controlled by the
  /// hosting application. If [items] is omitted, the package's three default
  /// items are used.
  FloatingBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    List<FloatingNavigationItem>? items,
    this.backgroundColor = _navigationColor,
    this.iconColor = _navigationIconColor,
    this.buttonSize = _navigationButtonSize,
    this.gap = _navigationGap,
    this.borderRadius = _navigationRadius,
    this.iconSize = _navigationIconSize,
    this.minimumBottomPadding = _navigationMinimumBottomPadding,
    this.useSafeArea = true,
  }) : items = _copyAndValidateItems(items),
       _usesDefaultItems = items == null {
    _validateSelectedIndex(selectedIndex, (this.items ?? _defaultItems).length);
    _validateStyle(
      buttonSize: buttonSize,
      gap: gap,
      borderRadius: borderRadius,
      iconSize: iconSize,
      minimumBottomPadding: minimumBottomPadding,
    );
  }

  /// The externally controlled selected item index.
  final int selectedIndex;

  /// Called once with an item index after a successful tap.
  final ValueChanged<int> onSelected;

  /// The optional defensive copy of the items supplied to the constructor.
  final List<FloatingNavigationItem>? items;

  /// The button background color.
  final Color backgroundColor;

  /// The default color inherited by icons that do not specify one.
  final Color iconColor;

  /// The logical-pixel width and height of each button.
  final double buttonSize;

  /// The logical-pixel gap between adjacent buttons.
  final double gap;

  /// The logical-pixel corner radius of each button.
  final double borderRadius;

  /// The logical-pixel default size inherited by icons that do not specify
  /// one.
  final double iconSize;

  /// The minimum logical-pixel space below the navigation row.
  final double minimumBottomPadding;

  /// Whether operating-system safe-area insets are applied on the bottom and
  /// sides.
  final bool useSafeArea;

  final bool _usesDefaultItems;

  static const _defaultItems = <FloatingNavigationItem>[
    FloatingNavigationItem(
      icon: FloatingNavigationIcon(icon: FloatingNavigationIconType.home),
      selectedIcon: FloatingNavigationIcon(
        icon: FloatingNavigationIconType.home,
        selected: true,
      ),
      semanticLabel: 'ホーム',
    ),
    FloatingNavigationItem(
      icon: FloatingNavigationIcon(icon: FloatingNavigationIconType.search),
      selectedIcon: FloatingNavigationIcon(
        icon: FloatingNavigationIconType.search,
        selected: true,
      ),
      semanticLabel: '検索',
    ),
    FloatingNavigationItem(
      icon: FloatingNavigationIcon(icon: FloatingNavigationIconType.profile),
      selectedIcon: FloatingNavigationIcon(
        icon: FloatingNavigationIconType.profile,
        selected: true,
      ),
      semanticLabel: 'プロフィール',
    ),
  ];

  static List<FloatingNavigationItem>? _copyAndValidateItems(
    List<FloatingNavigationItem>? items,
  ) {
    if (items == null) {
      return null;
    }
    if (items.length < 2 || items.length > 5) {
      throw ArgumentError.value(
        items.length,
        'items',
        'must contain between 2 and 5 navigation items',
      );
    }
    for (final item in items) {
      if (item.semanticLabel.trim().isEmpty) {
        throw ArgumentError.value(
          item.semanticLabel,
          'semanticLabel',
          'must contain at least one non-whitespace character',
        );
      }
    }
    return List<FloatingNavigationItem>.unmodifiable(items);
  }

  static void _validateSelectedIndex(int selectedIndex, int itemCount) {
    if (selectedIndex < 0 || selectedIndex >= itemCount) {
      throw ArgumentError.value(
        selectedIndex,
        'selectedIndex',
        'must refer to an item between 0 and ${itemCount - 1}',
      );
    }
  }

  static void _validateStyle({
    required double buttonSize,
    required double gap,
    required double borderRadius,
    required double iconSize,
    required double minimumBottomPadding,
  }) {
    if (!buttonSize.isFinite || buttonSize < 48) {
      throw ArgumentError.value(
        buttonSize,
        'buttonSize',
        'must be finite and at least 48 logical pixels',
      );
    }
    if (!gap.isFinite || gap < 0) {
      throw ArgumentError.value(gap, 'gap', 'must be finite and non-negative');
    }
    if (!borderRadius.isFinite ||
        borderRadius < 0 ||
        borderRadius > buttonSize / 2) {
      throw ArgumentError.value(
        borderRadius,
        'borderRadius',
        'must be finite, non-negative, and at most half of buttonSize',
      );
    }
    if (!iconSize.isFinite || iconSize <= 0 || iconSize > buttonSize) {
      throw ArgumentError.value(
        iconSize,
        'iconSize',
        'must be finite, greater than 0, and no larger than buttonSize',
      );
    }
    if (!minimumBottomPadding.isFinite || minimumBottomPadding < 0) {
      throw ArgumentError.value(
        minimumBottomPadding,
        'minimumBottomPadding',
        'must be finite and non-negative',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final navigationItems = items ?? _defaultItems;
    final navigation = Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < navigationItems.length; index += 1) ...[
            if (index > 0) SizedBox(width: gap),
            _FloatingNavigationButton(
              key: ValueKey<int>(index),
              item: navigationItems[index],
              selected: index == selectedIndex,
              onSelected: () => onSelected(index),
              searchVisual: _usesDefaultItems && index == 1,
              backgroundColor: backgroundColor,
              iconColor: iconColor,
              buttonSize: buttonSize,
              borderRadius: borderRadius,
              iconSize: iconSize,
            ),
          ],
        ],
      ),
    );
    if (!useSafeArea) {
      return Padding(
        padding: EdgeInsets.only(bottom: minimumBottomPadding),
        child: navigation,
      );
    }
    return SafeArea(
      top: false,
      left: true,
      right: true,
      bottom: true,
      minimum: EdgeInsets.only(bottom: minimumBottomPadding),
      child: navigation,
    );
  }
}

class _FloatingNavigationBackground extends InheritedWidget {
  const _FloatingNavigationBackground({
    required this.color,
    required super.child,
  });

  final Color color;

  static Color of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<_FloatingNavigationBackground>()
            ?.color ??
        _navigationColor;
  }

  @override
  bool updateShouldNotify(_FloatingNavigationBackground oldWidget) {
    return color != oldWidget.color;
  }
}

class _FloatingNavigationButton extends StatefulWidget {
  const _FloatingNavigationButton({
    super.key,
    required this.item,
    required this.selected,
    required this.onSelected,
    required this.searchVisual,
    required this.backgroundColor,
    required this.iconColor,
    required this.buttonSize,
    required this.borderRadius,
    required this.iconSize,
  });

  final FloatingNavigationItem item;
  final bool selected;
  final VoidCallback onSelected;
  final bool searchVisual;
  final Color backgroundColor;
  final Color iconColor;
  final double buttonSize;
  final double borderRadius;
  final double iconSize;

  @override
  State<_FloatingNavigationButton> createState() =>
      _FloatingNavigationButtonState();
}

class _FloatingNavigationButtonState extends State<_FloatingNavigationButton> {
  bool _pressed = false;
  final _buttonKey = GlobalKey();

  void _setPressed(bool value) {
    if (_pressed == value || !mounted) {
      return;
    }
    setState(() => _pressed = value);
  }

  bool _isInside(Offset globalPosition) {
    final renderObject = _buttonKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return false;
    }
    final localPosition = renderObject.globalToLocal(globalPosition);
    return renderObject.size.contains(localPosition);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: widget.item.semanticLabel,
      button: true,
      selected: widget.selected,
      onTap: widget.onSelected,
      child: SizedBox(
        key: _buttonKey,
        width: widget.buttonSize,
        height: widget.buttonSize,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => _setPressed(true),
          onTapUp: (details) {
            final wasInside = _isInside(details.globalPosition);
            _setPressed(false);
            if (wasInside) {
              widget.onSelected();
            }
          },
          onTapCancel: () => _setPressed(false),
          child: AnimatedScale(
            scale: _pressed ? _pressScale : 1,
            duration: _pressDuration,
            curve: Curves.easeOut,
            child: Container(
              key: widget.searchVisual
                  ? const ValueKey<String>('nav-search-visual')
                  : null,
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
              alignment: Alignment.center,
              child: _FloatingNavigationBackground(
                color: widget.backgroundColor,
                child: IconTheme.merge(
                  data: IconThemeData(
                    color: widget.iconColor,
                    size: widget.iconSize,
                  ),
                  child: ExcludeSemantics(
                    child: widget.selected
                        ? widget.item.selectedIcon
                        : widget.item.icon,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationIconPainter extends CustomPainter {
  const _NavigationIconPainter({
    required this.icon,
    required this.selected,
    required this.color,
    required this.backgroundColor,
  });

  final FloatingNavigationIconType icon;
  final bool selected;
  final Color color;
  final Color backgroundColor;

  Paint _paint({bool fill = false}) {
    return Paint()
      ..color = color
      ..style = fill ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
  }

  @override
  void paint(Canvas canvas, Size size) {
    switch (icon) {
      case FloatingNavigationIconType.home:
        _paintHome(canvas, size);
      case FloatingNavigationIconType.search:
        _paintSearch(canvas, size);
      case FloatingNavigationIconType.profile:
        _paintProfile(canvas, size);
    }
  }

  void _paintHome(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * .16, size.height * .47)
      ..lineTo(size.width * .43, size.height * .22)
      ..quadraticBezierTo(
        size.width * .5,
        size.height * .15,
        size.width * .57,
        size.height * .22,
      )
      ..lineTo(size.width * .84, size.height * .47)
      ..lineTo(size.width * .84, size.height * .76)
      ..quadraticBezierTo(
        size.width * .84,
        size.height * .86,
        size.width * .74,
        size.height * .86,
      )
      ..lineTo(size.width * .26, size.height * .86)
      ..quadraticBezierTo(
        size.width * .16,
        size.height * .86,
        size.width * .16,
        size.height * .76,
      )
      ..close();
    canvas.drawPath(path, _paint(fill: selected));
    if (selected) {
      final smile = Path()
        ..moveTo(size.width * .4, size.height * .69)
        ..quadraticBezierTo(
          size.width * .5,
          size.height * .77,
          size.width * .6,
          size.height * .69,
        );
      canvas.drawPath(smile, _paint()..color = backgroundColor);
    }
  }

  void _paintSearch(Canvas canvas, Size size) {
    final center = Offset(size.width * .43, size.height * .43);
    canvas.drawCircle(center, size.width * .27, _paint(fill: selected));
    if (selected) {
      canvas.drawCircle(
        center,
        size.width * .13,
        _paint(fill: true)..color = backgroundColor,
      );
    }
    canvas.drawLine(
      Offset(size.width * .63, size.height * .63),
      Offset(size.width * .86, size.height * .86),
      _paint(),
    );
  }

  void _paintProfile(Canvas canvas, Size size) {
    final headCenter = Offset(size.width * .5, size.height * .3);
    canvas.drawCircle(headCenter, size.width * .14, _paint(fill: selected));
    final body = Path()
      ..moveTo(size.width * .18, size.height * .84)
      ..cubicTo(
        size.width * .2,
        size.height * .6,
        size.width * .8,
        size.height * .6,
        size.width * .82,
        size.height * .84,
      )
      ..lineTo(size.width * .18, size.height * .84)
      ..close();
    canvas.drawPath(body, _paint(fill: selected));
  }

  @override
  bool shouldRepaint(covariant _NavigationIconPainter oldDelegate) {
    return oldDelegate.icon != icon ||
        oldDelegate.selected != selected ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
