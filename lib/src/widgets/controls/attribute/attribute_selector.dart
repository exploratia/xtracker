import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../generated/locale_keys.g.dart';
import '../../../model/series/attributes/attribute.dart';
import '../../../model/series/attributes/attribute_resolver.dart';
import '../../../util/media_query_utils.dart';
import '../../../util/theme_utils.dart';
import 'attribute_renderer.dart';

class AttributeSelector extends StatelessWidget {
  final AttributeResolver attributeResolver;
  final List<Attribute> attributes;
  final String? attributeUuid;
  final void Function(String) handleAttributeUuid;
  final void Function()? deleteAttributeUuid;

  const AttributeSelector({
    super.key,
    required this.attributeResolver,
    required this.attributes,
    this.attributeUuid,
    required this.handleAttributeUuid,
    this.deleteAttributeUuid,
  });

  @override
  Widget build(BuildContext context) {
    var attributesPopupMenuButton = PopupMenuButton(
      borderRadius: ThemeUtils.borderRadiusCircular,
      icon: attributeUuid == null ? const Icon(Icons.list) : null,
      tooltip: LocaleKeys.controls_select_attribute_action_select_tooltip.tr(),
      itemBuilder: (context) {
        var list = attributes
            .map(
              (e) => PopupMenuItem(
                /* Flutter Bug? if right >= 10 a huge wider padding is used. Seems not to work always. If only Text-Widgets are uses as child it has no effect. */
                padding: const EdgeInsets.only(right: 9, left: 9, bottom: 0),
                onTap: () => handleAttributeUuid(e.aid),
                child: AttributeRenderer(attribute: e),
              ),
            )
            .toList();
        if (deleteAttributeUuid != null) {
          list.add(
            PopupMenuItem(
              padding: const EdgeInsets.only(right: 9, left: 9, bottom: 0),
              onTap: deleteAttributeUuid,
              child: Tooltip(
                message: LocaleKeys.controls_select_attribute_action_clear_tooltip.tr(),
                child: const Center(child: Icon(Icons.clear_outlined)),
              ),
            ),
          );
        }
        return list;
      },
      child: attributeUuid != null
          ? Padding(
              padding: const EdgeInsets.all(ThemeUtils.paddingSmall),
              child: AttributeRenderer(attribute: attributeResolver.resolve(attributeUuid)),
            )
          : null,
    );

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 48 * MediaQueryUtils.textScaleFactor),
      child: Center(
        child: attributesPopupMenuButton,
      ),
    );
  }
}
