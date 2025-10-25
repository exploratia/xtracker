import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../util/theme_utils.dart';
import '../responsive/device_dependent_constrained_box.dart';
import 'center_horizontal.dart';
import 'single_child_scroll_view_with_scrollbar.dart';

/// Wrapper for Forms.<br>
/// Scrollbar, centered, Padding and formKey
class ScrollableCenteredFormWrapper extends StatelessWidget {
  final Key formKey;
  final List<Widget> children;
  final AutovalidateMode autovalidateMode;
  final bool vCentered;
  final bool useSeriesDataInputDlgWidth;
  final double spacing;

  const ScrollableCenteredFormWrapper({
    super.key,
    required this.formKey,
    required this.children,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.vCentered = false,
    this.useSeriesDataInputDlgWidth = false,
    this.spacing = 0,
  });

  @override
  Widget build(BuildContext context) {
    var form = Form(
      key: formKey,
      autovalidateMode: autovalidateMode,
      child: Column(
        spacing: spacing,
        children: children,
      ),
    );

    Widget constrained;
    if (useSeriesDataInputDlgWidth) {
      constrained = ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: ThemeUtils.seriesDataInputDlgMaxWidth),
        child: form,
      );
    } else {
      constrained = DeviceDependentWidthConstrainedBox(
        child: form,
      );
    }

    if (vCentered) {
      return Row(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollViewWithScrollbar(
                useScreenPadding: true,
                child: Container(
                  constraints: BoxConstraints(minHeight: math.max(20, constraints.maxHeight - 2 * ThemeUtils.screenPadding)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      constrained,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return SingleChildScrollViewWithScrollbar(
      useScreenPadding: true,
      child: CenterH(child: constrained),
    );
  }
}
