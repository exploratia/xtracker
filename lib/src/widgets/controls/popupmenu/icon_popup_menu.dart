import 'package:flutter/material.dart';

class IconPopupMenu extends StatefulWidget {
  /// [animated] if true, fly in. Fade is always active, because of the default page transition.
  const IconPopupMenu({super.key, required this.icon, required this.menuEntries, this.animated = true});

  final Icon icon;
  final List<IconPopupMenuEntry> menuEntries;
  final bool animated;

  @override
  State<IconPopupMenu> createState() => _IconPopupMenuState();
}

class _IconPopupMenuState extends State<IconPopupMenu> {
  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final GlobalKey menuButtonKey = GlobalKey();
    return IconButton(
      key: menuButtonKey,
      icon: widget.icon,
      onPressed: () => _showCustomPopupMenu(context, menuButtonKey, themeData),
    );
  }

  void _showCustomPopupMenu(BuildContext context, GlobalKey key, ThemeData themeData) {
    final RenderBox button = key.currentContext!.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset offset = button.localToGlobal(Offset.zero, ancestor: overlay);

    final menuPosition = Offset(offset.dx, offset.dy + button.size.height + 16);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "PopupMenu",
      barrierColor: Colors.transparent,
      pageBuilder: (_, __, ___) => _Menu(
        position: menuPosition,
        menuEntries: widget.menuEntries,
        animated: widget.animated,
      ),
    );
  }
}

class _Menu extends StatelessWidget {
  const _Menu({
    required this.position,
    required this.menuEntries,
    required this.animated,
  });

  final Offset position;
  final List<IconPopupMenuEntry> menuEntries;
  final bool animated;

  @override
  Widget build(BuildContext context) {
    Widget menu = animated
        ? _AnimatedMenu(menuEntries: menuEntries)
        : Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
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
          top: position.dy,
          child: menu,
        ),
      ],
    );
  }
}

class _AnimatedMenu extends StatefulWidget {
  final List<IconPopupMenuEntry> menuEntries;

  const _AnimatedMenu({required this.menuEntries});

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

  Widget _buildAnimatedItem(Widget widget, int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final animationValue = Curves.easeOut.transform(
          (_controller.value).clamp(0.0, 1.0),
        );

        return Opacity(
          opacity: animationValue,
          child: Transform.translate(
            offset: Offset(0, (1 - animationValue) * (-70 * (index + 1))),
            child: child,
          ),
        );
      },
      child: widget,
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];
    for (var i = 0; i < widget.menuEntries.length; ++i) {
      var mi = widget.menuEntries[i];
      items.add(_buildAnimatedItem(
        _MenuItemIconButton(mi),
        i,
      ));
    }

    return Column(
      spacing: 16,
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
      elevation: 4.0,
      child: IconButton(
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
