import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../../../generated/locale_keys.g.dart';
import '../../../util/color_utils.dart';

class ColorPicker extends StatefulWidget {
  const ColorPicker({super.key, this.color = const Color(0xffde0b30), required this.colorSelected, this.showColorLabel = true, this.showPixelPreview = false});

  final Color color;
  final void Function(Color) colorSelected;
  final bool showColorLabel;
  final bool showPixelPreview;

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
    final contrastColor = ColorUtils.getContrastingTextColor(currentColor); // useWhiteForeground(currentColor) ? Colors.white : Colors.black;
    var pickerBtn = ElevatedButton(
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

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 10,
      children: [
        if (widget.showColorLabel) Text(LocaleKeys.seriesEdit_common_label_seriesColor.tr()),
        pickerBtn,
        // if (widget.showPixelPreview) ...[
        //   Text("Pixel preview"),
        //   PixelViewPreview(color: currentColor),
        // ]
      ],
    );
  }
}
