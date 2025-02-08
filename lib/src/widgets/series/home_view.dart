import 'package:flutter/material.dart';

import '../card/glowing_border_container.dart';
import '../layout/v_centered_single_child_scroll_view_with_scrollbar.dart';
import 'add_first_series.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final mediaQueryData = MediaQuery.of(context);

    List<Widget> items = [
      // Placeholder(fallbackHeight: 50)
      GlowingBorderContainer(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.read_more),
                Text("Some child"),
              ],
            ),
          ],
        ),
      )),
    ];

    return VCenteredSingleChildScrollViewWithScrollbar(
        child: Column(
      spacing: 30,
      children: [
        ...items,
        if (items.isEmpty) const AddFirstSeries(),
      ],
    ));
  }
}
