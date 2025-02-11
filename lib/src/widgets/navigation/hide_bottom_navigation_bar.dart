import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Widget which hides BottomNavigationBar
class HideBottomNavigationBar extends StatefulWidget {
  static final ValueNotifier<bool> visible = ValueNotifier<bool>(true);
  static bool _forceHide = true;

  static void setScrollPosition(ScrollPosition scrollPos) {
    if (_forceHide) return;
    // Scroller ganz oben? Dann auf jeden Fall wieder anzeigen
    if (scrollPos.pixels == 0) {
      visible.value = true;
    } else if (scrollPos.userScrollDirection == ScrollDirection.reverse && visible.value) {
      visible.value = false;
    } else if (scrollPos.userScrollDirection == ScrollDirection.forward && !visible.value) {
      visible.value = true;
    }
  }

  static void setVisible(bool value) {
    if (_forceHide && value) return;
    if (visible.value != value) {
      visible.value = value;
    }
  }

  static void setForceHide(bool value) {
    _forceHide = value;
    setVisible(!value);
  }

  const HideBottomNavigationBar({super.key, required this.child});

  final Widget child;

  @override
  State<HideBottomNavigationBar> createState() => _HideBottomNavigationBar();
}

class _HideBottomNavigationBar extends State<HideBottomNavigationBar> {
  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) => HideBottomNavigationBar.setForceHide(false));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => HideBottomNavigationBar.setForceHide(true));
    return widget.child;
  }
}
