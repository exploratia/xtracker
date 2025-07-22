import 'package:flutter/material.dart';

import '../responsive/device_dependent_constrained_box.dart';
import 'center_horizontal.dart';
import 'single_child_scroll_view_with_scrollbar.dart';

/// Wrapper for Forms.<br>
/// Scrollbar, centered, Padding and formKey
class ScrollableCenteredFormWrapper extends StatelessWidget {
  final Key formKey;
  final List<Widget> children;
  final AutovalidateMode autovalidateMode;

  const ScrollableCenteredFormWrapper({super.key, required this.formKey, required this.children, this.autovalidateMode = AutovalidateMode.disabled});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollViewWithScrollbar(
      child: CenterH(
        child: DeviceDependentWidthConstrainedBox(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: formKey,
              autovalidateMode: autovalidateMode,
              child: Column(
                children: children,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
