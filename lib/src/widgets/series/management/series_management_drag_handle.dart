import 'package:flutter/material.dart';

class SeriesManagementDragHandle extends StatelessWidget {
  const SeriesManagementDragHandle({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return ReorderableDragStartListener(
      index: index,
      child: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Icon(Icons.drag_handle_outlined),
      ),
    );
  }
}
