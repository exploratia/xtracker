import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../util/theme_utils.dart';

/// Defines how popup menu entries are arranged around their anchor.
enum IconPopupMenuLayout { vertical, radial }

class IconPopupMenu extends StatefulWidget {
  /// [animated] if true, fly in. Fade is always active, because of the default page transition.
  const IconPopupMenu({super.key, required this.icon, required this.menuEntries, this.animated = true});

  final Icon icon;
  final List<IconPopupMenuEntry> menuEntries;
  final bool animated;

  /// Shows the popup menu at a global screen position.
  static Future<void> showAt(
    BuildContext context, {
    required Offset globalPosition,
    required List<IconPopupMenuEntry> menuEntries,
    bool animated = true,
    IconPopupMenuLayout layout = IconPopupMenuLayout.vertical,
  }) {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = overlay.globalToLocal(globalPosition);
    final openUpwards = position.dy >= overlay.size.height * 2 / 3;
    final menuPosition = Offset(
      position.dx.clamp(ThemeUtils.defaultPadding, overlay.size.width - kMinInteractiveDimension - ThemeUtils.defaultPadding),
      openUpwards ? overlay.size.height - position.dy + ThemeUtils.verticalSpacingLarge : position.dy + ThemeUtils.verticalSpacingLarge,
    );

    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'PopupMenu',
      barrierColor: Colors.transparent,
      pageBuilder: (_, _, _) => layout == IconPopupMenuLayout.radial
          ? _RadialMenu(
              position: _safeRadialMenuPosition(position, overlay.size),
              menuEntries: menuEntries,
              animated: animated,
            )
          : _Menu(
              position: menuPosition,
              menuEntries: menuEntries,
              animated: animated,
              openUpwards: openUpwards,
            ),
    );
  }

  static Offset _safeRadialMenuPosition(Offset position, Size overlaySize) {
    const radius = _RadialMenu.radius;
    const margin = radius + kMinInteractiveDimension / 2 + ThemeUtils.defaultPadding;
    final x = overlaySize.width >= margin * 2 ? position.dx.clamp(margin, overlaySize.width - margin) : overlaySize.width / 2;
    final y = overlaySize.height >= margin * 2 ? position.dy.clamp(margin, overlaySize.height - margin) : overlaySize.height / 2;
    return Offset(x, y);
  }

  @override
  State<IconPopupMenu> createState() => _IconPopupMenuState();
}

class _RadialMenu extends StatelessWidget {
  const _RadialMenu({required this.position, required this.menuEntries, required this.animated});

  static const double radius = 64;

  final Offset position;
  final List<IconPopupMenuEntry> menuEntries;
  final bool animated;

  @override
  Widget build(BuildContext context) {
    if (!animated) {
      return _buildMenu(1);
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      builder: (_, value, _) => _buildMenu(value),
    );
  }

  Widget _buildMenu(double animationValue) {
    final angles = _angles(menuEntries.length);
    return Stack(
      children: [
        for (var i = 0; i < menuEntries.length; i++)
          Positioned(
            left: position.dx + math.cos(angles[i]) * radius * animationValue - kMinInteractiveDimension / 2,
            top: position.dy + math.sin(angles[i]) * radius * animationValue - kMinInteractiveDimension / 2,
            child: Opacity(
              opacity: animationValue,
              child: _MenuItemIconButton(menuEntries[i]),
            ),
          ),
      ],
    );
  }

  List<double> _angles(int itemCount) {
    return switch (itemCount) {
      1 => [-math.pi / 2],
      2 => [-math.pi / 2, math.pi / 2],
      3 => [-math.pi / 2, math.pi / 6, 5 * math.pi / 6],
      _ => List.generate(itemCount, (index) => -math.pi / 2 + index * 2 * math.pi / itemCount),
    };
  }
}

class _IconPopupMenuState extends State<IconPopupMenu> {
  @override
  Widget build(BuildContext context) {
    final GlobalKey menuButtonKey = GlobalKey();
    return IconButton(
      iconSize: ThemeUtils.iconSizeScaled,
      key: menuButtonKey,
      icon: widget.icon,
      onPressed: () => _showCustomPopupMenu(context, menuButtonKey),
    );
  }

  void _showCustomPopupMenu(BuildContext context, GlobalKey key) {
    final RenderBox button = key.currentContext!.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final buttonCenter = button.localToGlobal(button.size.center(Offset.zero));
    final openUpwards = buttonCenter.dy >= overlay.size.height * 2 / 3;
    final offset = button.localToGlobal(
      openUpwards ? Offset.zero : Offset(0, button.size.height),
    );
    IconPopupMenu.showAt(
      context,
      globalPosition: offset,
      menuEntries: widget.menuEntries,
      animated: widget.animated,
    );
  }
}

class _Menu extends StatelessWidget {
  const _Menu({
    required this.position,
    required this.menuEntries,
    required this.animated,
    required this.openUpwards,
  });

  final Offset position;
  final List<IconPopupMenuEntry> menuEntries;
  final bool animated;
  final bool openUpwards;

  @override
  Widget build(BuildContext context) {
    Widget menu = animated
        ? _AnimatedMenu(
            menuEntries: menuEntries,
            openUpwards: openUpwards,
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            spacing: ThemeUtils.verticalSpacingLarge,
            children: [
              ...menuEntries.map(
                (mi) => _MenuItemIconButton(mi),
              ),
            ],
          );

    return Stack(
      children: [
        Positioned(
          left: position.dx,
          top: openUpwards ? null : position.dy,
          bottom: openUpwards ? position.dy : null,
          child: menu,
        ),
      ],
    );
  }
}

class _AnimatedMenu extends StatefulWidget {
  final List<IconPopupMenuEntry> menuEntries;
  final bool openUpwards;

  const _AnimatedMenu({
    required this.menuEntries,
    required this.openUpwards,
  });

  @override
  State<_AnimatedMenu> createState() => _AnimatedMenuState();
}

class _AnimatedMenuState extends State<_AnimatedMenu> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final int animationDuration = 150;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: animationDuration),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildAnimatedItem(Widget childWidget, int index) {
    final initialYOffset = 70 * (index + 1) * (widget.openUpwards ? 1 : -1);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final animationValue = Curves.easeOut.transform(
          (_controller.value).clamp(0.0, 1.0),
        );

        return Opacity(
          opacity: animationValue,
          child: Transform.translate(
            offset: Offset(0, (1 - animationValue) * initialYOffset),
            child: child,
          ),
        );
      },
      child: childWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];
    for (var i = 0; i < widget.menuEntries.length; ++i) {
      var mi = widget.menuEntries[i];
      items.add(
        _buildAnimatedItem(
          _MenuItemIconButton(mi),
          i,
        ),
      );
    }

    return Column(
      spacing: ThemeUtils.verticalSpacingLarge,
      mainAxisSize: MainAxisSize.min,
      children: items,
    );
  }
}

class _MenuItemIconButton extends StatelessWidget {
  const _MenuItemIconButton(this.menuEntry);

  final IconPopupMenuEntry menuEntry;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Material(
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      color: themeData.colorScheme.secondary,
      elevation: ThemeUtils.elevation,
      child: IconButton(
        iconSize: ThemeUtils.iconSizeScaled,
        tooltip: menuEntry.tooltip,
        hoverColor: themeData.colorScheme.primary,
        onPressed: () {
          Navigator.of(context).pop();
          menuEntry.fn();
        },
        icon: menuEntry.icon,
        color: themeData.colorScheme.onSecondary,
      ),
    );
  }
}

class IconPopupMenuEntry {
  final Icon icon;
  final void Function() fn;
  final String tooltip;

  IconPopupMenuEntry(this.icon, this.fn, this.tooltip);
}
