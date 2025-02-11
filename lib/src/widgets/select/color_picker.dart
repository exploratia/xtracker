import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPicker extends StatefulWidget {
  const ColorPicker({super.key, this.color = const Color(0xffde0b30), required this.colorSelected});

  final Color color;
  final void Function(Color) colorSelected;

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  Color currentColor = const Color(0xffde0b30);

  @override
  void initState() {
    currentColor = widget.color;
    super.initState();
  }

  void changeColor(Color color) {
    setState(() => currentColor = color);
    widget.colorSelected(currentColor);
  }

  @override
  Widget build(BuildContext context) {
    final contrastColor = useWhiteForeground(currentColor) ? Colors.white : Colors.black;
    return ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              titlePadding: const EdgeInsets.all(0),
              contentPadding: const EdgeInsets.all(0),
              shape: RoundedRectangleBorder(
                borderRadius: MediaQuery.of(context).orientation == Orientation.portrait
                    ? const BorderRadius.vertical(
                        top: Radius.circular(500),
                        bottom: Radius.circular(100),
                      )
                    : const BorderRadius.horizontal(right: Radius.circular(500)),
              ),
              content: SingleChildScrollView(
                child: HueRingPicker(
                  pickerColor: currentColor,
                  onColorChanged: changeColor,
                  enableAlpha: false,
                ),
              ),
            );
          },
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: currentColor,
        side: BorderSide(color: contrastColor),
      ),
      child: Icon(
        Icons.palette_outlined,
        color: contrastColor,
      ),
    );
  }
}
