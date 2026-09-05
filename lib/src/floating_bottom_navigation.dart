import 'package:flutter/material.dart';

const _navigationButtonSize = 52.0;
const _navigationGap = 8.0;
const _navigationRadius = 16.0;
const _navigationColor = Color(0xff32332d);
const _navigationIconSize = 28.0;
const _pressDuration = Duration(milliseconds: 120);
const _pressScale = 0.88;

class FloatingBottomNavigation extends StatelessWidget {
  const FloatingBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _items = <_NavigationItem>[
    _NavigationItem(label: 'ホーム', icon: _NavigationIcon.home),
    _NavigationItem(label: '検索', icon: _NavigationIcon.search),
    _NavigationItem(label: 'プロフィール', icon: _NavigationIcon.profile),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      left: false,
      right: false,
      minimum: const EdgeInsets.only(bottom: 32),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var index = 0; index < _items.length; index += 1) ...[
              if (index > 0) const SizedBox(width: _navigationGap),
              _FloatingNavigationButton(
                key: ValueKey<String>('nav-${_items[index].label}'),
                item: _items[index],
                selected: index == selectedIndex,
                onSelected: () => onSelected(index),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NavigationItem {
  const _NavigationItem({required this.label, required this.icon});

  final String label;
  final _NavigationIcon icon;
}

enum _NavigationIcon { home, search, profile }

class _FloatingNavigationButton extends StatefulWidget {
  const _FloatingNavigationButton({
    super.key,
    required this.item,
    required this.selected,
    required this.onSelected,
  });

  final _NavigationItem item;
  final bool selected;
  final VoidCallback onSelected;

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
      label: widget.item.label,
      button: true,
      selected: widget.selected,
      onTap: widget.onSelected,
      child: SizedBox(
        key: _buttonKey,
        width: _navigationButtonSize,
        height: _navigationButtonSize,
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
              key: widget.item.icon == _NavigationIcon.search
                  ? const ValueKey<String>('nav-search-visual')
                  : null,
              decoration: BoxDecoration(
                color: _navigationColor,
                borderRadius: BorderRadius.circular(_navigationRadius),
              ),
              alignment: Alignment.center,
              child: ExcludeSemantics(
                child: CustomPaint(
                  size: const Size.square(_navigationIconSize),
                  painter: _NavigationIconPainter(
                    icon: widget.item.icon,
                    selected: widget.selected,
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
  const _NavigationIconPainter({required this.icon, required this.selected});

  final _NavigationIcon icon;
  final bool selected;

  Paint _paint({bool fill = false}) {
    return Paint()
      ..color = Colors.white
      ..style = fill ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
  }

  @override
  void paint(Canvas canvas, Size size) {
    switch (icon) {
      case _NavigationIcon.home:
        _paintHome(canvas, size);
      case _NavigationIcon.search:
        _paintSearch(canvas, size);
      case _NavigationIcon.profile:
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
      canvas.drawPath(smile, _paint()..color = _navigationColor);
    }
  }

  void _paintSearch(Canvas canvas, Size size) {
    final center = Offset(size.width * .43, size.height * .43);
    canvas.drawCircle(center, size.width * .27, _paint(fill: selected));
    if (selected) {
      canvas.drawCircle(
        center,
        size.width * .13,
        _paint(fill: true)..color = _navigationColor,
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
    return oldDelegate.icon != icon || oldDelegate.selected != selected;
  }
}
