import 'package:flutter/material.dart';

import '../../util/theme_utils.dart';
import '../layout/drop_down_menu_item_child.dart';
import 'icon_map.dart';

class IconPicker extends StatefulWidget {
  const IconPicker({super.key, this.icoName = 'onetwothree_outlined', required this.icoSelected});

  final String icoName;
  final void Function(String) icoSelected;

  @override
  State<IconPicker> createState() => _IconPickerState();
}

class _IconPickerState extends State<IconPicker> {
  String currentIcoName = 'onetwothree_outlined';

  @override
  void initState() {
    currentIcoName = widget.icoName;
    super.initState();
  }

  void changeIco(String? icoName) {
    if (icoName == null) return;
    setState(() => currentIcoName = icoName);
    widget.icoSelected(currentIcoName);
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      key: const Key('settingsThemeSelect'),
      borderRadius: ThemeUtils.cardBorderRadius,
      value: currentIcoName,
      onChanged: (value) => changeIco(value),
      // menuMaxHeight: 300,
      items: IconMap.icons.keys.map((icoName) {
        var text = Icon(IconMap.icons[icoName]);
        var selected = currentIcoName == icoName;
        return DropdownMenuItem<String>(key: Key('icoSelect_$icoName'), value: icoName, child: DropDownMenuItemChild(selected: selected, child: text));
      }).toList(),
    );

    // to see all icons as once
    // Container(
    //   height: 300,
    //   width: 300,
    //   color: Colors.green,
    //   child: SingleChildScrollView(
    //     child: Wrap(
    //       spacing: 10,
    //       children: [
    //         ...items.map((icoName) => IconButton(
    //               key: Key('ico_select_$icoName'),
    //               icon: Icon(IconMap.icons[icoName]),
    //               onPressed: () => print(icoName),
    //             ))
    //       ],
    //     ),
    //   ),
    // ),
  }
}
