import 'package:flutter/material.dart';

class IconPopupMenu extends StatefulWidget {
  const IconPopupMenu({super.key, required this.icon, required this.menuItems});

  final Icon icon;
  final List<IconPopupMenuEntry> menuItems;

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

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "PopupMenu",
      barrierColor: Colors.transparent,
      pageBuilder: (_, __, ___) => Stack(
        children: [
          Positioned(
            left: offset.dx,
            top: offset.dy + button.size.height + 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 16,
              children: [
                ...widget.menuItems.map(
                  (mi) => Material(
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    color: themeData.colorScheme.secondary,
                    elevation: 4.0,
                    child: IconButton(
                      hoverColor: themeData.colorScheme.primary,
                      onPressed: () {
                        Navigator.of(context).pop();
                        mi.fn();
                      },
                      icon: mi.icon,
                      color: themeData.colorScheme.onSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class IconPopupMenuEntry {
  final Icon icon;
  final void Function() fn;

  IconPopupMenuEntry(this.icon, this.fn);
}
