import 'package:material_ui/material_ui.dart';

class CenterH extends StatelessWidget {
  final Widget child;

  const CenterH({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentGeometry.topCenter,
      child: child,
    );
  }
}
